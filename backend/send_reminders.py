#!/usr/bin/env python3
"""
Script de Lembretes Mensais - SplitMate
Envia notificações personalizadas na primeira segunda-feira de cada mês

Uso via cron (rodar a cada hora para respeitar horários individuais):
0 * * * * /opt/budget-system/backend/venv/bin/python /opt/budget-system/backend/send_reminders.py

Ou rodar manualmente para testar:
python send_reminders.py --test
python send_reminders.py --force  # Ignora verificação de primeira segunda-feira
"""

import sys
import os
from datetime import datetime, date
from decimal import Decimal
from calendar import monthrange
import argparse

# Adicionar path do backend e mudar para o diretório (para encontrar .env)
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.chdir(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import create_engine, func, extract
from sqlalchemy.orm import sessionmaker
from config import settings
from models import User, ExpenseSplit, NotificationPreferences, DeviceToken
from firebase_service import FirebaseService


def is_first_day_of_month():
    """Verifica se hoje é o primeiro dia do mês"""
    return date.today().day == 1


def get_current_hour_str():
    """Retorna hora e minuto atual no formato HH:MM"""
    return datetime.now().strftime('%H:%M')


def calculate_user_balances(db, month=None):
    """
    Calcula o balanço de cada usuário
    
    Retorna dict:
    {
        user_id: {
            'name': 'Nome',
            'balance': Decimal,  # positivo = tem a receber, negativo = deve
        }
    }
    """
    if month is None:
        # Usar mês anterior (lembrete é sobre o mês que passou)
        today = date.today()
        if today.month == 1:
            year = today.year - 1
            mon = 12
        else:
            year = today.year
            mon = today.month - 1
    else:
        year, mon = map(int, month.split('-'))
    
    users = db.query(User).filter(User.is_active == True).all()

    # 1 query com GROUP BY em vez de 1 query por usuário
    rows = db.query(
        ExpenseSplit.user_id,
        func.coalesce(func.sum(ExpenseSplit.balance), 0).label('balance')
    ).filter(
        extract('year', ExpenseSplit.due_date) == year,
        extract('month', ExpenseSplit.due_date) == mon
    ).group_by(ExpenseSplit.user_id).all()
    balance_by_user = {r.user_id: Decimal(str(r.balance)) for r in rows}

    balances = {}
    for user in users:
        balances[user.id] = {
            'name': user.name,
            'balance': balance_by_user.get(user.id, Decimal('0'))
        }

    return balances, f"{year}-{mon:02d}"


def generate_reminder_message(user_id, user_name, balances):
    """
    Gera mensagem personalizada baseada no balanço
    
    Se o usuário DEVE dinheiro (balance negativo):
        "📆 Fechamento do mês: R$ X a pagar"
    Se o usuário TEM A RECEBER (balance positivo):
        "📆 Fechamento do mês: R$ X a receber"
    """
    user_balance = balances.get(user_id, {}).get('balance', Decimal('0'))
    
    if user_balance == 0:
        return None, None  # Sem pendências
    
    amount = abs(float(user_balance))
    
    if user_balance < 0:
        # Usuário DEVE dinheiro
        title = "🗓️ Fechamento do mês"
        body = f"R$ {amount:.2f} a pagar".replace('.', ',')
    else:
        # Usuário TEM A RECEBER
        title = "🗓️ Fechamento do mês"
        body = f"R$ {amount:.2f} a receber".replace('.', ',')
    
    return title, body


def send_reminders(db, force=False, test=False):
    """
    Envia lembretes para usuários que configuraram
    
    Args:
        db: Sessão do banco
        force: Ignora verificação de primeira segunda-feira
        test: Modo teste (não envia, só mostra)
    """
    # Verificar se é primeira segunda-feira (a menos que force=True)
    if not force and not is_first_day_of_month():
        print(f"ℹ️ Hoje não é o primeiro dia do mês. Use --force para ignorar.")
        return
    
    current_time = get_current_hour_str()
    print(f"🕐 Hora atual: {current_time}")

    # Buscar usuários com lembretes ativos
    prefs = db.query(NotificationPreferences).filter(
        NotificationPreferences.notify_reminders == True
    ).all()

    if not prefs:
        print("ℹ️ Nenhum usuário com lembretes ativados")
        return

    # Filtrar por horário exato HH:MM
    users_to_notify = []
    for p in prefs:
        user_time = p.reminder_time or "09:00"
        if user_time == current_time or force:
            users_to_notify.append(p.user_id)
            print(f"  ✓ Usuário {p.user_id} - horário {p.reminder_time} -> enviar")
        else:
            print(f"  ✗ Usuário {p.user_id} - horário {p.reminder_time} (atual: {current_time}) -> pular")
    
    if not users_to_notify:
        print("ℹ️ Nenhum usuário para notificar neste horário")
        return
    
    # Calcular balanços
    balances, month_label = calculate_user_balances(db)
    print(f"📊 Balanços calculados para {month_label}")
    
    for uid, data in balances.items():
        if data['balance'] != 0:
            print(f"  {data['name']}: R$ {float(data['balance']):.2f}")
    
    # Enviar notificações
    print(f"\n📤 Enviando lembretes...")
    
    for user_id in users_to_notify:
        user = db.query(User).filter(User.id == user_id).first()
        if not user:
            continue
        
        title, body = generate_reminder_message(user_id, user.name, balances)
        
        if not title:
            print(f"  ✓ {user.name}: Sem pendências, pulando")
            continue
        
        print(f"  → {user.name}: {title} - {body}")
        
        if test:
            print(f"    [TESTE] Não enviado")
            continue
        
        # Buscar tokens do usuário
        tokens = db.query(DeviceToken).filter(
            DeviceToken.user_id == user_id
        ).all()
        
        if not tokens:
            print(f"    ⚠️ Sem tokens registrados")
            continue
        
        token_list = [t.token for t in tokens]
        
        result = FirebaseService.send_push(
            tokens=token_list,
            title=title,
            body=body,
            data={"action": "monthly_reminder", "month": month_label},
            db=db
        )
        
        print(f"    ✅ Enviado: {result.get('success_count', 0)} sucesso, {result.get('failure_count', 0)} falhas")


def main():
    parser = argparse.ArgumentParser(description='Enviar lembretes mensais do SplitMate')
    parser.add_argument('--test', action='store_true', help='Modo teste (não envia notificações)')
    parser.add_argument('--force', action='store_true', help='Ignora verificação de primeira segunda-feira')
    args = parser.parse_args()
    
    print("=" * 60)
    print(f"🔔 SplitMate - Lembretes Mensais")
    print(f"📅 Data: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 60)
    
    # Inicializar Firebase
    try:
        FirebaseService.initialize(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'firebase-credentials.json'))
        print("✅ Firebase inicializado")
    except Exception as e:
        print(f"⚠️ Firebase já inicializado ou erro: {e}")
    
    # Conectar ao banco
    engine = create_engine(settings.DATABASE_URL)
    SessionLocal = sessionmaker(bind=engine)
    db = SessionLocal()
    
    try:
        send_reminders(db, force=args.force, test=args.test)
    finally:
        db.close()
    
    print("\n✅ Concluído!")


if __name__ == "__main__":
    main()
