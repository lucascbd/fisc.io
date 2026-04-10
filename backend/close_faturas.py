#!/usr/bin/env python3
"""
Script de Fechamento de Faturas - SplitMate
Atualiza is_closed nos cartões de crédito com base na data de fechamento calculada.

Lógica: se hoje > closing (vencimento - 7 dias), a fatura está fechada.
        Ao virar o mês (dia 1), todos os cartões voltam para is_closed=False.

Uso via cron (rodar todo dia à meia-noite):
0 0 * * * /opt/budget-system/backend/venv/bin/python /opt/budget-system/backend/close_faturas.py

Ou rodar manualmente:
python close_faturas.py           # processa a data de hoje
python close_faturas.py --dry-run # simula sem salvar
"""

import sys
import os
import argparse
from datetime import date, timedelta
import calendar

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.chdir(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from config import settings
from models import PaymentMethod


def _is_fatura_closed(pm: PaymentMethod, today: date) -> bool:
    """
    Retorna True se a fatura do cartão deve estar fechada hoje.
    Usa a mesma lógica de _shift_card_date: closing = próximo vencimento - 7 dias.
    """
    if not (pm.is_card and pm.due_day):
        return False
    due_day = pm.due_day
    if today.month == 12:
        next_due = today.replace(year=today.year + 1, month=1, day=due_day)
    else:
        max_next = calendar.monthrange(today.year, today.month + 1)[1]
        next_due = today.replace(month=today.month + 1, day=min(due_day, max_next))
    closing = next_due - timedelta(days=7)
    return today > closing


def update_faturas(db, today: date, dry_run: bool = False):
    """
    Atualiza is_closed para todos os cartões do sistema.
    """
    cards = db.query(PaymentMethod).filter(PaymentMethod.is_card == True).all()

    if not cards:
        print("ℹ️  Nenhum cartão cadastrado.")
        return 0, 0

    updated = 0
    unchanged = 0

    for pm in cards:
        should_be_closed = _is_fatura_closed(pm, today)
        current_state = bool(pm.is_closed) if pm.is_closed is not None else False

        if current_state == should_be_closed:
            unchanged += 1
            continue

        state_str = "FECHADA" if should_be_closed else "ABERTA"
        print(f"  {'[DRY-RUN] ' if dry_run else ''}{'🔒' if should_be_closed else '🔓'}  {pm.description} → {state_str}")

        if not dry_run:
            pm.is_closed = should_be_closed

        updated += 1

    if not dry_run and updated > 0:
        db.commit()

    return updated, unchanged


def main():
    parser = argparse.ArgumentParser(description='Atualizar fechamento de faturas do SplitMate')
    parser.add_argument('--dry-run', action='store_true', help='Simula sem salvar no banco')
    args = parser.parse_args()

    today = date.today()

    print("=" * 60)
    print(f"💳  SplitMate — Fechamento de Faturas")
    print(f"📅  Data: {today.isoformat()}")
    if args.dry_run:
        print("⚠️   MODO DRY-RUN — nada será salvo")
    print("=" * 60)

    engine = create_engine(settings.DATABASE_URL)
    SessionLocal = sessionmaker(bind=engine)
    db = SessionLocal()

    try:
        updated, unchanged = update_faturas(db, today, dry_run=args.dry_run)
    finally:
        db.close()

    print("-" * 60)
    if args.dry_run:
        print(f"✅  Simulação: {updated} alterariam, {unchanged} sem mudança.")
    else:
        print(f"✅  Concluído: {updated} atualizados, {unchanged} sem mudança.")


if __name__ == "__main__":
    main()
