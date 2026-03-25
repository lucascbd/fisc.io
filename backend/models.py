"""SQLAlchemy Models - OTIMIZADO COM ÍNDICES"""
from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey, Numeric, Date, Index, Time
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from datetime import datetime, time
from database import Base


class User(Base):
    """User model"""
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    email = Column(String, unique=True, nullable=False, index=True)
    password_hash = Column(String, nullable=False)
    is_admin = Column(Boolean, default=False)
    is_active = Column(Boolean, default=True, index=True)
    color = Column(String(7), default='#3B82F6')
    emoji = Column(String(10), default='👤')
    display_order = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)
    # Preferências do usuário
    preferred_payment_method = Column(String(10), default='pix')   # 'pix' ou 'cartao'
    invoice_due_day = Column(Integer, default=1)                   # dia de vencimento da fatura (1-31)
    preferred_ipca_location = Column(Integer, default=1)           # D1C da tabela ipca (1=Brasil)
    hidden_category_ids = Column(String, default='[]')             # JSON list de category IDs ocultos pelo usuário
    preferred_split_profile_id = Column(Integer, nullable=True)    # perfil de divisão preferencial
    
    # Relationships
    device_tokens = relationship("DeviceToken", back_populates="user", cascade="all, delete-orphan")
    notification_preferences = relationship("NotificationPreferences", back_populates="user", uselist=False, cascade="all, delete-orphan")


class Category(Base):
    """Category model"""
    __tablename__ = "categories"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    description = Column(String)
    icon = Column(String)
    color = Column(String, default="#999999")
    is_active = Column(Boolean, default=True, index=True)
    display_order = Column(Integer, default=0)
    ipca_category_code = Column(Integer, nullable=True)    # D4C da tabela ipca
    ipca_category_name = Column(String, nullable=True)     # D4N da tabela ipca
    created_at = Column(DateTime, default=datetime.utcnow)


class SplitProfile(Base):
    """Split profile model"""
    __tablename__ = "split_profiles"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    description = Column(String)
    emoji = Column(String(10), default='⚖️')
    is_active = Column(Boolean, default=True, index=True)
    display_order = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    users = relationship("SplitProfileUser", back_populates="profile")


class SplitProfileUser(Base):
    """Split profile user relationship"""
    __tablename__ = "split_profile_users"
    
    id = Column(Integer, primary_key=True, index=True)
    profile_id = Column(Integer, ForeignKey("split_profiles.id"), nullable=False, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    percentage = Column(Numeric(5, 4), nullable=False)
    
    profile = relationship("SplitProfile", back_populates="users")


class Expense(Base):
    """Expense model"""
    __tablename__ = "expenses"
    
    id = Column(Integer, primary_key=True, index=True)
    description = Column(String, nullable=False)
    total_amount = Column(Numeric(12, 2), nullable=False)
    installments = Column(Integer, default=1)
    expense_date = Column(Date, nullable=False, index=True)
    paid_by_user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    category_id = Column(Integer, ForeignKey("categories.id"), nullable=False, index=True)
    split_profile_id = Column(Integer, ForeignKey("split_profiles.id"), nullable=False, index=True)
    notes = Column(String)
    payment_method = Column(String(10), default='pix')             # 'pix' ou 'cartao'
    original_date = Column(Date, nullable=True)                    # data real de lançamento (antes do ajuste de cartão)
    created_at = Column(DateTime, default=datetime.utcnow)
    created_by_user_id = Column(Integer, ForeignKey("users.id"))
    
    # Relationships com lazy="joined" para eager loading
    paid_by = relationship("User", foreign_keys=[paid_by_user_id], lazy="joined")
    category = relationship("Category", foreign_keys=[category_id], lazy="joined")
    split_profile = relationship("SplitProfile", foreign_keys=[split_profile_id], lazy="joined")


class ExpenseSplit(Base):
    """Expense split model"""
    __tablename__ = "expense_splits"
    
    id = Column(Integer, primary_key=True, index=True)
    expense_id = Column(Integer, ForeignKey("expenses.id"), nullable=False, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    installment_number = Column(Integer, nullable=False)
    installment_amount = Column(Numeric(10, 2), nullable=False)
    user_percentage = Column(Numeric(5, 4), nullable=False)
    user_amount = Column(Numeric(10, 2), nullable=False)
    paid_amount = Column(Numeric(10, 2), nullable=False, default=0)
    balance = Column(Numeric(10, 2), nullable=False, default=0)
    due_date = Column(Date, nullable=False, index=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationship com lazy="joined" para eager loading
    user = relationship("User", foreign_keys=[user_id], lazy="joined")
    
    # Índice composto para queries frequentes
    __table_args__ = (
        Index('idx_splits_user_due_date', 'user_id', 'due_date'),
        Index('idx_splits_expense_due_date', 'expense_id', 'due_date'),
    )


class DeviceToken(Base):
    """Tokens de dispositivos para notificações push via Firebase Cloud Messaging"""
    __tablename__ = "device_tokens"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    token = Column(String(255), unique=True, nullable=False, index=True)
    device_info = Column(String(255))
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # Relationship
    user = relationship("User", back_populates="device_tokens")


class NotificationPreferences(Base):
    """Preferências de notificação de cada usuário"""
    __tablename__ = "notification_preferences"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, unique=True, index=True)
    
    # Tipos de notificação
    notify_new_expense = Column(Boolean, default=True)      # Novas despesas
    notify_edit_expense = Column(Boolean, default=False)    # Edições
    notify_delete_expense = Column(Boolean, default=False)  # Deleções
    notify_reminders = Column(Boolean, default=True)        # Lembretes mensais
    
    # Horário preferido para lembretes (formato HH:MM)
    reminder_time = Column(String(5), default='09:00')
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # Relationship
    user = relationship("User", back_populates="notification_preferences")


class Target(Base):
    """Targets mensais por usuário (múltiplos por usuário)"""
    __tablename__ = "targets"

    id             = Column(Integer, primary_key=True, index=True)
    user_id        = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    name           = Column(String(100), nullable=False, default="Meu Target")
    emoji          = Column(String(10), nullable=False, default="🎯")
    monthly_amount = Column(Numeric(10, 2), nullable=False, default=0)
    category_ids   = Column(String, nullable=True)   # JSON: "[1,2,3]"
    payment_methods = Column(String, nullable=True)  # JSON: '["pix","cartao","vale"]' — null = todos
    display_mode   = Column(String(20), nullable=False, default="daily")   # 'daily' | 'ticket'
    ticket_months  = Column(Integer, nullable=False, default=6)
    sort_order     = Column(Integer, nullable=False, default=0)
    is_active      = Column(Boolean, nullable=False, default=True)
    created_at     = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User")


class RecurringExpense(Base):
    """Despesas recorrentes — geradas no dia 1 de cada mês"""
    __tablename__ = "recurring_expenses"

    id              = Column(Integer, primary_key=True, index=True)
    description     = Column(String, nullable=False)
    total_amount    = Column(Numeric(12, 2), nullable=False)
    category_id     = Column(Integer, ForeignKey("categories.id"), nullable=False, index=True)
    split_profile_id= Column(Integer, ForeignKey("split_profiles.id"), nullable=False, index=True)
    paid_by_user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    payment_method  = Column(String(10), default='pix')
    notes           = Column(String, nullable=True)
    is_active       = Column(Boolean, nullable=False, default=True)
    last_generated_month = Column(String(7), nullable=True)   # "YYYY-MM" do último mês gerado
    created_by_user_id   = Column(Integer, ForeignKey("users.id"), nullable=True)
    created_at      = Column(DateTime(timezone=True), server_default=func.now())

    category     = relationship("Category",     foreign_keys=[category_id],      lazy="joined")
    split_profile= relationship("SplitProfile", foreign_keys=[split_profile_id], lazy="joined")
    paid_by      = relationship("User",         foreign_keys=[paid_by_user_id],  lazy="joined")
