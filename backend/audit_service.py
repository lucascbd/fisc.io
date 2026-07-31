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
from sqlalchemy import extract

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
    surplus:           List[dict] = field(default_factory=list)
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


# ── XLSX parser ───────────────────────────────────────────────────────────────
def parse_xlsx(content: bytes) -> Tuple[List[FileTxn], int]:
    """
    Parse credit card XLSX statement (Itaú format).
    Header is on row 14; data starts on row 15.
    Columns: B=Data, C=Lançamento, D=Parcelamento, E=Valor
    """
    txns: List[FileTxn] = []
    silent = 0

    import openpyxl
    wb = openpyxl.load_workbook(io.BytesIO(content), data_only=True)
    ws = wb.active

    HEADER_ROW = 14   # 1-indexed; data begins at row 15
    COL_DATE   = 2    # B
    COL_DESC   = 3    # C
    COL_PARCEL = 4    # D
    COL_AMOUNT = 5    # E

    for row in ws.iter_rows(min_row=HEADER_ROW + 1, values_only=True):
        if len(row) < COL_AMOUNT:
            continue

        date_val   = row[COL_DATE   - 1]
        desc_raw   = row[COL_DESC   - 1]
        parcel_val = row[COL_PARCEL - 1]
        amount_val = row[COL_AMOUNT - 1]

        if date_val is None and desc_raw is None and amount_val is None:
            continue

        # Date — already a datetime object from openpyxl
        if isinstance(date_val, datetime):
            txn_date = date_val.date()
        elif isinstance(date_val, date):
            txn_date = date_val
        else:
            continue

        if not desc_raw:
            continue
        desc_raw = str(desc_raw).strip()

        # Silent filter
        if any(k.lower() in desc_raw.lower() for k in CSV_SKIP):
            silent += 1
            continue

        # Amount — already a float; positive = expense, negative = refund/payment
        if amount_val is None:
            continue
        try:
            amount = Decimal(str(amount_val))
        except InvalidOperation:
            continue

        if amount == 0:
            continue

        # Parcel info from dedicated column (e.g. "2/12")
        pnum: Optional[int] = None
        ptotal: Optional[int] = None
        if parcel_val is not None:
            parts = str(parcel_val).strip().split('/')
            if len(parts) == 2:
                try:
                    pn, pt = int(parts[0]), int(parts[1])
                    if 1 <= pn <= pt:
                        pnum, ptotal = pn, pt
                except (ValueError, TypeError):
                    pass

        parcel_display = f"{pnum}/{ptotal}" if pnum else ""
        raw_parts = [txn_date.isoformat(), desc_raw]
        if parcel_display:
            raw_parts.append(parcel_display)
        raw_parts.append(f"{float(amount):.2f}")
        raw_line = " | ".join(raw_parts)

        is_micro = abs(amount) < MICRO_THRESHOLD

        txns.append(FileTxn(
            txn_date=txn_date,
            description=desc_raw,
            amount=amount,
            raw_line=raw_line,
            parcel_num=pnum,
            parcel_total=ptotal,
            is_micro=is_micro,
        ))

    return txns, silent


# ── Matching engine ───────────────────────────────────────────────────────────
def match_transactions(
    db: Session,
    txns: List[FileTxn],
    payment_method_id: int,
    audit_month: Optional[str] = None,   # "YYYY-MM"
) -> AuditResult:
    """
    Classify each file transaction as matched / ambiguous / unmatched
    against DB expenses for the given payment_method_id.

    audit_month scoping:
      - Single expenses:     expense_date must be in the selected month
      - Installment expenses: at least one split.due_date must be in the month;
                              only the matching split is used for amount/date comparison
    """
    result = AuditResult()

    filt_year = filt_month = None
    if audit_month:
        try:
            filt_year, filt_month = int(audit_month[:4]), int(audit_month[5:7])
        except (ValueError, IndexError):
            pass

    # ── Load single (non-installment) expenses filtered by month ─────────────
    q_single = db.query(Expense).filter(
        Expense.payment_method_id == payment_method_id,
        Expense.installments == 1,
    )
    if filt_year:
        q_single = q_single.filter(
            extract('year',  Expense.expense_date) == filt_year,
            extract('month', Expense.expense_date) == filt_month,
        )
    single_expenses: List[Expense] = q_single.all()

    # ── Load installment expenses that have a split due in the month ──────────
    q_inst = db.query(Expense).filter(
        Expense.payment_method_id == payment_method_id,
        Expense.installments > 1,
    )
    if filt_year:
        # Filtra no SQL: só expenses com parcela vencendo no mês auditado
        month_split_ids = db.query(ExpenseSplit.expense_id).filter(
            extract('year',  ExpenseSplit.due_date) == filt_year,
            extract('month', ExpenseSplit.due_date) == filt_month,
        ).distinct().subquery()
        q_inst = q_inst.filter(Expense.id.in_(month_split_ids))
    inst_expenses: List[Expense] = q_inst.all()

    # Pre-load ALL splits for installment expenses
    inst_ids = [e.id for e in inst_expenses]
    splits_by_exp: Dict[int, List[ExpenseSplit]] = defaultdict(list)
    if inst_ids:
        for s in (db.query(ExpenseSplit)
                    .filter(ExpenseSplit.expense_id.in_(inst_ids))
                    .all()):
            splits_by_exp[s.expense_id].append(s)

    # For installments: keep only expenses that have ≥1 split due in the month.
    # Also build a lookup: exp_id → split for that month (the "active" split).
    active_split_by_exp: Dict[int, ExpenseSplit] = {}
    filtered_inst: List[Expense] = []
    for exp in inst_expenses:
        if filt_year:
            month_splits = [
                s for s in splits_by_exp.get(exp.id, [])
                if s.due_date.year == filt_year and s.due_date.month == filt_month
            ]
            if not month_splits:
                continue
            # Use the first matching split as the active one for this month
            active_split_by_exp[exp.id] = month_splits[0]
        filtered_inst.append(exp)

    expenses: List[Expense] = single_expenses + filtered_inst

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

            exp_amt     = float(exp.total_amount)
            display_amt = exp_amt
            amount_ok   = False
            ref_date    = exp.expense_date   # date used for proximity ranking

            if exp.installments > 1:
                # ── Installment expense ───────────────────────────────────
                # Priority 1: explicit parcel suffix match (e.g. 02/12 in CSV)
                is_parcel_match = (
                    txn.parcel_num and txn.parcel_total
                    and exp.installments == txn.parcel_total
                )
                if is_parcel_match:
                    sp = next((s for s in splits_by_exp.get(exp.id, [])
                               if s.installment_number == txn.parcel_num), None)
                    if sp and abs(float(sp.installment_amount) - file_amount) <= 0.01:
                        amount_ok   = True
                        display_amt = float(sp.installment_amount)
                        ref_date    = sp.due_date

                # Priority 2: use the active split for this month
                if not amount_ok:
                    active = active_split_by_exp.get(exp.id)
                    if active and abs(float(active.installment_amount) - file_amount) <= 0.01:
                        amount_ok   = True
                        display_amt = float(active.installment_amount)
                        ref_date    = active.due_date
            else:
                # ── Single expense ────────────────────────────────────────
                if exp_amt > 0 and abs(exp_amt - file_amount) <= 0.01:
                    amount_ok = True

            if not amount_ok:
                continue

            # ── Date proximity (soft signal only) ─────────────────────────
            days_diff = abs((txn.txn_date - ref_date).days)
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

    # ── Surplus: DB expenses not matched to any file transaction ─────────────
    for exp in expenses:
        if exp.id in used_ids:
            continue
        display_amt = float(exp.total_amount)
        if exp.installments > 1 and exp.id in active_split_by_exp:
            display_amt = float(active_split_by_exp[exp.id].installment_amount)
        result.surplus.append(_exp_dict(exp, display_amt))

    return result
