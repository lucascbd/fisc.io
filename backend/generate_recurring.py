#!/usr/bin/env python3
"""
Script de Despesas Recorrentes - SplitMate
Gera as despesas recorrentes do mês atual caso ainda não tenham sido geradas.

Uso via cron (rodar todo dia às 00:00):
0 0 * * * /opt/budget-system/backend/venv/bin/python /opt/budget-system/backend/generate_recurring.py

Ou rodar manualmente:
python generate_recurring.py           # gera o mês atual
python generate_recurring.py --dry-run # mostra o que seria gerado sem salvar
python generate_recurring.py --force   # regera mesmo que já tenha sido gerado este mês
"""

import sys
import os
import argparse
from datetime import datetime, date
from decimal import Decimal

sys.path.insert(0, '/opt/budget-system/backend')
os.chdir('/opt/budget-system/backend')

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from config import settings
from models import RecurringExpense
from expense_service import ExpenseService


def generate_for_month(db, target_date: date, dry_run: bool = False, force: bool = False):
    """
    Gera as despesas recorrentes para o mês de target_date.
    Idempotente: pula templates cujo last_generated_month já é YYYY-MM do target_date.
    """
    current_month_str = target_date.strftime("%Y-%m")
    expense_date = target_date.replace(day=1)

    items = db.query(RecurringExpense).filter(RecurringExpense.is_active == True).all()

    if not items:
        print("ℹ️  Nenhuma despesa recorrente cadastrada.")
        return 0, 0

    generated = 0
    skipped = 0

    for r in items:
        if not force and r.last_generated_month == current_month_str:
            print(f"  ↷  Já gerada em {current_month_str}: {r.description}")
            skipped += 1
            continue

        print(f"  {'[DRY-RUN] ' if dry_run else ''}✓  {r.description} — R$ {float(r.total_amount):.2f}")

        if not dry_run:
            ExpenseService.create_expense(
                db=db,
                description=r.description,
                total_amount=Decimal(str(r.total_amount)),
                category_id=r.category_id,
                split_profile_id=r.split_profile_id,
                paid_by_user_id=r.paid_by_user_id,
                expense_date=expense_date,
                installments=1,
                notes=r.notes,
                payment_method=r.payment_method,
                created_by_user_id=r.created_by_user_id,
            )
            r.last_generated_month = current_month_str

        generated += 1

    if not dry_run and generated > 0:
        db.commit()

    return generated, skipped


def main():
    parser = argparse.ArgumentParser(description='Gerar despesas recorrentes do SplitMate')
    parser.add_argument('--dry-run', action='store_true', help='Simula sem salvar no banco')
    parser.add_argument('--force',   action='store_true', help='Regera mesmo que já tenha sido gerado este mês')
    args = parser.parse_args()

    today = date.today()

    print("=" * 60)
    print(f"🔁  SplitMate — Despesas Recorrentes")
    print(f"📅  Data: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"📆  Mês alvo: {today.strftime('%Y-%m')}")
    if args.dry_run: print("⚠️   MODO DRY-RUN — nada será salvo")
    if args.force:   print("⚠️   MODO FORCE — regera independente do histórico")
    print("=" * 60)

    engine = create_engine(settings.DATABASE_URL)
    SessionLocal = sessionmaker(bind=engine)
    db = SessionLocal()

    try:
        generated, skipped = generate_for_month(db, today, dry_run=args.dry_run, force=args.force)
    finally:
        db.close()

    print("-" * 60)
    if args.dry_run:
        print(f"✅  Simulação: {generated} seriam geradas, {skipped} puladas.")
    else:
        print(f"✅  Concluído: {generated} geradas, {skipped} puladas.")


if __name__ == "__main__":
    main()
