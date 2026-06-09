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
from datetime import datetime, date, timedelta
import calendar
from decimal import Decimal

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.chdir(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from config import settings
from models import RecurringExpense, PaymentMethod
from expense_service import ExpenseService


def _shift_card_date(expense_date: date, pm) -> date:
    """If expense date is past the card closing window, shift to next billing month."""
    if not (pm and pm.is_card and pm.due_day):
        return expense_date
    due_day = pm.due_day
    if expense_date.month == 12:
        next_due = expense_date.replace(year=expense_date.year + 1, month=1, day=due_day)
    else:
        max_next = calendar.monthrange(expense_date.year, expense_date.month + 1)[1]
        next_due = expense_date.replace(month=expense_date.month + 1, day=min(due_day, max_next))
    closing = next_due - timedelta(days=7)
    if expense_date > closing:
        max_day = calendar.monthrange(next_due.year, next_due.month)[1]
        return expense_date.replace(year=next_due.year, month=next_due.month, day=min(expense_date.day, max_day))
    return expense_date


def generate_for_month(db, target_date: date, dry_run: bool = False, force: bool = False):
    """
    Gera as despesas recorrentes para o mês de target_date.
    Idempotente: pula templates cujo last_generated_month já é YYYY-MM do target_date.
    """
    current_month_str = target_date.strftime("%Y-%m")

    items = db.query(RecurringExpense).filter(
        RecurringExpense.is_active == True,
        RecurringExpense.is_enabled != False,
    ).all()

    if not items:
        print("ℹ️  Nenhuma despesa recorrente cadastrada.")
        return 0, 0

    generated = 0
    skipped = 0

    for r in items:
        interval = float(r.interval) if r.interval is not None else 0.0

        # Verificar se deve gerar neste mês com base no interval
        if not force:
            if r.last_generated_month is None:
                should_generate = True
            elif interval == 0.0:
                # Mensal: gera todo mês
                should_generate = r.last_generated_month != current_month_str
            elif interval == 0.5:
                # A cada 45 dias: calcula pela data do último insert_day no last_generated_month
                last_yr, last_mn = map(int, r.last_generated_month.split('-'))
                last_day = min(r.insert_day or 1, calendar.monthrange(last_yr, last_mn)[1])
                last_gen_date = date(last_yr, last_mn, last_day)
                should_generate = target_date >= last_gen_date + timedelta(days=45)
            else:
                # Pula N meses inteiros: gera quando diff >= N+1
                last_yr, last_mn = map(int, r.last_generated_month.split('-'))
                months_diff = (target_date.year - last_yr) * 12 + (target_date.month - last_mn)
                should_generate = months_diff > interval
        else:
            should_generate = True

        if not should_generate:
            print(f"  ↷  Pulada (interval={interval}): {r.description}")
            skipped += 1
            continue

        print(f"  {'[DRY-RUN] ' if dry_run else ''}✓  {r.description} — R$ {float(r.total_amount):.2f}")

        if not dry_run:
            insert_day = max(1, min(31, r.insert_day or 1))
            last_day = calendar.monthrange(target_date.year, target_date.month)[1]
            real_date = target_date.replace(day=min(insert_day, last_day))
            pm = db.query(PaymentMethod).filter(PaymentMethod.id == r.payment_method_id).first() if r.payment_method_id else None
            expense_date = _shift_card_date(real_date, pm)
            exp = ExpenseService.create_expense(
                db=db,
                description=r.description,
                total_amount=Decimal(str(r.total_amount)),
                category_id=r.category_id,
                split_profile_id=r.split_profile_id,
                paid_by_user_id=r.paid_by_user_id,
                expense_date=expense_date,
                original_date=real_date,
                installments=1,
                notes=r.notes,
                payment_method_id=r.payment_method_id,
                created_by_user_id=r.created_by_user_id,
            )
            if exp:
                exp.is_recurring = True
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
