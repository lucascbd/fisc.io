#!/usr/bin/env python3
"""
Gera expense_splits para despesas que não possuem splits.
Execute na pasta backend com o venv ativo:
    cd /opt/budget-system/backend
    python generate_missing_splits.py

Flags:
    --dry-run   Mostra o que seria feito sem gravar nada
    --ids 1,2,3 Processa apenas essas despesas específicas
"""

import sys
import argparse
from decimal import Decimal, ROUND_HALF_UP
from dateutil.relativedelta import relativedelta

# Adicionar o diretório ao path para importar os módulos do projeto
sys.path.insert(0, '.')

from database import SessionLocal
from models import Expense, ExpenseSplit, SplitProfileUser

def generate_splits_for_expense(db, expense, dry_run=False):
    total_amount     = Decimal(str(expense.total_amount))
    installments     = expense.installments or 1
    expense_date     = expense.expense_date
    paid_by_user_id  = expense.paid_by_user_id
    split_profile_id = expense.split_profile_id

    profile_users = db.query(SplitProfileUser).filter(
        SplitProfileUser.profile_id == split_profile_id
    ).all()

    if not profile_users:
        print(f"  ⚠️  Expense {expense.id}: perfil {split_profile_id} sem usuários — pulando")
        return 0

    total_pct = sum(Decimal(str(pu.percentage)) for pu in profile_users)
    if not (Decimal('0.9999') <= total_pct <= Decimal('1.0001')):
        print(f"  ⚠️  Expense {expense.id}: percentuais somam {total_pct*100:.2f}% — pulando")
        return 0

    installment_amount = (total_amount / Decimal(str(installments))).quantize(
        Decimal('0.01'), rounding=ROUND_HALF_UP
    )
    ajuste_ultima = total_amount - installment_amount * Decimal(str(installments))

    created = 0
    for inst_num in range(1, installments + 1):
        due_date = expense_date + relativedelta(months=inst_num - 1)
        inst_amt = installment_amount + ajuste_ultima if inst_num == installments else installment_amount

        allocated = Decimal('0')
        for idx, pu in enumerate(profile_users):
            pct = Decimal(str(pu.percentage))
            if idx == len(profile_users) - 1:
                user_amount = inst_amt - allocated
            else:
                user_amount = (inst_amt * pct).quantize(Decimal('0.01'), rounding=ROUND_HALF_UP)
                allocated += user_amount

            paid_amount = inst_amt if pu.user_id == paid_by_user_id else Decimal('0')
            balance     = paid_amount - user_amount

            if not dry_run:
                db.add(ExpenseSplit(
                    expense_id         = expense.id,
                    user_id            = pu.user_id,
                    installment_number = inst_num,
                    due_date           = due_date,
                    installment_amount = inst_amt,
                    user_amount        = user_amount,
                    user_percentage    = pct,
                    paid_amount        = paid_amount,
                    balance            = balance,
                ))
            created += 1

    return created

def main():
    parser = argparse.ArgumentParser(description='Gera splits para despesas sem splits')
    parser.add_argument('--dry-run', action='store_true', help='Apenas mostra, não grava')
    parser.add_argument('--ids', type=str, default='', help='IDs específicos separados por vírgula')
    args = parser.parse_args()

    db = SessionLocal()
    try:
        # Buscar despesas sem splits
        if args.ids:
            id_list = [int(x.strip()) for x in args.ids.split(',')]
            expenses_without_splits = (
                db.query(Expense)
                .filter(Expense.id.in_(id_list))
                .outerjoin(ExpenseSplit, Expense.id == ExpenseSplit.expense_id)
                .filter(ExpenseSplit.id == None)
                .all()
            )
            # Despesas com split já existente nos ids especificados
            all_specified = db.query(Expense).filter(Expense.id.in_(id_list)).all()
            with_splits = [e for e in all_specified if e not in expenses_without_splits]
            if with_splits:
                print(f"ℹ️  Despesas já com splits (puladas): {[e.id for e in with_splits]}")
        else:
            from sqlalchemy import not_, exists
            expenses_without_splits = (
                db.query(Expense)
                .filter(
                    ~exists().where(ExpenseSplit.expense_id == Expense.id)
                )
                .order_by(Expense.id)
                .all()
            )

        if not expenses_without_splits:
            print("✅ Nenhuma despesa sem splits encontrada.")
            return

        print(f"{'[DRY RUN] ' if args.dry_run else ''}Encontradas {len(expenses_without_splits)} despesas sem splits:\n")

        total_splits = 0
        for expense in expenses_without_splits:
            n = generate_splits_for_expense(db, expense, dry_run=args.dry_run)
            print(f"  {'→' if args.dry_run else '✓'} Expense {expense.id} | {expense.description!r} | "
                  f"R$ {expense.total_amount} | {expense.installments}x | "
                  f"perfil {expense.split_profile_id} → {n} splits")
            total_splits += n

        if not args.dry_run:
            db.commit()
            print(f"\n✅ {total_splits} splits gravados para {len(expenses_without_splits)} despesas.")
        else:
            print(f"\n[DRY RUN] Seriam criados {total_splits} splits para {len(expenses_without_splits)} despesas.")

    except Exception as e:
        db.rollback()
        print(f"❌ Erro: {e}")
        raise
    finally:
        db.close()

if __name__ == '__main__':
    main()
