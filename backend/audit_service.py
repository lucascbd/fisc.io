"""
Audit service: reconcile bank CSV/OFX files against DB expenses.

Supported formats:
  - CSV: configurable columns (date, description, amount)
  - OFX: SGML format (checking account export)
"""
import re
import io
import csv
import unicodedata
from datetime import date, datetime
from decimal import Decimal, InvalidOperation
from dataclasses import dataclass, field
from typing import Optional, List, Tuple, Dict
from difflib import SequenceMatcher
from collections import defaultdict

from dateutil.relativedelta import relativedelta
from sqlalchemy.orm import Session

from models import Expense, ExpenseSplit

# ── Thresholds & constants ────────────────────────────────────────────────────
MICRO_THRESHOLD  = Decimal('0.10')   # |amount| below this → micro-adjustment
SIM_AUTO_MATCH   = 0.68              # similarity >= this + date_ok → matched
SIM_AMBIGUOUS    = 0.20              # similarity below this → discard candidate
DATE_WINDOW_PAR  = 35                # days tolerance for installment parcels

# OFX: MEMO/NAME patterns to silently skip (investment/internal transactions)
OFX_SKIP = [
    'REND PAGO APLIC AUT MAIS',
    'APLICACAO CDB DI',
    'RESGATE CDB DI',
    'ITAU BLACK',
    'CREDITO LIBERAD',
    'PIX ORIGEM CARTAO',
]

# CSV: description patterns to silently skip
CSV_SKIP = [
    'PAGAMENTO EFETUADO',
]

# ── Parcel regex: NN/NN at end of description ─────────────────────────────────
_PARCEL_RE = re.compile(r'\s*(\d{2})/(\d{2})$')

# ── Date formats to try when parsing ─────────────────────────────────────────
_DATE_FMTS = ['%Y-%m-%d', '%d/%m/%Y', '%d/%m/%y', '%m/%d/%Y', '%Y%m%d']


# ── Data classes ──────────────────────────────────────────────────────────────
@dataclass
class FileTxn:
    txn_date:     date
    description:  str             # cleaned (no parcel suffix)
    amount:       Decimal         # positive = expense, negative = income/refund
    raw_line:     str             # original for display
    parcel_num:   Optional[int]   = None
    parcel_total: Optional[int]   = None
    fitid:        Optional[str]   = None
    is_micro:     bool            = False


@dataclass
class AuditResult:
    matched:           List[dict] = field(default_factory=list)
    ambiguous:         List[dict] = field(default_factory=list)
    unmatched:         List[dict] = field(default_factory=list)
    micro_adjustments: List[dict] = field(default_factory=list)
    silent_filtered:   int = 0


# ── Text helpers ──────────────────────────────────────────────────────────────
def _strip_accents(text: str) -> str:
    n = unicodedata.normalize('NFKD', text)
    return ''.join(c for c in n if not unicodedata.combining(c))


def _normalize(text: str) -> str:
    text = _strip_accents(text).lower()
    text = re.sub(r'[^a-z0-9\s]', ' ', text)
    return re.sub(r'\s+', ' ', text).strip()


def _sim(a: str, b: str) -> float:
    return SequenceMatcher(None, _normalize(a), _normalize(b)).ratio()


def _parse_parcel(desc: str) -> Tuple[str, Optional[int], Optional[int]]:
    m = _PARCEL_RE.search(desc)
    if not m:
        return desc.strip(), None, None
    num, total = int(m.group(1)), int(m.group(2))
    if num < 1 or total < 1 or num > total:
        return desc.strip(), None, None
    return desc[:m.start()].strip(), num, total


def _parse_date(val: str) -> Optional[date]:
    val = val.strip()
    for fmt in _DATE_FMTS:
        try:
            return datetime.strptime(val, fmt).date()
        except ValueError:
            continue
    return None


def _parse_amount(val: str) -> Optional[Decimal]:
    """Parse Brazilian/international amount string."""
    val = val.strip()
    # Remove currency symbol and whitespace
    val = re.sub(r'[R$\s]', '', val)
    # Remove trailing D/C (débito/crédito markers)
    val = re.sub(r'[DdCc]$', '', val)
    val = val.strip()
    if not val:
        return None
    # Handle negative in parentheses: (1.234,56) → -1234.56
    negative = val.startswith('-') or (val.startswith('(') and val.endswith(')'))
    val = val.strip('-()').strip()
    # Brazilian format: 1.234,56 (dot=thousands, comma=decimal)
    if ',' in val and '.' in val:
        val = val.replace('.', '').replace(',', '.')
    elif ',' in val:
        val = val.replace(',', '.')
    try:
        result = Decimal(val)
        return -result if negative else result
    except InvalidOperation:
        return None


def _txn_dict(txn: FileTxn) -> dict:
    return {
        'date':        txn.txn_date.isoformat(),
        'description': txn.description,
        'amount':      float(txn.amount),
        'raw_line':    txn.raw_line,
        'parcel_num':  txn.parcel_num,
        'parcel_total':txn.parcel_total,
    }


def _exp_dict(exp: Expense, display_amount: Optional[float] = None) -> dict:
    return {
        'id':               exp.id,
        'description':      exp.description,
        'total_amount':     float(exp.total_amount),
        'display_amount':   display_amount if display_amount is not None else float(exp.total_amount),
        'expense_date':     exp.expense_date.isoformat(),
        'installments':     exp.installments,
        'category_id':      exp.category_id,
        'split_profile_id': exp.split_profile_id,
        'paid_by_user_id':  exp.paid_by_user_id,
    }


# ── CSV helpers ───────────────────────────────────────────────────────────────
def _detect_sep(content: str) -> str:
    """Detect CSV separator: semicolon wins if present (BR banks use ; because , is decimal)."""
    first_line = content.strip().splitlines()[0] if content.strip() else ''
    if first_line.count(';') >= first_line.count(',') and first_line.count(';') > 0:
        return ';'
    return ','


def detect_csv_headers(content: str) -> List[str]:
    """Return the list of column headers from the first CSV line."""
    sep = _detect_sep(content)
    first_line = content.strip().splitlines()[0] if content.strip() else ''
    return [p.strip().strip('"').strip("'") for p in first_line.split(sep)]


def _best_col(headers: List[str], keywords: List[str]) -> Optional[str]:
    """Auto-select column header best matching the given keywords."""
    norm_headers = [_strip_accents(h).lower().strip() for h in headers]
    for kw in keywords:
        for i, nh in enumerate(norm_headers):
            if kw in nh:
                return headers[i]
    return headers[0] if headers else None


# ── CSV parser ────────────────────────────────────────────────────────────────
def parse_csv(
    content: str,
    col_date:   Optional[str] = None,
    col_desc:   Optional[str] = None,
    col_amount: Optional[str] = None,
    negate:     bool = False,
) -> Tuple[List[FileTxn], int]:
    """
    Parse credit card CSV.
    If column names are not provided, auto-detect from headers.
    """
    txns: List[FileTxn] = []
    silent = 0

    # Strip BOM (common in Windows/Excel exports)
    content = content.lstrip('\ufeff')

    sep = _detect_sep(content)
    headers = detect_csv_headers(content)
    norm_headers = {_strip_accents(h).lower().strip(): h for h in headers}

    # Auto-detect columns if not provided
    if not col_date:
        col_date = _best_col(headers, ['data', 'date', 'dt'])
    if not col_desc:
        col_desc = _best_col(headers, ['lancamento', 'descricao', 'historico', 'desc', 'nome', 'memorial'])
    if not col_amount:
        col_amount = _best_col(headers, ['valor', 'value', 'amount', 'vl', 'vlr', 'montante'])

    # Normalize requested column name → key used in row_n
    def _find_key(requested: Optional[str]) -> Optional[str]:
        if not requested:
            return None
        norm = _strip_accents(requested).lower().strip()
        return norm if norm in norm_headers else None

    key_date   = _find_key(col_date)
    key_desc   = _find_key(col_desc)
    key_amount = _find_key(col_amount)

    reader = csv.DictReader(io.StringIO(content), delimiter=sep)
    for row in reader:
        row_n = {_strip_accents(k).lower().strip(): (v or '').strip() for k, v in row.items()}

        date_str = row_n.get(key_date, '')   if key_date   else ''
        desc_raw = row_n.get(key_desc, '')   if key_desc   else ''
        val_str  = row_n.get(key_amount, '') if key_amount else ''

        if not date_str and not desc_raw and not val_str:
            continue

        txn_date = _parse_date(date_str)
        if txn_date is None:
            continue

        amount = _parse_amount(val_str)
        if amount is None:
            continue

        if negate:
            amount = -amount

        # Silent filter
        if any(k.lower() in desc_raw.lower() for k in CSV_SKIP):
            silent += 1
            continue

        # Skip zero-amount rows
        if amount == 0:
            continue

        is_micro = abs(amount) < MICRO_THRESHOLD
        base, pnum, ptotal = _parse_parcel(desc_raw)

        txns.append(FileTxn(
            txn_date=txn_date, description=base, amount=amount,
            raw_line=f"{date_str} | {desc_raw} | {val_str}",
            parcel_num=pnum, parcel_total=ptotal, is_micro=is_micro,
        ))

    return txns, silent


# ── OFX parser ────────────────────────────────────────────────────────────────
def parse_ofx(content: str) -> Tuple[List[FileTxn], int]:
    """Parse SGML OFX (checking account export)."""
    txns: List[FileTxn] = []
    silent = 0

    def _tag(block: str, name: str) -> str:
        m = re.search(rf'<{name}>\s*([^\n<]+)', block)
        return m.group(1).strip() if m else ''

    blocks = re.findall(r'<STMTTRN>(.*?)</STMTTRN>', content, re.DOTALL | re.IGNORECASE)

    for block in blocks:
        memo     = _tag(block, 'MEMO') or _tag(block, 'NAME')
        date_str = _tag(block, 'DTPOSTED')[:8]   # YYYYMMDD
        amt_str  = _tag(block, 'TRNAMT')
        fitid    = _tag(block, 'FITID')

        # Combine NAME + MEMO when both present and different
        name_val = _tag(block, 'NAME')
        memo_val = _tag(block, 'MEMO')
        if name_val and memo_val and _normalize(name_val) != _normalize(memo_val):
            memo = f"{name_val} {memo_val}"
        elif name_val:
            memo = name_val
        elif memo_val:
            memo = memo_val

        if not memo or not date_str or not amt_str:
            continue

        txn_date = _parse_date(date_str)
        if txn_date is None:
            continue

        ofx_amt = _parse_amount(amt_str)
        if ofx_amt is None:
            continue

        # Silent filter
        if any(k.lower() in memo.lower() for k in OFX_SKIP):
            silent += 1
            continue

        # OFX sign convention: DEBIT = negative (expense), CREDIT = positive (income)
        expense_amount = -ofx_amt

        # Skip zero-amount rows
        if expense_amount == 0:
            continue

        is_micro = abs(expense_amount) < MICRO_THRESHOLD
        base, pnum, ptotal = _parse_parcel(memo)

        txns.append(FileTxn(
            txn_date=txn_date, description=base, amount=expense_amount,
            raw_line=memo, parcel_num=pnum, parcel_total=ptotal,
            fitid=fitid, is_micro=is_micro,
        ))

    return txns, silent


# ── Matching engine ───────────────────────────────────────────────────────────
def match_transactions(db: Session, txns: List[FileTxn], payment_method_id: int) -> AuditResult:
    """
    Classify each file transaction as matched / ambiguous / unmatched
    against DB expenses for the given payment_method_id.
    """
    result = AuditResult()

    expenses: List[Expense] = (
        db.query(Expense)
        .filter(Expense.payment_method_id == payment_method_id)
        .all()
    )

    # Pre-load splits for installment expenses
    inst_ids = [e.id for e in expenses if e.installments > 1]
    splits_by_exp: Dict[int, List[ExpenseSplit]] = defaultdict(list)
    if inst_ids:
        for s in (db.query(ExpenseSplit)
                    .filter(ExpenseSplit.expense_id.in_(inst_ids))
                    .all()):
            splits_by_exp[s.expense_id].append(s)

    # Parcel cache: (norm_base_desc, parcel_total) → expense_id
    parcel_cache: Dict[Tuple[str, int], int] = {}
    used_ids: set = set()

    for txn in txns:
        # ── Micro-adjustments ─────────────────────────────────────────────
        if txn.is_micro:
            result.micro_adjustments.append(_txn_dict(txn))
            continue

        # ── Parcel cache: auto-match subsequent parcels of same purchase ──
        if txn.parcel_num and txn.parcel_total:
            cache_key = (_normalize(txn.description), txn.parcel_total)
            if cache_key in parcel_cache:
                exp_id = parcel_cache[cache_key]
                exp = next((e for e in expenses if e.id == exp_id), None)
                result.matched.append({
                    'file':    _txn_dict(txn),
                    'expense': _exp_dict(exp) if exp else None,
                    'reason':  f'parcela {txn.parcel_num}/{txn.parcel_total}',
                })
                continue

        # ── Score each DB expense ─────────────────────────────────────────
        file_amount = abs(float(txn.amount))
        candidates = []

        for exp in expenses:
            if exp.id in used_ids:
                continue

            exp_amt      = float(exp.total_amount)
            display_amt  = exp_amt          # shown to user; overridden for installments
            amount_ok    = False

            # ── Try installment parcel match first ────────────────────────
            is_parcel_match = (
                txn.parcel_num and txn.parcel_total
                and exp.installments == txn.parcel_total
            )
            if is_parcel_match:
                splits = splits_by_exp.get(exp.id, [])
                sp = next((s for s in splits
                           if s.installment_number == txn.parcel_num), None)
                if sp:
                    sp_amt = float(sp.installment_amount)
                    if abs(sp_amt - file_amount) <= 0.01:
                        amount_ok   = True
                        display_amt = sp_amt

            # ── Regular (non-parcel) amount match ─────────────────────────
            if not amount_ok:
                if exp_amt <= 0:
                    continue
                # Also try each installment split against file_amount
                # (CSV may list individual installment without parcel suffix)
                if exp.installments > 1:
                    for sp in splits_by_exp.get(exp.id, []):
                        sp_amt = float(sp.installment_amount)
                        if abs(sp_amt - file_amount) <= 0.01:
                            amount_ok   = True
                            display_amt = sp_amt
                            break
                if not amount_ok:
                    if abs(exp_amt - file_amount) <= 0.01:
                        amount_ok = True

            if not amount_ok:
                continue

            # ── Date proximity (soft signal, not a hard gate) ─────────────
            days_diff = abs((txn.txn_date - exp.expense_date).days)
            date_ok   = days_diff <= 7

            # ── Description similarity ────────────────────────────────────
            sim = _sim(txn.description, exp.description)

            candidates.append({
                'expense':    _exp_dict(exp, display_amt),
                'similarity': round(sim, 2),
                'date_ok':    date_ok,
                'days_diff':  days_diff,
            })

        # Sort: date_ok first, then similarity desc, then days_diff asc
        candidates.sort(
            key=lambda x: (x['date_ok'], x['similarity'], -x['days_diff']),
            reverse=True,
        )

        if not candidates:
            result.unmatched.append({'file': _txn_dict(txn)})

        elif (candidates[0]['similarity'] >= SIM_AUTO_MATCH
              and candidates[0]['date_ok']):
            best = candidates[0]
            exp_id = best['expense']['id']
            used_ids.add(exp_id)
            if txn.parcel_num and txn.parcel_total:
                cache_key = (_normalize(txn.description), txn.parcel_total)
                parcel_cache[cache_key] = exp_id
            result.matched.append({
                'file':    _txn_dict(txn),
                'expense': best['expense'],
                'reason':  f"sim={best['similarity']:.0%}",
            })

        else:
            # Strip internal-only days_diff before sending to frontend
            clean = [
                {k: v for k, v in c.items() if k != 'days_diff'}
                for c in candidates[:5]
            ]
            result.ambiguous.append({
                'file':       _txn_dict(txn),
                'candidates': clean,
            })

    return result
