"""
Audit service: reconcile bank CSV/OFX files against DB expenses.

Supported formats:
  - CSV: data,lançamento,valor  (credit card export)
  - OFX: SGML format            (checking account export)
"""
import re
import io
import csv
import unicodedata
from datetime import date
from decimal import Decimal
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
SIM_AMBIGUOUS    = 0.38              # similarity below this → discard candidate
DATE_WINDOW_REG  = 7                 # days tolerance for regular expenses
DATE_WINDOW_PAR  = 35                # days tolerance for installment parcels

# OFX: MEMO patterns to silently skip (investment/internal transactions)
OFX_SKIP = [
    'REND PAGO APLIC AUT MAIS',
    'APLICACAO CDB DI',
    'RESGATE CDB DI',
    'ITAU BLACK',          # credit card bill payment from checking
    'CREDITO LIBERAD',     # internal PIX card credit rebate
    'PIX ORIGEM CARTAO',   # internal PIX card credit rebate
]

# CSV: description patterns to silently skip
CSV_SKIP = [
    'PAGAMENTO EFETUADO',
]

# ── Parcel regex: NN/NN at end of description ─────────────────────────────────
_PARCEL_RE = re.compile(r'\s*(\d{2})/(\d{2})$')


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
    # Sanity check: parcel number ≤ total and both > 0
    if num < 1 or total < 1 or num > total:
        return desc.strip(), None, None
    return desc[:m.start()].strip(), num, total


def _txn_dict(txn: FileTxn) -> dict:
    return {
        'date':        txn.txn_date.isoformat(),
        'description': txn.description,
        'amount':      float(txn.amount),
        'raw_line':    txn.raw_line,
        'parcel_num':  txn.parcel_num,
        'parcel_total':txn.parcel_total,
    }


def _exp_dict(exp: Expense) -> dict:
    return {
        'id':               exp.id,
        'description':      exp.description,
        'total_amount':     float(exp.total_amount),
        'expense_date':     exp.expense_date.isoformat(),
        'installments':     exp.installments,
        'category_id':      exp.category_id,
        'split_profile_id': exp.split_profile_id,
        'paid_by_user_id':  exp.paid_by_user_id,
    }


# ── CSV parser ────────────────────────────────────────────────────────────────
def parse_csv(content: str) -> Tuple[List[FileTxn], int]:
    """Parse credit card CSV (data,lançamento,valor)."""
    txns: List[FileTxn] = []
    silent = 0

    reader = csv.DictReader(io.StringIO(content))
    for row in reader:
        # Normalize field names (handles 'lançamento' with accent)
        row_n = {_strip_accents(k).lower().strip(): v.strip() for k, v in row.items()}
        desc_raw = row_n.get('lancamento', '')
        date_str = row_n.get('data', '')
        val_str  = row_n.get('valor', '')

        if not desc_raw or not date_str or not val_str:
            continue

        try:
            txn_date = date.fromisoformat(date_str)
        except ValueError:
            continue

        try:
            amount = Decimal(val_str.replace(',', '.'))
        except Exception:
            continue

        # Silent filter
        if any(k.lower() in desc_raw.lower() for k in CSV_SKIP):
            silent += 1
            continue

        is_micro = abs(amount) < MICRO_THRESHOLD
        base, pnum, ptotal = _parse_parcel(desc_raw)

        txns.append(FileTxn(
            txn_date=txn_date, description=base, amount=amount,
            raw_line=f"{date_str},{desc_raw},{val_str}",
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

    blocks = re.findall(r'<STMTTRN>(.*?)</STMTTRN>', content, re.DOTALL)

    for block in blocks:
        memo     = _tag(block, 'MEMO')
        date_str = _tag(block, 'DTPOSTED')[:8]   # YYYYMMDD
        amt_str  = _tag(block, 'TRNAMT')
        fitid    = _tag(block, 'FITID')

        try:
            txn_date = date(int(date_str[:4]), int(date_str[4:6]), int(date_str[6:8]))
            ofx_amt  = Decimal(amt_str)
        except Exception:
            continue

        # Silent filter
        if any(k.lower() in memo.lower() for k in OFX_SKIP):
            silent += 1
            continue

        # OFX sign convention: DEBIT = negative (expense), CREDIT = positive (income)
        # We flip: expense = positive, income = negative
        expense_amount = -ofx_amt

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

    # Load all expenses for this PM
    expenses: List[Expense] = (
        db.query(Expense)
        .filter(Expense.payment_method_id == payment_method_id)
        .all()
    )

    # Pre-load splits only for installment expenses (avoid N+1)
    inst_ids = [e.id for e in expenses if e.installments > 1]
    splits_by_exp: Dict[int, List[ExpenseSplit]] = defaultdict(list)
    if inst_ids:
        for s in (db.query(ExpenseSplit)
                    .filter(ExpenseSplit.expense_id.in_(inst_ids))
                    .all()):
            splits_by_exp[s.expense_id].append(s)

    # Parcel cache: (norm_base_desc, parcel_total) → expense_id
    # When parcel N/M is auto-matched, subsequent parcels skip scoring
    parcel_cache: Dict[Tuple[str, int], int] = {}
    used_ids: set = set()    # prevent double-matching same DB expense

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

            # ── Amount check ──────────────────────────────────────────────
            is_parcel_match = (
                txn.parcel_num and txn.parcel_total
                and exp.installments == txn.parcel_total
            )

            if is_parcel_match:
                splits = splits_by_exp.get(exp.id, [])
                sp = next((s for s in splits
                           if s.installment_number == txn.parcel_num), None)
                if not sp:
                    continue
                if abs(float(sp.installment_amount) - file_amount) > 0.02:
                    continue
                # Date window: purchase_date + (parcel_num-1) months ≈ txn_date
                expected = exp.expense_date + relativedelta(months=txn.parcel_num - 1)
                date_ok = abs((txn.txn_date - expected).days) <= DATE_WINDOW_PAR
            else:
                exp_amt = float(exp.total_amount)
                if exp_amt <= 0:
                    continue
                if abs(exp_amt - file_amount) / exp_amt > 0.02:
                    continue
                date_ok = abs((txn.txn_date - exp.expense_date).days) <= DATE_WINDOW_REG

            # ── Similarity ────────────────────────────────────────────────
            sim = _sim(txn.description, exp.description)
            if sim < SIM_AMBIGUOUS:
                continue

            candidates.append({
                'expense':    _exp_dict(exp),
                'similarity': round(sim, 2),
                'date_ok':    date_ok,
            })

        # Sort: date_ok first, then similarity descending
        candidates.sort(key=lambda x: (x['date_ok'], x['similarity']), reverse=True)

        # ── Classify ──────────────────────────────────────────────────────
        if not candidates:
            result.unmatched.append({'file': _txn_dict(txn)})

        elif (candidates[0]['similarity'] >= SIM_AUTO_MATCH
              and candidates[0]['date_ok']):
            best = candidates[0]
            exp_id = best['expense']['id']
            used_ids.add(exp_id)
            # Populate parcel cache for subsequent parcels
            if txn.parcel_num and txn.parcel_total:
                cache_key = (_normalize(txn.description), txn.parcel_total)
                parcel_cache[cache_key] = exp_id
            result.matched.append({
                'file':    _txn_dict(txn),
                'expense': best['expense'],
                'reason':  f"sim={best['similarity']:.0%}",
            })

        else:
            # Multiple candidates, low similarity, or date mismatch → ambiguous
            result.ambiguous.append({
                'file':       _txn_dict(txn),
                'candidates': candidates[:5],
            })

    return result
