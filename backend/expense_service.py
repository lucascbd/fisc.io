"""Expense business logic"""
from sqlalchemy.orm import Session
from sqlalchemy import func
from decimal import Decimal, ROUND_HALF_UP
from datetime import date
from dateutil.relativedelta import relativedelta
from typing import Optional

from models import Expense, ExpenseSplit, SplitProfileUser, User
from database import SessionLocal

class ExpenseService:
    
    @staticmethod
    def create_expense(
        db: Session,
        paid_by_user_id: int,
        category_id: int,
        split_profile_id: int,
        description: str,
        total_amount: Decimal,
        expense_date: date,
        installments: int = 1,
        notes: Optional[str] = None,
        created_by_user_id: Optional[int] = None,
        payment_method: Optional[str] = 'pix',
        original_date: Optional[date] = None
    ) -> Expense:
        """Create expense with automatic splitting"""
        
        # Create expense
        expense = Expense(
            description=description,
            total_amount=total_amount,
            installments=installments,
            expense_date=expense_date,
            paid_by_user_id=paid_by_user_id,
            category_id=category_id,
            split_profile_id=split_profile_id,
            notes=notes,
            payment_method=payment_method or 'pix',
            original_date=original_date or expense_date,
            created_by_user_id=created_by_user_id or paid_by_user_id
        )
        
        db.add(expense)
        db.flush()
        
        # Get split profile users
        profile_users = db.query(SplitProfileUser).filter(
            SplitProfileUser.profile_id == split_profile_id
        ).all()
        
        if not profile_users:
            raise ValueError("Split profile has no users")
        
        # Validate percentages sum to 1
        total_percentage = sum(Decimal(str(pu.percentage)) for pu in profile_users)
        if not (Decimal('0.9999') <= total_percentage <= Decimal('1.0001')):
            raise ValueError(f"Percentages must sum to 100% (got {total_percentage * 100}%)")
        
        # Calculate installment amount with proper rounding
        # Arredonda para 2 casas decimais e ajusta centavos na última parcela
        installment_amount_raw = total_amount / Decimal(str(installments))
        installment_amount = installment_amount_raw.quantize(Decimal('0.01'), rounding=ROUND_HALF_UP)
        
        # Calcular ajuste para última parcela (evitar centavos perdidos)
        # Exemplo: 20/3 = 6.67 * 3 = 20.01, ajuste = -0.01
        total_parcelas = installment_amount * Decimal(str(installments))
        ajuste_ultima_parcela = total_amount - total_parcelas
        
        # Create splits for each installment and user
        for inst_num in range(1, installments + 1):
            due_date = expense_date + relativedelta(months=inst_num - 1)
            
            # Aplica ajuste na última parcela
            if inst_num == installments:
                installment_amount_atual = installment_amount + ajuste_ultima_parcela
            else:
                installment_amount_atual = installment_amount
            
            profile_user_ids = {pu.user_id for pu in profile_users}

            allocated = Decimal('0')
            for idx, profile_user in enumerate(profile_users):
                user_percentage = Decimal(str(profile_user.percentage))
                if idx == len(profile_users) - 1:
                    # Last user absorbs cent difference so splits always sum exactly to installment
                    user_amount = installment_amount_atual - allocated
                else:
                    user_amount = (installment_amount_atual * user_percentage).quantize(Decimal('0.01'), rounding=ROUND_HALF_UP)
                    allocated += user_amount

                paid_amount = installment_amount_atual if profile_user.user_id == paid_by_user_id else Decimal('0')
                balance = paid_amount - user_amount

                split = ExpenseSplit(
                    expense_id=expense.id,
                    user_id=profile_user.user_id,
                    installment_number=inst_num,
                    due_date=due_date,
                    installment_amount=installment_amount_atual,
                    user_amount=user_amount,
                    user_percentage=user_percentage,
                    paid_amount=paid_amount,
                    balance=balance
                )
                db.add(split)

            # Se o pagador não está no perfil, criar split extra para registrar o crédito dele
            if paid_by_user_id not in profile_user_ids:
                payer_split = ExpenseSplit(
                    expense_id=expense.id,
                    user_id=paid_by_user_id,
                    installment_number=inst_num,
                    due_date=due_date,
                    installment_amount=installment_amount_atual,
                    user_amount=Decimal('0'),
                    user_percentage=Decimal('0'),
                    paid_amount=installment_amount_atual,
                    balance=installment_amount_atual
                )
                db.add(payer_split)

        db.commit()
        db.refresh(expense)

        return expense

    @staticmethod
    def update_expense(
        db: Session,
        expense_id: int,
        paid_by_user_id: int,
        category_id: int,
        split_profile_id: int,
        description: str,
        total_amount: Decimal,
        expense_date: date,
        installments: int = 1,
        notes: Optional[str] = None,
        updated_by_user_id: Optional[int] = None,
        payment_method: Optional[str] = 'pix',
        original_date: Optional[date] = None
    ) -> Expense:
        """
        Update expense mantendo o ID original.
        Recria os splits apenas se necessário (valor, parcelas ou perfil mudaram).
        """
        expense = db.query(Expense).filter(Expense.id == expense_id).first()
        if not expense:
            raise ValueError("Expense not found")
        
        # Verificar se precisa recalcular splits
        needs_splits_recalc = (
            expense.total_amount != total_amount or
            expense.installments != installments or
            expense.split_profile_id != split_profile_id or
            expense.expense_date != expense_date
        )
        
        # Atualizar campos da despesa
        expense.description = description
        expense.total_amount = total_amount
        expense.installments = installments
        expense.expense_date = expense_date
        expense.paid_by_user_id = paid_by_user_id
        expense.category_id = category_id
        expense.split_profile_id = split_profile_id
        expense.notes = notes
        expense.payment_method = payment_method or 'pix'
        expense.original_date = original_date or expense_date
        
        if needs_splits_recalc:
            # Deletar splits antigos
            db.query(ExpenseSplit).filter(ExpenseSplit.expense_id == expense_id).delete()
            
            # Recriar splits
            profile_users = db.query(SplitProfileUser).filter(
                SplitProfileUser.profile_id == split_profile_id
            ).all()
            
            if not profile_users:
                raise ValueError("Split profile has no users")
            
            # Validate percentages sum to 1
            total_percentage = sum(Decimal(str(pu.percentage)) for pu in profile_users)
            if not (Decimal('0.9999') <= total_percentage <= Decimal('1.0001')):
                raise ValueError(f"Percentages must sum to 100% (got {total_percentage * 100}%)")
            
            # Calculate installment amount with proper rounding
            installment_amount_raw = total_amount / Decimal(str(installments))
            installment_amount = installment_amount_raw.quantize(Decimal('0.01'), rounding=ROUND_HALF_UP)
            
            # Calcular ajuste para última parcela
            total_parcelas = installment_amount * Decimal(str(installments))
            ajuste_ultima_parcela = total_amount - total_parcelas
            
            # Create splits for each installment and user
            for inst_num in range(1, installments + 1):
                due_date = expense_date + relativedelta(months=inst_num - 1)
                
                # Aplica ajuste na última parcela
                if inst_num == installments:
                    installment_amount_atual = installment_amount + ajuste_ultima_parcela
                else:
                    installment_amount_atual = installment_amount
                
                profile_user_ids = {pu.user_id for pu in profile_users}

                allocated = Decimal('0')
                for idx, profile_user in enumerate(profile_users):
                    user_percentage = Decimal(str(profile_user.percentage))
                    if idx == len(profile_users) - 1:
                        user_amount = installment_amount_atual - allocated
                    else:
                        user_amount = (installment_amount_atual * user_percentage).quantize(Decimal('0.01'), rounding=ROUND_HALF_UP)
                        allocated += user_amount

                    paid_amount = installment_amount_atual if profile_user.user_id == paid_by_user_id else Decimal('0')
                    balance = paid_amount - user_amount

                    split = ExpenseSplit(
                        expense_id=expense.id,
                        user_id=profile_user.user_id,
                        installment_number=inst_num,
                        due_date=due_date,
                        installment_amount=installment_amount_atual,
                        user_amount=user_amount,
                        user_percentage=user_percentage,
                        paid_amount=paid_amount,
                        balance=balance
                    )
                    db.add(split)

                # Se o pagador não está no perfil, criar split extra para registrar o crédito
                if paid_by_user_id not in profile_user_ids:
                    payer_split = ExpenseSplit(
                        expense_id=expense.id,
                        user_id=paid_by_user_id,
                        installment_number=inst_num,
                        due_date=due_date,
                        installment_amount=installment_amount_atual,
                        user_amount=Decimal('0'),
                        user_percentage=Decimal('0'),
                        paid_amount=installment_amount_atual,
                        balance=installment_amount_atual
                    )
                    db.add(payer_split)
        else:
            # Apenas atualizar paid_by nos splits existentes (se mudou quem pagou)
            splits = db.query(ExpenseSplit).filter(ExpenseSplit.expense_id == expense_id).all()
            for split in splits:
                old_paid = split.paid_amount
                new_paid = split.installment_amount if split.user_id == paid_by_user_id else Decimal('0')
                if old_paid != new_paid:
                    split.paid_amount = new_paid
                    split.balance = new_paid - split.user_amount
        
        db.commit()
        db.refresh(expense)
        
        return expense
    
    @staticmethod
    def delete_expense(db: Session, expense_id: int):
        """Delete expense and all its splits"""
        expense = db.query(Expense).filter(Expense.id == expense_id).first()
        if not expense:
            raise ValueError("Expense not found")
        
        db.delete(expense)
        db.commit()
    
    @staticmethod
    def get_user_balance(db: Session, user_id: int) -> Decimal:
        """Get total balance for a user via SQL SUM"""
        result = db.query(
            func.coalesce(func.sum(ExpenseSplit.balance), 0)
        ).filter(ExpenseSplit.user_id == user_id).scalar()
        return Decimal(str(result))
    
    @staticmethod
    def get_all_balances(db: Session):
        """Get balances for all users"""
        users = db.query(User).filter(User.is_active == True).all()
        
        balances = []
        for user in users:
            balance = ExpenseService.get_user_balance(db, user.id)
            balances.append({
                "user_id": user.id,
                "user_name": user.name,
                "balance": float(balance),
                "to_receive": float(balance) if balance > 0 else 0,
                "to_pay": float(-balance) if balance < 0 else 0
            })
        
        return balances
