"""Budget System - FastAPI Main Application - UPDATED"""
from fastapi import FastAPI, Depends, HTTPException, status, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import func, extract, or_
from datetime import datetime, timedelta, date
from jose import JWTError, jwt
from typing import List, Optional
import json
import os
from pydantic import BaseModel
import bcrypt
from decimal import Decimal

from config import settings
from database import Base, engine, get_db
from models import User, Category, SplitProfile, SplitProfileUser, Expense, ExpenseSplit, DeviceToken, Target, RecurringExpense
from expense_service import ExpenseService
from firebase_service import FirebaseService

# Create tables
Base.metadata.create_all(bind=engine)

# NOTA: As colunas abaixo precisam ser adicionadas manualmente no banco se ainda não existirem:
#   ALTER TABLE categories ADD COLUMN IF NOT EXISTS ipca_category_code INTEGER;
#   ALTER TABLE categories ADD COLUMN IF NOT EXISTS ipca_category_name TEXT;
#   ALTER TABLE users ADD COLUMN IF NOT EXISTS preferred_payment_method TEXT DEFAULT 'pix';
#   ALTER TABLE users ADD COLUMN IF NOT EXISTS invoice_due_day INTEGER DEFAULT 1;
#   -- Se já tinha invoice_closing_day: ALTER TABLE users RENAME COLUMN invoice_closing_day TO invoice_due_day;
#   ALTER TABLE users ADD COLUMN IF NOT EXISTS preferred_ipca_location INTEGER DEFAULT 1;
#   ALTER TABLE users ADD COLUMN IF NOT EXISTS hidden_category_ids TEXT DEFAULT '[]';
#   ALTER TABLE expenses ADD COLUMN IF NOT EXISTS payment_method TEXT DEFAULT 'pix';
#   ALTER TABLE expenses ADD COLUMN IF NOT EXISTS original_date DATE;

# Seed: cria usuário admin padrão e carrega dados iniciais se o banco estiver vazio
def run_seeds():
    import os
    import io
    import psycopg2
    from database import SessionLocal
    from sqlalchemy import text

    db = SessionLocal()
    try:
        # Admin padrão
        if db.query(User).count() == 0:
            password_hash = bcrypt.hashpw("admin".encode("utf-8"), bcrypt.gensalt()).decode("utf-8")
            admin = User(name="Admin", email="admin@admin.com", password_hash=password_hash, is_admin=True, is_active=True)
            db.add(admin)
            db.commit()
            print("✅ Usuário admin padrão criado (email: admin@admin.com, senha: admin)")

        # Dados iniciais (categories, ipca) via psycopg2
        seed_file = os.path.join(os.path.dirname(__file__), "seeds", "initial_data.sql")
        if os.path.exists(seed_file) and db.execute(text("SELECT COUNT(*) FROM categories")).scalar() == 0:
            db_url = os.environ.get("DATABASE_URL", "")
            conn = psycopg2.connect(db_url)
            conn.autocommit = True
            cur = conn.cursor()

            # Cria tabela ipca se não existir
            cur.execute("""
                CREATE TABLE IF NOT EXISTS public.ipca (
                    "NC" integer, "NN" text, "MC" integer, "MN" text,
                    "V" numeric(12,2), "D1C" integer, "D1N" text,
                    "D2C" integer, "D2N" text, "D3C" integer, "D3N" text,
                    "D4C" integer, "D4N" text,
                    sidra_row_hash text NOT NULL,
                    ingested_at timestamp without time zone DEFAULT now() NOT NULL
                )
            """)
            cur.execute("CREATE UNIQUE INDEX IF NOT EXISTS ipca_rowhash_uidx ON public.ipca (sidra_row_hash)")

            # Parseia blocos COPY do dump e executa via copy_expert
            with open(seed_file, "r", encoding="utf-8") as f:
                lines = f.readlines()

            i = 0
            while i < len(lines):
                line = lines[i]
                if line.startswith("COPY ") and "FROM stdin" in line:
                    copy_header = line.strip()
                    i += 1
                    data_lines = []
                    while i < len(lines) and lines[i].rstrip("\n") != "\\.":
                        data_lines.append(lines[i])
                        i += 1
                    data = "".join(data_lines)
                    cur.copy_expert(copy_header, io.StringIO(data))
                elif line.startswith("SELECT setval("):
                    cur.execute(line.strip())
                i += 1

            cur.close()
            conn.close()
            print("✅ Dados iniciais carregados (categories/ipca)")
    except Exception as e:
        import traceback
        print(f"⚠️ Erro no seed inicial: {e}")
        traceback.print_exc()
    finally:
        db.close()

run_seeds()

# Initialize Firebase Admin SDK
try:
    firebase_creds = os.environ.get("FIREBASE_CREDENTIALS_PATH", "/app/firebase-credentials.json")
    FirebaseService.initialize(firebase_creds)
    print("✅ Firebase Admin SDK inicializado com sucesso")
except Exception as e:
    print(f"⚠️ Firebase não inicializado: {e}")

# Initialize app
app = FastAPI(title=settings.APP_NAME, version=settings.APP_VERSION)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

oauth2_scheme = OAuth2PasswordBearer(tokenUrl=f"{settings.API_V1_PREFIX}/auth/login")

# ============================================================================
# PYDANTIC MODELS
# ============================================================================

class CategoryCreate(BaseModel):
    name: str
    description: Optional[str] = None
    icon: Optional[str] = None
    color: str = "#999999"
    ipca_category_code: Optional[int] = None
    ipca_category_name: Optional[str] = None

class ProfileUserCreate(BaseModel):
    user_id: int
    percentage: float

class ProfileCreate(BaseModel):
    name: str
    description: Optional[str] = ""
    emoji: Optional[str] = "⚖️"
    users: List[ProfileUserCreate]
    from_month: Optional[str] = None  # YYYY-MM: se informado, recalcula splits a partir deste mês

class ExpenseCreate(BaseModel):
    description: str
    total_amount: float
    category_id: int
    split_profile_id: int
    paid_by_user_id: int
    expense_date: str
    installments: int = 1
    notes: Optional[str] = None
    payment_method: Optional[str] = "pix"

class RecurringExpenseCreate(BaseModel):
    description: str
    total_amount: float
    category_id: int
    split_profile_id: int
    paid_by_user_id: int
    payment_method: Optional[str] = "pix"
    notes: Optional[str] = None

class UserUpdate(BaseModel):
    name: Optional[str] = None
    email: Optional[str] = None
    password: Optional[str] = None
    color: Optional[str] = None
    is_admin: Optional[bool] = None
    emoji: Optional[str] = None
    preferred_payment_method: Optional[str] = None
    invoice_due_day: Optional[int] = None
    preferred_ipca_location: Optional[int] = None
    preferred_split_profile_id: Optional[int] = None
    hidden_category_ids: Optional[List[int]] = None

class CategoryReorder(BaseModel):
    category_ids: List[int]

class DeviceTokenCreate(BaseModel):
    token: str


class NotificationPreferencesUpdate(BaseModel):
    notify_new_expense: bool = True
    notify_edit_expense: bool = False
    notify_delete_expense: bool = False
    notify_reminders: bool = True
    reminder_time: str = "09:00"

class TargetCreate(BaseModel):
    name: str = "Meu Target"
    emoji: str = "🎯"
    monthly_amount: float
    category_ids: List[int] = []
    payment_methods: List[str] = []  # [] = todos os métodos
    display_mode: str = "daily"   # 'daily' | 'ticket'
    ticket_months: int = 6

# ============================================================================
# AUTH FUNCTIONS
# ============================================================================

def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return bcrypt.checkpw(plain_password.encode('utf-8'), hashed_password.encode('utf-8'))

def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            raise HTTPException(status_code=401, detail="Invalid credentials")
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    user = db.query(User).filter(User.email == email).first()
    if user is None:
        raise HTTPException(status_code=401, detail="User not found")
    
    return user

def require_admin(current_user: User = Depends(get_current_user)):
    if not current_user.is_admin:
        raise HTTPException(status_code=403, detail="Admin access required")
    return current_user

def visible_expense_ids_subquery(db: Session, current_user: User):
    """
    Retorna subquery com IDs das expenses visíveis para o current_user.
    Todos os usuários (incluindo admins) veem apenas despesas onde:
      - são quem pagou (paid_by_user_id), OU
      - fazem parte do perfil de split da despesa (via SplitProfileUser)
    """
    user_profile_ids = db.query(SplitProfileUser.profile_id).filter(
        SplitProfileUser.user_id == current_user.id
    ).subquery()
    return db.query(Expense.id).filter(
        or_(
            Expense.paid_by_user_id == current_user.id,
            Expense.split_profile_id.in_(user_profile_ids)
        )
    ).subquery()


def _month_date_range(year: int, mon: int):
    """Retorna (start_date, end_date) para um mês, compatível com índice B-tree em due_date."""
    start = date(year, mon, 1)
    end = date(year + 1, 1, 1) if mon == 12 else date(year, mon + 1, 1)
    return start, end


# ============================================================================
# HEALTH & ROOT
# ============================================================================

@app.get("/health")
async def health():
    return {"status": "healthy", "app": settings.APP_NAME}

@app.get("/")
async def root():
    return {"app": settings.APP_NAME, "version": settings.APP_VERSION, "docs": "/docs"}

# ============================================================================
# AUTH ENDPOINTS
# ============================================================================

@app.post(f"{settings.API_V1_PREFIX}/auth/login")
async def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    """Login with email and password"""
    user = db.query(User).filter(User.email == form_data.username).first()
    
    if not user or not verify_password(form_data.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Invalid email or password")
    
    if not user.is_active:
        raise HTTPException(status_code=403, detail="User inactive")
    
    access_token = create_access_token(data={"sub": user.email, "user_id": user.id})
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": {
            "id": user.id,
            "name": user.name,
            "email": user.email,
            "is_admin": user.is_admin,
            "preferred_payment_method": user.preferred_payment_method or 'pix',
            "invoice_due_day": user.invoice_due_day or 1,
            "preferred_ipca_location": user.preferred_ipca_location or 1,
            "preferred_split_profile_id": user.preferred_split_profile_id,
            "hidden_category_ids": json.loads(user.hidden_category_ids or '[]')
        }
    }

@app.get(f"{settings.API_V1_PREFIX}/auth/me")
async def get_me(current_user: User = Depends(get_current_user)):
    """Get current user info"""
    return {
        "id": current_user.id,
        "name": current_user.name,
        "email": current_user.email,
        "is_admin": current_user.is_admin,
        "is_active": current_user.is_active,
        "preferred_payment_method": current_user.preferred_payment_method or 'pix',
        "invoice_due_day": current_user.invoice_due_day or 1,
        "preferred_ipca_location": current_user.preferred_ipca_location or 1,
        "preferred_split_profile_id": current_user.preferred_split_profile_id,
        "hidden_category_ids": json.loads(current_user.hidden_category_ids or '[]')
    }

# ============================================================================
# DEVICE TOKEN ENDPOINTS (Firebase Cloud Messaging)
# ============================================================================

@app.post(f"{settings.API_V1_PREFIX}/device-tokens")
async def register_device_token(
    data: DeviceTokenCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Registrar token FCM de um dispositivo"""
    try:
        # Verificar se token já existe para este usuário
        existing = db.query(DeviceToken).filter(
            DeviceToken.user_id == current_user.id,
            DeviceToken.token == data.token
        ).first()
        
        if existing:
            # Atualizar timestamp
            existing.updated_at = func.now()
            db.commit()
            return {"message": "Token atualizado", "token_id": existing.id}
        
        # Criar novo token
        device_token = DeviceToken(
            user_id=current_user.id,
            token=data.token,
            device_info=None
        )
        
        db.add(device_token)
        db.commit()
        db.refresh(device_token)
        
        return {"message": "Token registrado", "token_id": device_token.id}
        
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))

# ============================================================================
# USER ENDPOINTS - COM UPDATE
# ============================================================================

@app.get(f"{settings.API_V1_PREFIX}/users")
async def list_users(db: Session = Depends(get_db), _: User = Depends(get_current_user)):
    """List all active users ordered by display_order"""
    users = db.query(User).filter(User.is_active == True).order_by(User.display_order).all()
    return [{
        "id": u.id, "name": u.name, "email": u.email,
        "color": u.color or '#3B82F6', "emoji": u.emoji or '👤',
        "display_order": u.display_order or 0, "is_admin": u.is_admin,
        "preferred_payment_method": u.preferred_payment_method or 'pix',
        "invoice_due_day": u.invoice_due_day or 1,
        "preferred_ipca_location": u.preferred_ipca_location or 1,
        "preferred_split_profile_id": u.preferred_split_profile_id,
        "hidden_category_ids": json.loads(u.hidden_category_ids or '[]')
    } for u in users]

@app.post(f"{settings.API_V1_PREFIX}/users")
async def create_user(
    name: str,
    email: str,
    password: str,
    color: str = '#3B82F6',
    emoji: str = '👤',
    is_admin: bool = False,
    db: Session = Depends(get_db),
    _: User = Depends(require_admin)
):
    """Create new user (admin only)"""
    if db.query(User).filter(User.email == email).first():
        raise HTTPException(status_code=400, detail="Email already registered")
    
    salt = bcrypt.gensalt()
    password_hash = bcrypt.hashpw(password.encode('utf-8'), salt).decode('utf-8')
    
    user = User(name=name, email=email, password_hash=password_hash, color=color, emoji=emoji, is_admin=is_admin)
    db.add(user)
    db.commit()
    db.refresh(user)
    
    return {"id": user.id, "name": user.name, "email": user.email, "color": user.color, "emoji": user.emoji}

@app.put(f"{settings.API_V1_PREFIX}/users/{{user_id}}")
async def update_user(
    user_id: int,
    data: UserUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Update user. Admin pode editar qualquer usuário. Usuário comum pode editar apenas seus próprios dados (exceto is_admin)."""
    # Verificar permissão: admin pode tudo, usuário comum só edita si mesmo
    if not current_user.is_admin and current_user.id != user_id:
        raise HTTPException(status_code=403, detail="Sem permissão para editar este usuário")
    
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    if data.name:
        user.name = data.name
    if data.email:
        existing = db.query(User).filter(User.email == data.email, User.id != user_id).first()
        if existing:
            raise HTTPException(status_code=400, detail="Email already in use")
        user.email = data.email
    if data.password:
        salt = bcrypt.gensalt()
        user.password_hash = bcrypt.hashpw(data.password.encode('utf-8'), salt).decode('utf-8')
    if data.color:
        user.color = data.color
    # is_admin só pode ser alterado por admin
    if data.is_admin is not None and current_user.is_admin:
        user.is_admin = data.is_admin
    if data.emoji:
        user.emoji = data.emoji
    if data.preferred_payment_method is not None:
        user.preferred_payment_method = data.preferred_payment_method
    if data.invoice_due_day is not None:
        user.invoice_due_day = data.invoice_due_day
    if data.preferred_ipca_location is not None:
        user.preferred_ipca_location = data.preferred_ipca_location
    if data.preferred_split_profile_id is not None:
        user.preferred_split_profile_id = data.preferred_split_profile_id
    if data.hidden_category_ids is not None:
        user.hidden_category_ids = json.dumps(data.hidden_category_ids)
    # Target: qualquer usuário pode editar no próprio perfil
    
    db.commit()
    return {"message": "User updated"}

@app.post(f"{settings.API_V1_PREFIX}/users/me/toggle-category/{{category_id}}")
async def toggle_category_visibility(
    category_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Toggle visibility of a category for the current user. Returns updated hidden list."""
    hidden = json.loads(current_user.hidden_category_ids or '[]')
    if category_id in hidden:
        hidden.remove(category_id)
    else:
        hidden.append(category_id)
    current_user.hidden_category_ids = json.dumps(hidden)
    db.commit()
    return {"hidden_category_ids": hidden}

@app.delete(f"{settings.API_V1_PREFIX}/users/{{user_id}}")
async def delete_user(user_id: int, db: Session = Depends(get_db), _: User = Depends(require_admin)):
    """Delete user (admin only) - Soft delete se tiver expense_splits, erro se estiver em perfil"""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Verificar se está em algum perfil de split ativo
    profile_users = db.query(SplitProfileUser).filter(SplitProfileUser.user_id == user_id).all()
    if profile_users:
        profile_ids = [pu.profile_id for pu in profile_users]
        active_profiles = db.query(SplitProfile).filter(
            SplitProfile.id.in_(profile_ids), 
            SplitProfile.is_active == True
        ).all()
        if active_profiles:
            names = ', '.join([p.name for p in active_profiles])
            raise HTTPException(status_code=400, detail=f"Remova o usuário dos perfis primeiro: {names}")
    
    # Verificar se tem expense_splits
    has_splits = db.query(ExpenseSplit).filter(ExpenseSplit.user_id == user_id).first()
    
    if has_splits:
        user.is_active = False
        db.commit()
        return {"message": "User deactivated", "soft_delete": True}
    else:
        db.delete(user)
        db.commit()
        return {"message": "User deleted", "soft_delete": False}

@app.put(f"{settings.API_V1_PREFIX}/users/{{user_id}}/reorder")
async def reorder_user(
    user_id: int, 
    data: dict, 
    db: Session = Depends(get_db), 
    _: User = Depends(require_admin)
):
    """Reorder user (admin only)"""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    user.display_order = data.get("display_order", 0)
    db.commit()
    return {"message": "User reordered successfully"}

# ============================================================================
# CATEGORY ENDPOINTS - COM UPDATE E REATIVAÇÃO
# ============================================================================

@app.get(f"{settings.API_V1_PREFIX}/categories")
async def list_categories(db: Session = Depends(get_db), _: User = Depends(get_current_user)):
    """List all active categories ordered by display_order (if exists) or id"""
    try:
        cats = db.query(Category).filter(Category.is_active == True).order_by(Category.display_order, Category.id).all()
    except Exception:
        cats = db.query(Category).filter(Category.is_active == True).order_by(Category.id).all()
    return [{"id": c.id, "name": c.name, "description": c.description, "icon": c.icon, "color": c.color,
             "ipca_category_code": c.ipca_category_code, "ipca_category_name": c.ipca_category_name} for c in cats]

@app.get(f"{settings.API_V1_PREFIX}/ipca/categories")
async def list_ipca_categories(db: Session = Depends(get_db), _: User = Depends(get_current_user)):
    """List distinct D4C/D4N pairs from ipca table, ordered hierarchically by D4N prefix"""
    from sqlalchemy import text
    import re
    try:
        result = db.execute(text(
            'SELECT DISTINCT "D4C", "D4N" FROM ipca WHERE "D4C" IS NOT NULL AND "D4N" IS NOT NULL'
        )).fetchall()
        
        def sort_key(row):
            name = row[1]
            m = re.match(r'^([\d.]+)\.', name)
            if not m:
                return []  # Índice geral vai primeiro
            # Converte "1101002" em [1, 1, 101002] para ordenação hierárquica
            prefix = m.group(1)
            parts = prefix.split('.')
            # Sem ponto no prefix: é o número direto (ex: "1101002")
            # Com ponto não acontece aqui — os prefixos são como "1", "11", "1101", "1101002"
            # Vamos converter em lista de segmentos: "1101002" → [1, 101002] seguindo a hierarquia
            # Hierarquia: 1 dígito → 2 dígitos → 4 dígitos → 7+ dígitos
            num = prefix.replace('.', '')
            segments = []
            if len(num) >= 1:
                segments.append(int(num[:1]))
            if len(num) >= 2:
                segments.append(int(num[:2]))
            if len(num) >= 4:
                segments.append(int(num[:4]))
            if len(num) >= 7:
                segments.append(int(num))
            return segments
        
        sorted_rows = sorted(result, key=sort_key)
        return [{"code": row[0], "name": row[1]} for row in sorted_rows]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao consultar IPCA: {str(e)}")

# ============================================================================
# RECURRING EXPENSES
# ============================================================================

def _recurring_dict(r: RecurringExpense) -> dict:
    return {
        "id": r.id,
        "description": r.description,
        "total_amount": float(r.total_amount),
        "category_id": r.category_id,
        "category_name": r.category.name if r.category else None,
        "category_emoji": r.category.icon if r.category else None,
        "split_profile_id": r.split_profile_id,
        "split_profile_name": r.split_profile.name if r.split_profile else None,
        "paid_by_user_id": r.paid_by_user_id,
        "paid_by_name": r.paid_by.name if r.paid_by else None,
        "payment_method": r.payment_method,
        "notes": r.notes,
        "is_active": r.is_active,
        "last_generated_month": r.last_generated_month,
        "created_by_user_id": r.created_by_user_id,
    }

@app.get(f"{settings.API_V1_PREFIX}/recurring")
async def list_recurring(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """List all active recurring expenses visible to the current user."""
    items = db.query(RecurringExpense).filter(RecurringExpense.is_active == True).order_by(RecurringExpense.id).all()
    return [_recurring_dict(r) for r in items]

@app.post(f"{settings.API_V1_PREFIX}/recurring")
async def create_recurring(data: RecurringExpenseCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """Create a new recurring expense template."""
    r = RecurringExpense(
        description=data.description,
        total_amount=Decimal(str(data.total_amount)),
        category_id=data.category_id,
        split_profile_id=data.split_profile_id,
        paid_by_user_id=data.paid_by_user_id,
        payment_method=data.payment_method,
        notes=data.notes,
        created_by_user_id=current_user.id,
    )
    db.add(r); db.commit(); db.refresh(r)
    return _recurring_dict(r)

@app.put(f"{settings.API_V1_PREFIX}/recurring/{{recurring_id}}")
async def update_recurring(recurring_id: int, data: RecurringExpenseCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """Update a recurring expense template."""
    r = db.query(RecurringExpense).filter(RecurringExpense.id == recurring_id, RecurringExpense.is_active == True).first()
    if not r:
        raise HTTPException(status_code=404, detail="Recurring expense not found")
    r.description = data.description
    r.total_amount = Decimal(str(data.total_amount))
    r.category_id = data.category_id
    r.split_profile_id = data.split_profile_id
    r.paid_by_user_id = data.paid_by_user_id
    r.payment_method = data.payment_method
    r.notes = data.notes
    db.commit()
    return _recurring_dict(r)

@app.delete(f"{settings.API_V1_PREFIX}/recurring/{{recurring_id}}")
async def delete_recurring(recurring_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """Soft-delete a recurring expense template."""
    r = db.query(RecurringExpense).filter(RecurringExpense.id == recurring_id).first()
    if not r:
        raise HTTPException(status_code=404, detail="Recurring expense not found")
    r.is_active = False
    db.commit()
    return {"message": "Deleted"}

@app.post(f"{settings.API_V1_PREFIX}/recurring/generate")
async def generate_recurring(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Generate expenses for the current month from all active recurring templates.
    Skips templates that have already been generated this month.
    Returns the list of created expense ids.
    """
    today = datetime.utcnow().date()
    current_month_str = today.strftime("%Y-%m")
    expense_date = today.replace(day=1)   # always day 1 of current month

    items = db.query(RecurringExpense).filter(RecurringExpense.is_active == True).all()
    created_ids = []
    skipped = 0

    for r in items:
        if r.last_generated_month == current_month_str:
            skipped += 1
            continue
        # Reuse ExpenseService to get correct split calculation
        expense = ExpenseService.create_expense(
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
            created_by_user_id=current_user.id,
        )
        r.last_generated_month = current_month_str
        created_ids.append(expense.id)

    db.commit()
    return {"generated": len(created_ids), "skipped": skipped, "expense_ids": created_ids}

@app.get(f"{settings.API_V1_PREFIX}/inflation/locations")
async def list_inflation_locations(db: Session = Depends(get_db), _: User = Depends(get_current_user)):
    """List available D1C/D1N locations from ipca table"""
    from sqlalchemy import text
    result = db.execute(text('SELECT DISTINCT "D1C", "D1N" FROM ipca WHERE "D1C" IS NOT NULL ORDER BY "D1C"')).fetchall()
    return [{"code": row[0], "name": row[1]} for row in result]

@app.get(f"{settings.API_V1_PREFIX}/inflation/months")
async def list_inflation_months(db: Session = Depends(get_db), _: User = Depends(get_current_user)):
    """List available year-months from ipca table, most recent first"""
    from sqlalchemy import text
    result = db.execute(text(
        'SELECT DISTINCT "D3C" FROM ipca WHERE "D3C" IS NOT NULL ORDER BY "D3C" DESC'
    )).fetchall()
    # D3C is YYYYMM integer, convert to YYYY-MM string
    months = []
    for row in result:
        d3c = str(row[0])
        if len(d3c) == 6:
            months.append(f"{d3c[:4]}-{d3c[4:]}")
    return {"months": months, "latest": months[0] if months else None}

@app.get(f"{settings.API_V1_PREFIX}/inflation/data")
async def get_inflation_data(
    d1c: int = Query(1, description="D1C location code (1=Brasil, 4801=RJ)"),
    months: Optional[str] = Query(None, description="Comma-separated YYYY-MM months to include"),
    category_ids: Optional[str] = Query(None, description="Comma-separated category IDs"),
    user_ids: Optional[str] = Query(None, description="Comma-separated user IDs"),
    expense_type: Optional[str] = Query(None, description="Filter: 'individual', 'shared', or None for all"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    from sqlalchemy import text
    from collections import defaultdict

    filter_months = set(months.split(',')) if months else None
    filter_cat_ids = set(int(x) for x in category_ids.split(',')) if category_ids else None
    filter_user_ids = set(int(x) for x in user_ids.split(',')) if user_ids else None

    # 1. Buscar parcelas visíveis com categoria e código IPCA
    # Quando filter_months é informado, filtra no SQL para evitar carregar toda a tabela
    sql_date_filter = ""
    sql_params: dict = {"uid": current_user.id}
    if filter_months:
        parsed = sorted(filter_months)
        min_y, min_m = map(int, min(parsed).split('-'))
        max_y, max_m = map(int, max(parsed).split('-'))
        sql_start = date(min_y, min_m, 1)
        sql_end_y, sql_end_m = (max_y + 1, 1) if max_m == 12 else (max_y, max_m + 1)
        sql_end = date(sql_end_y, sql_end_m, 1)
        sql_date_filter = "AND es.due_date >= :sql_start AND es.due_date < :sql_end"
        sql_params["sql_start"] = sql_start
        sql_params["sql_end"] = sql_end

    splits_raw = db.execute(text(f"""
        SELECT es.user_id, es.user_amount, es.due_date, e.category_id,
               c.ipca_category_code, c.name as cat_name, c.icon as cat_icon,
               COALESCE(es.user_percentage, 1.0) as user_pct,
               e.id as expense_id, u.name as user_name
        FROM expense_splits es
        JOIN expenses e ON es.expense_id = e.id
        JOIN categories c ON e.category_id = c.id
        JOIN users u ON es.user_id = u.id
        WHERE e.id IN (
            SELECT DISTINCT e2.id FROM expenses e2
            LEFT JOIN split_profile_users spu ON spu.profile_id = e2.split_profile_id
            WHERE e2.paid_by_user_id = :uid OR spu.user_id = :uid
        )
        {sql_date_filter}
        ORDER BY es.due_date
    """), sql_params).fetchall()

    filtered = []
    # Track ALL splits per expense per month to detect shared expenses
    expense_month_users = defaultdict(lambda: defaultdict(set))  # {expense_id: {month_str: set(user_ids)}}
    all_splits_full = []  # all rows with full data

    for r in splits_raw:
        user_id, user_amount, due_date, category_id, ipca_code, cat_name, cat_icon, user_pct, expense_id, user_name = r
        month_str = f"{due_date.year}-{str(due_date.month).zfill(2)}"
        expense_month_users[expense_id][month_str].add(user_id)
        all_splits_full.append((user_id, float(user_amount), due_date, category_id, ipca_code, cat_name, cat_icon or '📁', month_str, float(user_pct), expense_id, user_name))

    for row in all_splits_full:
        user_id, user_amount, due_date, category_id, ipca_code, cat_name, cat_icon, month_str, user_pct, expense_id, user_name = row
        if filter_months and month_str not in filter_months:
            continue
        if filter_cat_ids and category_id not in filter_cat_ids:
            continue
        if filter_user_ids and user_id not in filter_user_ids:
            continue
        filtered.append((user_id, user_amount, due_date, category_id, ipca_code, cat_name, cat_icon, month_str, user_pct, expense_id, user_name))

    if not filtered:
        return {"my_inflation": [], "ipca_geral": [], "adjusted_by_month": [],
                "category_inflation": [], "price_volume": [], "shared_by_user_adj": []}

    # 2. IPCA para localização selecionada
    ipca_raw = db.execute(text("""
        SELECT "D4C", "D3C", "V"
        FROM ipca WHERE "D1C" = :d1c AND "D2C" = 63 AND "V" IS NOT NULL
    """), {"d1c": d1c}).fetchall()

    ipca_dict = {(row[0], row[1]): float(row[2]) for row in ipca_raw}
    ipca_geral_dict = {d3c: v for (d4c, d3c), v in ipca_dict.items() if d4c == 7169}

    months_in_splits = sorted(set(r[2].year * 100 + r[2].month for r in filtered))
    if not months_in_splits:
        return {"my_inflation": [], "ipca_geral": [], "adjusted_by_month": [],
                "category_inflation": [], "price_volume": [], "shared_by_user_adj": []}
    max_month = months_in_splits[-1]

    # Pré-calcular v_accum para cada (ipca_code, month_int) único
    # v_accum[code][month] = soma do IPCA dos meses POSTERIORES a month (exclui o próprio)
    # Usa suffix-sum: percorre months_in_splits de trás pra frente, O(codes × months)
    unique_codes = {r[4] for r in filtered if r[4]}
    v_accum_cache: dict = {}
    for code in unique_codes:
        running = 0.0
        v_accum_cache[code] = {}
        # Iterar de trás pra frente: para cada mês, o acumulado posterior é a soma que já temos
        for m in reversed(months_in_splits):
            v_accum_cache[code][m] = running
            running += ipca_dict.get((code, m), 0.0)

    # 3. Cálculo principal por mês
    monthly_num = defaultdict(float)
    monthly_den = defaultdict(float)
    monthly_adj = defaultdict(float)
    monthly_adj_individual = defaultdict(float)
    monthly_adj_shared = defaultdict(float)
    # Per-category
    cat_monthly_num = defaultdict(lambda: defaultdict(float))
    cat_monthly_den = defaultdict(lambda: defaultdict(float))
    cat_monthly_adj = defaultdict(lambda: defaultdict(float))   # adj valor per cat/month
    cat_monthly_count = defaultdict(lambda: defaultdict(float))   # weighted volume per cat/month
    cat_info = {}
    # Shared-by-user: only include splits from shared expenses (>1 user in same month)
    shared_user_monthly_adj = defaultdict(lambda: defaultdict(float))  # {user_name: {month: adj_amount}}

    for user_id, user_amount, due_date, category_id, ipca_code, cat_name, cat_icon, month_str, user_pct, expense_id, user_name in filtered:
        month_int = due_date.year * 100 + due_date.month
        v = ipca_dict.get((ipca_code, month_int), 0.0) if ipca_code else 0.0
        v_accum = v_accum_cache.get(ipca_code, {}).get(month_int, 0.0) if ipca_code else 0.0
        user_amount_adj = round(user_amount * (1 + v_accum / 100), 2)

        users_in_month = expense_month_users[expense_id].get(month_str, set())
        is_shared = len(users_in_month) > 1

        # Only include logged-in user's splits in the main aggregates
        if user_id == current_user.id:
            # Apply expense_type filter
            if expense_type == 'individual' and is_shared:
                pass  # skip shared expenses for individual-only view
            elif expense_type == 'shared' and not is_shared:
                pass  # skip individual expenses for shared-only view
            else:
                # Only include in IPCA weighting if the category has an IPCA code
                if ipca_code:
                    monthly_num[month_str] += user_amount * v
                    monthly_den[month_str] += user_amount
                    cat_monthly_num[category_id][month_str] += user_amount * v
                    cat_monthly_den[category_id][month_str] += user_amount
                monthly_adj[month_str] += user_amount_adj
                if is_shared:
                    monthly_adj_shared[month_str] += user_amount_adj
                else:
                    monthly_adj_individual[month_str] += user_amount_adj
                cat_monthly_adj[category_id][month_str] += user_amount_adj
                cat_monthly_count[category_id][month_str] += user_pct
        cat_info[category_id] = (cat_name, cat_icon)

        # Shared-by-user breakdown
        if is_shared:
            shared_user_monthly_adj[user_name][month_str] += user_amount_adj

    sorted_months = sorted(monthly_adj.keys())

    # 4. Minha Inflação acumulada (com rate mensal para tooltip)
    my_inflation, cumulative = [], 0.0
    for m in sorted_months:
        den = monthly_den[m]
        rate = round(monthly_num[m] / den, 2) if den > 0 else 0.0
        cumulative = round(cumulative + rate, 2)
        my_inflation.append({"month": m, "rate": rate, "cumulative": cumulative})

    # 5. IPCA Geral acumulado
    ipca_geral, geral_cum = [], 0.0
    for m in sorted_months:
        rate = ipca_geral_dict.get(int(m.replace("-", "")), 0.0)
        geral_cum = round(geral_cum + rate, 2)
        ipca_geral.append({"month": m, "rate": rate, "cumulative": geral_cum})

    # 6. Ajustado por mês
    adjusted_by_month = [
        {
            "month": m,
            "adjusted": round(monthly_adj[m], 2),
            "nominal": round(monthly_den[m], 2),
            "individual": round(monthly_adj_individual[m], 2),
            "shared": round(monthly_adj_shared[m], 2)
        }
        for m in sorted_months
    ]

    # 7. Inflação por categoria (acumulada e mensal para tooltip)
    category_inflation = []
    for cat_id, month_num_dict in cat_monthly_num.items():
        name, icon = cat_info.get(cat_id, ('?', '📁'))
        cum, series = 0.0, []
        for m in sorted_months:
            den = cat_monthly_den[cat_id].get(m, 0.0)
            rate = round(month_num_dict.get(m, 0.0) / den, 2) if den > 0 else 0.0
            cum = round(cum + rate, 2)
            series.append({"month": m, "rate": rate, "cumulative": cum})
        if any(d["rate"] != 0 for d in series):
            category_inflation.append({"category_id": cat_id, "name": name, "icon": icon, "series": series})
    category_inflation.sort(key=lambda x: abs(sum(d["cumulative"] for d in x["series"])), reverse=True)

    # 8. Análise Média x Último Mês (efeito preço + volume)
    # Lógica Excel:
    #   prev_months = todos os meses EXCETO o último
    #   volume_prev[cat] = count de transações nos meses anteriores (COUNT)
    #   valor_prev[cat] = SUM(user_amount) nos meses anteriores
    #   P (avg_vol_prev) = SUM(volume por mês anterior) / count(meses anteriores)
    #   Q (avg_valor_prev) = valor_prev / P
    #   S (avg_price_prev) = Q / P = avg_valor_prev / avg_vol_prev
    #   volume_last[cat] = count de transações no último mês
    #   valor_last[cat] = SUM(user_amount) no último mês
    #   T (avg_price_last) = valor_last / volume_last
    #   Efeito preço = (T - S) * N  onde N = volume_last
    #   Efeito volume = (N - P) * S
    if len(sorted_months) < 2:
        price_volume = []
    else:
        last_month = sorted_months[-1]
        prev_months = sorted_months[:-1]
        n_prev = len(prev_months)

        price_volume = []
        for cat_id in cat_monthly_count:
            name, icon = cat_info.get(cat_id, ('?', '📁'))
            # P: avg monthly count in prev months
            p = sum(cat_monthly_count[cat_id].get(m, 0) for m in prev_months) / n_prev if n_prev > 0 else 0.0
            # Q: avg adj valor in prev months (total adj / n_prev months)
            q = sum(cat_monthly_adj[cat_id].get(m, 0.0) for m in prev_months) / n_prev if n_prev > 0 else 0.0
            # S: adj avg price (ticket médio) in prev months — sem round para preservar precisão
            s = q / p if p > 0 else 0.0
            # N: count last month
            n_last = cat_monthly_count[cat_id].get(last_month, 0)
            # T: adj avg price last month — sem round para preservar precisão
            valor_last_adj = cat_monthly_adj[cat_id].get(last_month, 0.0)
            t = valor_last_adj / n_last if n_last > 0 else 0.0
            # Effects (in R$)
            preco = round((t - s) * n_last, 2)
            volume = round((n_last - p) * s, 2)
            # Effects as %
            base = q  # avg monthly adj spend in prev
            preco_pct = round(preco / base * 100, 1) if base > 0 else 0.0
            volume_pct = round(volume / base * 100, 1) if base > 0 else 0.0
            if p > 0 or n_last > 0:
                price_volume.append({
                    "category_id": cat_id, "name": name, "icon": icon,
                    "avg_price_prev": round(s, 2), "avg_price_last": round(t, 2),
                    "vol_prev": round(p, 1), "vol_last": n_last,
                    "efeito_preco": preco, "efeito_volume": volume,
                    "efeito_preco_pct": preco_pct, "efeito_volume_pct": volume_pct,
                    "avg_spend_prev": round(q, 2),
                    "avg_spend_last": round(valor_last_adj, 2)
                })
        price_volume.sort(key=lambda x: abs(x["efeito_preco"]) + abs(x["efeito_volume"]), reverse=True)

    # 9. Shared-by-user adjusted totals per month
    all_shared_user_names = sorted(shared_user_monthly_adj.keys())
    shared_by_user_adj = []
    for m in sorted_months:
        row = {"month": m}
        has_data = False
        for uname in all_shared_user_names:
            val = round(shared_user_monthly_adj[uname].get(m, 0.0), 2)
            row[uname] = val
            if val > 0:
                has_data = True
        if has_data:
            shared_by_user_adj.append(row)

    return {
        "my_inflation": my_inflation,
        "ipca_geral": ipca_geral,
        "adjusted_by_month": adjusted_by_month,
        "category_inflation": category_inflation,
        "price_volume": price_volume,
        "shared_by_user_adj": shared_by_user_adj,
        "max_month": sorted_months[-1] if sorted_months else None,
        "months": sorted_months
    }

@app.post(f"{settings.API_V1_PREFIX}/categories")
async def create_category(
    data: CategoryCreate,
    db: Session = Depends(get_db),
    _: User = Depends(require_admin)
):
    """Create new category (admin only) - REATIVA SE JÁ EXISTIR INATIVA"""
    existing = db.query(Category).filter(Category.name == data.name).first()
    
    if existing:
        if existing.is_active:
            raise HTTPException(status_code=400, detail="Category already exists")
        else:
            existing.is_active = True
            existing.description = data.description
            existing.icon = data.icon
            existing.color = data.color
            existing.ipca_category_code = data.ipca_category_code
            existing.ipca_category_name = data.ipca_category_name
            db.commit()
            db.refresh(existing)
            return {"id": existing.id, "name": existing.name, "message": "Category reactivated"}
    
    category = Category(
        name=data.name,
        description=data.description,
        icon=data.icon,
        color=data.color,
        ipca_category_code=data.ipca_category_code,
        ipca_category_name=data.ipca_category_name
    )
    db.add(category)
    db.commit()
    db.refresh(category)
    return {"id": category.id, "name": category.name}

@app.put(f"{settings.API_V1_PREFIX}/categories/reorder")
async def reorder_categories(
    data: CategoryReorder,
    db: Session = Depends(get_db),
    _: User = Depends(require_admin)
):
    """Reorder categories by updating display_order (admin only)"""
    try:
        cats = {c.id: c for c in db.query(Category).filter(Category.id.in_(data.category_ids)).all()}
        for index, category_id in enumerate(data.category_ids):
            if category_id in cats:
                cats[category_id].display_order = index

        db.commit()
        return {"message": "Categories reordered successfully"}
    except Exception as e:
        db.rollback()
        if "display_order" in str(e):
            raise HTTPException(
                status_code=400, 
                detail="Database needs migration. Run: ALTER TABLE categories ADD COLUMN display_order INTEGER DEFAULT 0;"
            )
        raise HTTPException(status_code=500, detail=f"Error reordering: {str(e)}")

@app.put(f"{settings.API_V1_PREFIX}/categories/{{category_id}}")
async def update_category(
    category_id: int,
    data: CategoryCreate,
    db: Session = Depends(get_db),
    _: User = Depends(require_admin)
):
    """Update category (admin only)"""
    category = db.query(Category).filter(Category.id == category_id).first()
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")
    
    if data.name != category.name:
        existing = db.query(Category).filter(Category.name == data.name, Category.id != category_id).first()
        if existing and existing.is_active:
            raise HTTPException(status_code=400, detail="Category name already in use")
    
    category.name = data.name
    category.description = data.description
    category.icon = data.icon
    category.color = data.color
    category.ipca_category_code = data.ipca_category_code
    category.ipca_category_name = data.ipca_category_name
    
    db.commit()
    return {"message": "Category updated"}

@app.delete(f"{settings.API_V1_PREFIX}/categories/{{category_id}}")
async def delete_category(category_id: int, db: Session = Depends(get_db), _: User = Depends(require_admin)):
    """Delete category (admin only) - Soft delete se tiver expenses"""
    category = db.query(Category).filter(Category.id == category_id).first()
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")
    
    has_expenses = db.query(Expense).filter(Expense.category_id == category_id).first()
    
    if has_expenses:
        category.is_active = False
        db.commit()
        return {"message": "Category deactivated", "soft_delete": True}
    else:
        db.delete(category)
        db.commit()
        return {"message": "Category deleted", "soft_delete": False}

# ============================================================================
# SPLIT PROFILE ENDPOINTS - COM UPDATE
# ============================================================================

@app.get(f"{settings.API_V1_PREFIX}/profiles")
async def list_profiles(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """List split profiles - admin vê todos, usuário comum vê apenas os que faz parte"""
    query = db.query(SplitProfile).options(
        joinedload(SplitProfile.users)
    ).filter(SplitProfile.is_active == True)

    if not current_user.is_admin:
        user_profile_ids = db.query(SplitProfileUser.profile_id).filter(
            SplitProfileUser.user_id == current_user.id
        ).subquery()
        query = query.filter(SplitProfile.id.in_(user_profile_ids))

    profiles = query.order_by(SplitProfile.display_order).all()
    
    return [{
        "id": p.id,
        "name": p.name,
        "description": p.description,
        "emoji": p.emoji or '⚖️',
        "display_order": p.display_order or 0,
        "users": [{"user_id": u.user_id, "percentage": float(u.percentage)} for u in p.users]
    } for p in profiles]

@app.post(f"{settings.API_V1_PREFIX}/profiles")
async def create_profile(
    data: ProfileCreate,
    db: Session = Depends(get_db),
    _: User = Depends(require_admin)
):
    """Create split profile (admin only)"""
    total = sum(u.percentage for u in data.users)
    if not (0.9999 <= total <= 1.0001):
        raise HTTPException(status_code=400, detail=f"Percentages must sum to 100% (got {total*100}%)")
    
    profile = SplitProfile(name=data.name, description=data.description, emoji=data.emoji or '⚖️')
    db.add(profile)
    db.flush()
    
    for u in data.users:
        profile_user = SplitProfileUser(
            profile_id=profile.id,
            user_id=u.user_id,
            percentage=Decimal(str(u.percentage))
        )
        db.add(profile_user)
    
    db.commit()
    return {"id": profile.id, "name": profile.name}

@app.put(f"{settings.API_V1_PREFIX}/profiles/{{profile_id}}")
async def update_profile(
    profile_id: int,
    data: ProfileCreate,
    db: Session = Depends(get_db),
    _: User = Depends(require_admin)
):
    """Update profile (admin only). Se from_month informado, recalcula expense_splits a partir desse mês."""
    profile = db.query(SplitProfile).filter(SplitProfile.id == profile_id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    total = sum(u.percentage for u in data.users)
    if not (0.9999 <= total <= 1.0001):
        raise HTTPException(status_code=400, detail="Percentages must sum to 100%")
    
    try:
        profile.name = data.name
        profile.description = data.description
        profile.emoji = data.emoji or '⚖️'
        
        # Atualizar usuários do perfil
        db.query(SplitProfileUser).filter(SplitProfileUser.profile_id == profile_id).delete()
        for u in data.users:
            db.add(SplitProfileUser(
                profile_id=profile.id,
                user_id=u.user_id,
                percentage=Decimal(str(u.percentage))
            ))
        
        # Se from_month informado, recalcular expense_splits a partir desse mês
        splits_updated = 0
        if data.from_month:
            try:
                from_date = datetime.strptime(data.from_month + "-01", "%Y-%m-%d").date()
            except ValueError:
                raise HTTPException(status_code=400, detail="from_month deve estar no formato YYYY-MM")
            
            expenses = db.query(Expense).filter(Expense.split_profile_id == profile_id).all()
            new_users = [{"user_id": u.user_id, "percentage": float(u.percentage)} for u in data.users]
            
            for expense in expenses:
                splits_to_update = db.query(ExpenseSplit).filter(
                    ExpenseSplit.expense_id == expense.id,
                    ExpenseSplit.due_date >= from_date
                ).all()
                if not splits_to_update:
                    continue
                
                # Agrupar por installment_number
                installments_map: dict = {}
                for s in splits_to_update:
                    installments_map.setdefault(s.installment_number, []).append(s)
                
                for inst_num, inst_splits in installments_map.items():
                    installment_amount = float(inst_splits[0].installment_amount)
                    due_date = inst_splits[0].due_date
                    for old_split in inst_splits:
                        db.delete(old_split)
                    db.flush()  # garante que os deletes são processados antes dos inserts
                    for ud in new_users:
                        user_amount = round(installment_amount * ud["percentage"], 2)
                        paid_amount = installment_amount if expense.paid_by_user_id == ud["user_id"] else 0.0
                        db.add(ExpenseSplit(
                            expense_id=expense.id,
                            user_id=ud["user_id"],
                            installment_number=inst_num,
                            installment_amount=Decimal(str(installment_amount)),
                            user_percentage=Decimal(str(ud["percentage"])),
                            user_amount=Decimal(str(user_amount)),
                            paid_amount=Decimal(str(paid_amount)),
                            balance=Decimal(str(paid_amount - user_amount)),
                            due_date=due_date
                        ))
                        splits_updated += 1
        
        db.commit()
        
    except HTTPException:
        db.rollback()
        raise
    except Exception as e:
        db.rollback()
        import traceback
        print(f"❌ Erro em update_profile: {traceback.format_exc()}")
        raise HTTPException(status_code=500, detail=f"Erro ao atualizar perfil: {str(e)}")
    
    if data.from_month:
        return {"message": f"Perfil atualizado. {splits_updated} splits recalculados a partir de {data.from_month}"}
    return {"message": "Profile updated"}

@app.delete(f"{settings.API_V1_PREFIX}/profiles/{{profile_id}}")
async def delete_profile(profile_id: int, db: Session = Depends(get_db), _: User = Depends(require_admin)):
    """Delete profile (admin only) - Soft delete se tiver expenses"""
    profile = db.query(SplitProfile).filter(SplitProfile.id == profile_id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    has_expenses = db.query(Expense).filter(Expense.split_profile_id == profile_id).first()
    
    if has_expenses:
        profile.is_active = False
        db.commit()
        return {"message": "Profile deactivated", "soft_delete": True}
    else:
        db.query(SplitProfileUser).filter(SplitProfileUser.profile_id == profile_id).delete()
        db.delete(profile)
        db.commit()
        return {"message": "Profile deleted", "soft_delete": False}

@app.put(f"{settings.API_V1_PREFIX}/profiles/{{profile_id}}/reorder")
async def reorder_profile(
    profile_id: int, 
    data: dict, 
    db: Session = Depends(get_db), 
    _: User = Depends(require_admin)
):
    """Reorder profile (admin only)"""
    profile = db.query(SplitProfile).filter(SplitProfile.id == profile_id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    profile.display_order = data.get("display_order", 0)
    db.commit()
    return {"message": "Profile reordered successfully"}

@app.get(f"{settings.API_V1_PREFIX}/profiles/{{profile_id}}/expense-months")
async def list_profile_expense_months(profile_id: int, db: Session = Depends(get_db), _: User = Depends(get_current_user)):
    """List all months that have expenses with this profile"""
    months = db.query(
        func.to_char(ExpenseSplit.due_date, 'YYYY-MM').label('month')
    ).join(Expense, ExpenseSplit.expense_id == Expense.id).filter(
        Expense.split_profile_id == profile_id
    ).distinct().order_by(func.to_char(ExpenseSplit.due_date, 'YYYY-MM')).all()
    return [{"value": m[0], "label": m[0]} for m in months]

@app.put(f"{settings.API_V1_PREFIX}/profiles/{{profile_id}}/update-splits-from-month")
async def update_profile_splits_from_month(profile_id: int, data: dict, db: Session = Depends(get_db), _: User = Depends(require_admin)):
    """Update expense_splits for this profile starting from a specific month"""
    from_month = data.get("from_month")
    new_users = data.get("users", [])
    if not from_month:
        raise HTTPException(status_code=400, detail="from_month is required")
    
    from_date = datetime.strptime(from_month + "-01", "%Y-%m-%d").date()
    expenses = db.query(Expense).filter(Expense.split_profile_id == profile_id).all()
    
    updated_count = 0
    for expense in expenses:
        splits_to_update = db.query(ExpenseSplit).filter(
            ExpenseSplit.expense_id == expense.id,
            ExpenseSplit.due_date >= from_date
        ).all()
        
        if not splits_to_update:
            continue
        
        installments_map = {}
        for split in splits_to_update:
            if split.installment_number not in installments_map:
                installments_map[split.installment_number] = []
            installments_map[split.installment_number].append(split)
        
        for inst_num, inst_splits in installments_map.items():
            installment_amount = float(inst_splits[0].installment_amount)
            due_date = inst_splits[0].due_date
            
            for old_split in inst_splits:
                db.delete(old_split)
            
            for user_data in new_users:
                user_id = user_data["user_id"]
                percentage = user_data["percentage"]
                user_amount = round(installment_amount * percentage, 2)
                paid_amount = installment_amount if expense.paid_by_user_id == user_id else 0
                balance = paid_amount - user_amount
                
                new_split = ExpenseSplit(
                    expense_id=expense.id, user_id=user_id, installment_number=inst_num,
                    installment_amount=installment_amount, user_percentage=percentage,
                    user_amount=user_amount, paid_amount=paid_amount, balance=balance, due_date=due_date
                )
                db.add(new_split)
                updated_count += 1
    
    db.query(SplitProfileUser).filter(SplitProfileUser.profile_id == profile_id).delete()
    for user_data in new_users:
        db.add(SplitProfileUser(profile_id=profile_id, user_id=user_data["user_id"], percentage=user_data["percentage"]))
    
    db.commit()
    return {"message": f"Profile updated. {updated_count} splits recalculated from {from_month}"}

# ============================================================================
# EXPENSE ENDPOINTS - COM UPDATE E FILTRO POR MÊS
# ============================================================================

@app.get(f"{settings.API_V1_PREFIX}/expenses/months")
async def list_expense_months(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """List all available year-months with expense splits (filtrado pelo usuário logado)"""
    vis = visible_expense_ids_subquery(db, current_user)
    months = db.query(
        func.to_char(ExpenseSplit.due_date, 'YYYY-MM').label('month')
    ).join(Expense, ExpenseSplit.expense_id == Expense.id).filter(
        Expense.id.in_(vis)
    ).distinct().order_by(func.to_char(ExpenseSplit.due_date, 'YYYY-MM').desc()).all()
    return [{"value": m[0], "label": m[0]} for m in months]

@app.get(f"{settings.API_V1_PREFIX}/expenses/filters-for-month")
async def get_filters_for_month(month: str = Query(...), db: Session = Depends(get_db), _: User = Depends(get_current_user)):
    """Get available users and profiles for a specific month"""
    year, month_num = map(int, month.split('-'))
    start_date = date(year, month_num, 1)
    end_date = date(year + 1, 1, 1) if month_num == 12 else date(year, month_num + 1, 1)
    
    expenses_in_month = db.query(Expense.paid_by_user_id, Expense.split_profile_id).join(
        ExpenseSplit, ExpenseSplit.expense_id == Expense.id
    ).filter(ExpenseSplit.due_date >= start_date, ExpenseSplit.due_date < end_date).distinct().all()
    
    user_ids = list(set([e.paid_by_user_id for e in expenses_in_month]))
    profile_ids = list(set([e.split_profile_id for e in expenses_in_month]))
    
    users_list = db.query(User).filter(User.id.in_(user_ids)).all() if user_ids else []
    profiles_list = db.query(SplitProfile).filter(SplitProfile.id.in_(profile_ids)).all() if profile_ids else []
    
    return {
        "users": [{"id": u.id, "name": u.name, "emoji": u.emoji or '👤'} for u in users_list],
        "profiles": [{"id": p.id, "name": p.name, "emoji": p.emoji or '⚖️'} for p in profiles_list]
    }

@app.get(f"{settings.API_V1_PREFIX}/expenses/filters-for-period")
async def get_filters_for_period(start_month: str = Query(...), end_month: str = Query(...), db: Session = Depends(get_db), _: User = Depends(get_current_user)):
    """Get available users and categories for a period"""
    sy, sm = map(int, start_month.split('-'))
    ey, em = map(int, end_month.split('-'))
    start_date = date(sy, sm, 1)
    end_date = date(ey + 1, 1, 1) if em == 12 else date(ey, em + 1, 1)
    
    splits = db.query(ExpenseSplit.user_id, Expense.category_id).join(
        Expense, ExpenseSplit.expense_id == Expense.id
    ).filter(ExpenseSplit.due_date >= start_date, ExpenseSplit.due_date < end_date).distinct().all()
    
    user_ids = list(set([s.user_id for s in splits]))
    cat_ids = list(set([s.category_id for s in splits]))
    
    users_list = db.query(User).filter(User.id.in_(user_ids)).all() if user_ids else []
    cats_list = db.query(Category).filter(Category.id.in_(cat_ids)).all() if cat_ids else []
    
    return {
        "users": [{"id": u.id, "name": u.name, "emoji": u.emoji or '👤'} for u in users_list],
        "categories": [{"id": c.id, "name": c.name, "icon": c.icon or '📦'} for c in cats_list]
    }

@app.get(f"{settings.API_V1_PREFIX}/expenses")
async def list_expenses(
    month: Optional[str] = Query(None, description="Filter by YYYY-MM"),
    skip: int = Query(0, ge=0, description="Paginação: offset"),
    limit: int = Query(500, ge=1, le=1000, description="Paginação: limite"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """List expenses - OTIMIZADO com eager loading e paginação"""
    query = db.query(Expense).options(
        joinedload(Expense.paid_by),
        joinedload(Expense.category),
        joinedload(Expense.split_profile)
    )
    
    # Filtro de visibilidade: usuário só vê despesas em que está envolvido
    vis = visible_expense_ids_subquery(db, current_user)
    query = query.filter(Expense.id.in_(vis))
    
    if month:
        year, mon = map(int, month.split('-'))
        start_date, end_date = _month_date_range(year, mon)
        expense_ids_subquery = db.query(ExpenseSplit.expense_id).filter(
            ExpenseSplit.due_date >= start_date,
            ExpenseSplit.due_date < end_date
        ).distinct().subquery()
        query = query.filter(Expense.id.in_(expense_ids_subquery))

    expenses = query.order_by(Expense.expense_date.desc()).offset(skip).limit(limit).all()

    return [{
        "id": e.id,
        "description": e.description,
        "total_amount": float(e.total_amount),
        "installments": e.installments,
        "expense_date": str(e.expense_date),
        "original_date": str(e.original_date) if e.original_date else str(e.expense_date),
        "payment_method": e.payment_method or 'pix',
        "paid_by_user_id": e.paid_by_user_id,
        "paid_by_name": e.paid_by.name,
        "category_id": e.category_id,
        "category_name": e.category.name,
        "category_emoji": e.category.icon,
        "split_profile_id": e.split_profile_id,
        "profile_name": e.split_profile.name,
        "notes": e.notes
    } for e in expenses]

@app.get(f"{settings.API_V1_PREFIX}/expenses/with-splits")
async def list_expenses_with_splits(
    month: Optional[str] = Query(None, description="Filter by YYYY-MM"),
    skip: int = Query(0, ge=0, description="Paginação: offset"),
    limit: int = Query(500, ge=1, le=1000, description="Paginação: limite"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """List expenses with their splits - OTIMIZADO"""
    # Filtro de visibilidade
    vis = visible_expense_ids_subquery(db, current_user)

    if month:
        year, mon = map(int, month.split('-'))
        start_date, end_date = _month_date_range(year, mon)
        expense_ids_subquery = db.query(ExpenseSplit.expense_id).filter(
            ExpenseSplit.due_date >= start_date,
            ExpenseSplit.due_date < end_date
        ).distinct().subquery()

        q = db.query(Expense).options(
            joinedload(Expense.paid_by),
            joinedload(Expense.category),
            joinedload(Expense.split_profile)
        ).filter(Expense.id.in_(expense_ids_subquery)).filter(Expense.id.in_(vis))
        expenses = q.order_by(Expense.expense_date.desc()).offset(skip).limit(limit).all()

        expense_ids = [e.id for e in expenses]
        splits_query = db.query(ExpenseSplit).options(
            joinedload(ExpenseSplit.user)
        ).filter(
            ExpenseSplit.expense_id.in_(expense_ids),
            ExpenseSplit.due_date >= start_date,
            ExpenseSplit.due_date < end_date
        ).all() if expense_ids else []

    else:
        q = db.query(Expense).options(
            joinedload(Expense.paid_by),
            joinedload(Expense.category),
            joinedload(Expense.split_profile)
        ).filter(Expense.id.in_(vis))
        expenses = q.order_by(Expense.expense_date.desc()).offset(skip).limit(limit).all()
        
        expense_ids = [e.id for e in expenses]
        splits_query = db.query(ExpenseSplit).options(
            joinedload(ExpenseSplit.user)
        ).filter(ExpenseSplit.expense_id.in_(expense_ids)).all() if expense_ids else []
    
    splits_by_expense = {}
    for s in splits_query:
        splits_by_expense.setdefault(s.expense_id, []).append(s)
    
    result = []
    for e in expenses:
        splits = splits_by_expense.get(e.id, [])
        result.append({
            "id": e.id,
            "description": e.description,
            "total_amount": float(e.total_amount),
            "installments": e.installments,
            "expense_date": str(e.expense_date),
            "original_date": str(e.original_date) if e.original_date else str(e.expense_date),
            "payment_method": e.payment_method or 'pix',
            "paid_by_user_id": e.paid_by_user_id,
            "paid_by_name": e.paid_by.name,
            "category_id": e.category_id,
            "category_name": e.category.name,
            "category_emoji": e.category.icon,
            "split_profile_id": e.split_profile_id,
            "profile_name": e.split_profile.name,
            "notes": e.notes,
            "splits": [{
                "id": s.id,
                "user_id": s.user_id,
                "user_name": s.user.name,
                "installment_number": s.installment_number,
                "due_date": str(s.due_date),
                "installment_amount": float(s.installment_amount),
                "user_percentage": float(s.user_percentage) * 100 if s.user_percentage else 0,
                "user_amount": float(s.user_amount),
                "paid_amount": float(s.paid_amount) if s.paid_amount is not None else 0,
                "balance": float(s.balance) if s.balance is not None else 0,
            } for s in splits]
        })
    
    return result

@app.post(f"{settings.API_V1_PREFIX}/expenses")
async def create_expense(
    data: ExpenseCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Create new expense"""
    expense_date_obj = date.fromisoformat(data.expense_date)

    # Cartão: se data > fechamento (vencimento − 7 dias) → jogar pro próximo mês
    payment_method = data.payment_method or 'pix'
    original_date = expense_date_obj  # sempre guardar a data real de lançamento
    if payment_method == 'cartao':
        import calendar as _cal
        from datetime import timedelta as _td
        payer = db.query(User).filter(User.id == data.paid_by_user_id).first()
        due_day = (payer.invoice_due_day or 1) if payer else 1
        # Calcular próxima data de vencimento (1º do próximo mês + due_day - 1)
        exp = expense_date_obj
        if exp.month == 12:
            next_due = exp.replace(year=exp.year + 1, month=1, day=due_day)
        else:
            max_next = _cal.monthrange(exp.year, exp.month + 1)[1]
            next_due = exp.replace(month=exp.month + 1, day=min(due_day, max_next))
        # Fechamento = vencimento - 7 dias; lança no próximo mês se data > fechamento
        closing = next_due - _td(days=7)
        if expense_date_obj > closing:
            # Avançar expense_date para o mês do vencimento (mantém o dia original, clampado)
            max_day = _cal.monthrange(next_due.year, next_due.month)[1]
            next_day = min(expense_date_obj.day, max_day)
            expense_date_obj = expense_date_obj.replace(year=next_due.year, month=next_due.month, day=next_day)
    
    expense = ExpenseService.create_expense(
        db=db,
        paid_by_user_id=data.paid_by_user_id,
        category_id=data.category_id,
        split_profile_id=data.split_profile_id,
        description=data.description,
        total_amount=Decimal(str(data.total_amount)),
        expense_date=expense_date_obj,
        installments=data.installments,
        notes=data.notes,
        created_by_user_id=current_user.id,
        payment_method=payment_method,
        original_date=original_date
    )
    
    # Enviar push notification para outros usuários do perfil
    try:
        FirebaseService.send_to_profile_users(
            db=db,
            profile_id=expense.split_profile_id,
            exclude_user_id=current_user.id,
            title="💸 Despesa adicionada",
            body=("{current_user.name} adicionou:\n{icon} {desc} - R$ {amt}".format(
                current_user=current_user,
                icon=expense.category.icon or '',
                desc=expense.description,
                amt=f"{float(expense.total_amount):.2f}".replace('.', ',')
            )),
            data={"expense_id": str(expense.id), "action": "new_expense"},
            action_type="new"
        )
    except Exception as e:
        print(f"⚠️ Erro ao enviar push: {e}")
    
    return {"id": expense.id, "description": expense.description, "message": "Expense created"}

@app.put(f"{settings.API_V1_PREFIX}/expenses/{{expense_id}}")
async def update_expense(
    expense_id: int,
    data: ExpenseCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Update expense - mantém o ID original (UPDATE real)"""
    expense_date_obj = date.fromisoformat(data.expense_date)

    # Cartão: se data > fechamento (vencimento − 7 dias) → jogar pro próximo mês
    payment_method = data.payment_method or 'pix'
    original_date = expense_date_obj  # sempre guardar a data real de lançamento
    if payment_method == 'cartao':
        import calendar as _cal
        from datetime import timedelta as _td
        payer = db.query(User).filter(User.id == data.paid_by_user_id).first()
        due_day = (payer.invoice_due_day or 1) if payer else 1
        # Calcular próxima data de vencimento (1º do próximo mês + due_day - 1)
        exp = expense_date_obj
        if exp.month == 12:
            next_due = exp.replace(year=exp.year + 1, month=1, day=due_day)
        else:
            max_next = _cal.monthrange(exp.year, exp.month + 1)[1]
            next_due = exp.replace(month=exp.month + 1, day=min(due_day, max_next))
        # Fechamento = vencimento - 7 dias; lança no próximo mês se data > fechamento
        closing = next_due - _td(days=7)
        if expense_date_obj > closing:
            # Avançar expense_date para o mês do vencimento (mantém o dia original, clampado)
            max_day = _cal.monthrange(next_due.year, next_due.month)[1]
            next_day = min(expense_date_obj.day, max_day)
            expense_date_obj = expense_date_obj.replace(year=next_due.year, month=next_due.month, day=next_day)

    # UPDATE real - mantém o ID
    expense = ExpenseService.update_expense(
        db=db,
        expense_id=expense_id,
        paid_by_user_id=data.paid_by_user_id,
        category_id=data.category_id,
        split_profile_id=data.split_profile_id,
        description=data.description,
        total_amount=Decimal(str(data.total_amount)),
        expense_date=expense_date_obj,
        installments=data.installments,
        notes=data.notes,
        updated_by_user_id=current_user.id,
        payment_method=payment_method,
        original_date=original_date
    )
    
    # Enviar push notification para outros usuários do perfil
    try:
        FirebaseService.send_to_profile_users(
            db=db,
            profile_id=expense.split_profile_id,
            exclude_user_id=current_user.id,
            title="✏️ Despesa editada",
            body=("{current_user.name} editou:\n{icon} {desc} - R$ {amt}".format(
                current_user=current_user,
                icon=expense.category.icon or '',
                desc=expense.description,
                amt=f"{float(expense.total_amount):.2f}".replace('.', ',')
            )),
            data={"expense_id": str(expense.id), "action": "edit_expense"},
            action_type="edit"
        )
    except Exception as e:
        print(f"⚠️ Erro ao enviar push: {e}")
    
    return {"id": expense.id, "message": "Expense updated"}

@app.delete(f"{settings.API_V1_PREFIX}/expenses/{{expense_id}}")
async def delete_expense(expense_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """Delete expense"""
    # Buscar despesa antes de deletar (para enviar notificação)
    expense = db.query(Expense).filter(Expense.id == expense_id).first()
    
    if expense:
        # Salvar info para notificação
        profile_id = expense.split_profile_id
        description = expense.description
        
        # Deletar despesa
        ExpenseService.delete_expense(db, expense_id)
        
        # Enviar push notification
        try:
            FirebaseService.send_to_profile_users(
                db=db,
                profile_id=profile_id,
                exclude_user_id=current_user.id,
                title="🗑️ Despesa deletada",
                body=f"{current_user.name} deletou: {expense.category.icon or ''} {description}",
                data={"action": "delete_expense"},
                action_type="delete"
            )
        except Exception as e:
            print(f"⚠️ Erro ao enviar push: {e}")
    else:
        ExpenseService.delete_expense(db, expense_id)
    
    return {"message": "Expense deleted"}


# ============================================================================
# DASHBOARD ENDPOINT - AGREGADO (1 request em vez de 5)
# ============================================================================

@app.get(f"{settings.API_V1_PREFIX}/dashboard")
async def get_dashboard(
    month: Optional[str] = Query(None, description="Filter by YYYY-MM"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Endpoint agregado para Dashboard - retorna TUDO em 1 request.
    
    Substitui 5 requests separados:
    - GET /users
    - GET /categories  
    - GET /profiles
    - GET /expenses/with-splits
    - GET /balances
    """
    
    # 1. Users (dados estáticos)
    users_list = db.query(User).filter(User.is_active == True).order_by(User.display_order).all()
    users_data = [{
        "id": u.id, 
        "name": u.name, 
        "email": u.email, 
        "color": u.color or '#3B82F6', 
        "emoji": u.emoji or '👤', 
        "display_order": u.display_order or 0, 
        "is_admin": u.is_admin,
    } for u in users_list]
    
    # 2. Categories (dados estáticos)
    try:
        cats_list = db.query(Category).filter(Category.is_active == True).order_by(Category.display_order, Category.id).all()
    except Exception:
        cats_list = db.query(Category).filter(Category.is_active == True).order_by(Category.id).all()
    categories_data = [{
        "id": c.id, 
        "name": c.name, 
        "description": c.description, 
        "icon": c.icon, 
        "color": c.color,
        "ipca_category_code": c.ipca_category_code,
        "ipca_category_name": c.ipca_category_name
    } for c in cats_list]
    
    # 3. Profiles (dados estáticos)
    profiles_list = db.query(SplitProfile).options(
        joinedload(SplitProfile.users)
    ).filter(
        SplitProfile.is_active == True
    ).order_by(SplitProfile.display_order).all()
    profiles_data = [{
        "id": p.id,
        "name": p.name,
        "description": p.description,
        "emoji": p.emoji or '⚖️',
        "display_order": p.display_order or 0,
        "users": [{"user_id": u.user_id, "percentage": float(u.percentage)} for u in p.users]
    } for p in profiles_list]
    
    # 4. Expenses with splits (dados dinâmicos filtrados por mês + visibilidade)
    # Filtro de visibilidade: usuário só vê despesas em que está envolvido
    vis = visible_expense_ids_subquery(db, current_user)

    dash_start_date = dash_end_date = None
    if month:
        dash_year, dash_mon = map(int, month.split('-'))
        dash_start_date, dash_end_date = _month_date_range(dash_year, dash_mon)
        expense_ids_subquery = db.query(ExpenseSplit.expense_id).filter(
            ExpenseSplit.due_date >= dash_start_date,
            ExpenseSplit.due_date < dash_end_date
        ).distinct().subquery()

        q = db.query(Expense).options(
            joinedload(Expense.paid_by),
            joinedload(Expense.category),
            joinedload(Expense.split_profile)
        ).filter(Expense.id.in_(expense_ids_subquery)).filter(Expense.id.in_(vis))
        expenses_query = q.order_by(Expense.expense_date.desc()).all()

        expense_ids = [e.id for e in expenses_query]
        splits_query = db.query(ExpenseSplit).options(
            joinedload(ExpenseSplit.user)
        ).filter(
            ExpenseSplit.expense_id.in_(expense_ids),
            ExpenseSplit.due_date >= dash_start_date,
            ExpenseSplit.due_date < dash_end_date
        ).all() if expense_ids else []
    else:
        q = db.query(Expense).options(
            joinedload(Expense.paid_by),
            joinedload(Expense.category),
            joinedload(Expense.split_profile)
        ).filter(Expense.id.in_(vis))
        expenses_query = q.order_by(Expense.expense_date.desc()).limit(500).all()

        expense_ids = [e.id for e in expenses_query]
        splits_query = db.query(ExpenseSplit).options(
            joinedload(ExpenseSplit.user)
        ).filter(ExpenseSplit.expense_id.in_(expense_ids)).all() if expense_ids else []
    
    # Agrupar splits por expense_id
    splits_by_expense = {}
    for s in splits_query:
        if s.expense_id not in splits_by_expense:
            splits_by_expense[s.expense_id] = []
        splits_by_expense[s.expense_id].append(s)
    
    expenses_data = []
    for e in expenses_query:
        splits = splits_by_expense.get(e.id, [])
        expenses_data.append({
            "id": e.id,
            "description": e.description,
            "total_amount": float(e.total_amount),
            "installments": e.installments,
            "expense_date": str(e.expense_date),
            "original_date": str(e.original_date) if e.original_date else str(e.expense_date),
            "payment_method": e.payment_method or 'pix',
            "paid_by_user_id": e.paid_by_user_id,
            "paid_by_name": e.paid_by.name,
            "category_id": e.category_id,
            "category_name": e.category.name,
            "category_emoji": e.category.icon,
            "split_profile_id": e.split_profile_id,
            "profile_name": e.split_profile.name,
            "notes": e.notes,
            "splits": [{
                "id": s.id,
                "user_id": s.user_id,
                "user_name": s.user.name,
                "installment_number": s.installment_number,
                "due_date": str(s.due_date),
                "installment_amount": float(s.installment_amount),
                "user_percentage": float(s.user_percentage) * 100 if s.user_percentage else 0,
                "user_amount": float(s.user_amount),
                "paid_amount": float(s.paid_amount) if s.paid_amount is not None else 0,
                "balance": float(s.balance) if s.balance is not None else 0,
            } for s in splits]
        })
    
    # 5. Balances — 1 query com GROUP BY em vez de N queries (uma por usuário)
    bal_q = db.query(
        ExpenseSplit.user_id,
        func.coalesce(func.sum(ExpenseSplit.balance), 0).label('balance'),
        func.coalesce(func.sum(ExpenseSplit.paid_amount), 0).label('total_paid'),
        func.coalesce(func.sum(ExpenseSplit.user_amount), 0).label('total_owed')
    )
    if dash_start_date:
        bal_q = bal_q.filter(
            ExpenseSplit.due_date >= dash_start_date,
            ExpenseSplit.due_date < dash_end_date
        )
    bal_by_user = {row.user_id: row for row in bal_q.group_by(ExpenseSplit.user_id).all()}

    balances_data = []
    for user in users_list:
        row = bal_by_user.get(user.id)
        balance = float(row.balance) if row else 0.0
        balances_data.append({
            "user_id": user.id,
            "user_name": user.name,
            "balance": balance,
            "to_receive": balance if balance > 0 else 0,
            "to_pay": -balance if balance < 0 else 0,
            "total_paid": float(row.total_paid) if row else 0.0,
            "total_owed": float(row.total_owed) if row else 0.0
        })
    
    # 6. Totais pré-calculados
    totals = {
        "period": sum(float(e["total_amount"]) for e in expenses_data) if not month else 0,
        "by_category": {},
        "by_user": {}
    }
    
    # Calcular total do período baseado nas parcelas (não no total das despesas)
    if month:
        period_total = 0
        seen_installments = set()
        
        for expense in expenses_data:
            for split in expense["splits"]:
                split_date = split["due_date"]
                if split_date.startswith(month):
                    key = f"{expense['id']}-{split['installment_number']}"
                    if key not in seen_installments:
                        seen_installments.add(key)
                        period_total += split["installment_amount"]
        
        totals["period"] = period_total
    
    return {
        "users": users_data,
        "categories": categories_data,
        "profiles": profiles_data,
        "expenses": expenses_data,
        "balances": balances_data,
        "totals": totals,
        "current_user_id": current_user.id
    }


@app.get(f"{settings.API_V1_PREFIX}/balances")
async def get_balances(
    month: Optional[str] = Query(None, description="Filter by YYYY-MM"),
    db: Session = Depends(get_db),
    _: User = Depends(get_current_user)
):
    """
    Get balances — 1 query GROUP BY em vez de N queries (uma por usuário)
    """
    users = db.query(User).filter(User.is_active == True).all()

    bal_q = db.query(
        ExpenseSplit.user_id,
        func.coalesce(func.sum(ExpenseSplit.balance), 0).label('balance'),
        func.coalesce(func.sum(ExpenseSplit.paid_amount), 0).label('total_paid'),
        func.coalesce(func.sum(ExpenseSplit.user_amount), 0).label('total_owed')
    )
    if month:
        year, mon = map(int, month.split('-'))
        start_date, end_date = _month_date_range(year, mon)
        bal_q = bal_q.filter(
            ExpenseSplit.due_date >= start_date,
            ExpenseSplit.due_date < end_date
        )
    bal_by_user = {row.user_id: row for row in bal_q.group_by(ExpenseSplit.user_id).all()}

    balances = []
    for user in users:
        row = bal_by_user.get(user.id)
        balance = float(row.balance) if row else 0.0
        balances.append({
            "user_id": user.id,
            "user_name": user.name,
            "balance": balance,
            "to_receive": balance if balance > 0 else 0,
            "to_pay": -balance if balance < 0 else 0,
            "total_paid": float(row.total_paid) if row else 0.0,
            "total_owed": float(row.total_owed) if row else 0.0
        })

    return balances

@app.get(f"{settings.API_V1_PREFIX}/expenses/{{expense_id}}/splits")
async def get_expense_splits(expense_id: int, db: Session = Depends(get_db), _: User = Depends(get_current_user)):
    """Get splits for an expense"""
    splits = db.query(ExpenseSplit).filter(ExpenseSplit.expense_id == expense_id).all()
    return [{
        "id": s.id,
        "user_id": s.user_id,
        "user_name": s.user.name,
        "installment_number": s.installment_number,
        "due_date": str(s.due_date),
        "installment_amount": float(s.installment_amount),
        "user_percentage": float(s.user_percentage) * 100 if s.user_percentage else 0,
        "user_amount": float(s.user_amount),
        "paid_amount": float(s.paid_amount) if s.paid_amount is not None else 0,
        "balance": float(s.balance) if s.balance is not None else 0,
    } for s in splits]


# ============================================================================
# DEBUG ENDPOINTS - NOTIFICAÇÕES PUSH
# ============================================================================

@app.get(f"{settings.API_V1_PREFIX}/debug/tokens")
async def debug_list_tokens(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Lista todos os tokens registrados (apenas admin)"""
    if not current_user.is_admin:
        raise HTTPException(status_code=403, detail="Admin only")
    
    tokens = db.query(DeviceToken).all()
    users = {u.id: u.name for u in db.query(User).all()}
    
    return [
        {
            "id": t.id,
            "user_id": t.user_id,
            "user_name": users.get(t.user_id, "?"),
            "token": t.token[:30] + "..." if len(t.token) > 30 else t.token,
            "token_full": t.token,
            "created_at": str(t.created_at),
            "updated_at": str(t.updated_at)
        }
        for t in tokens
    ]


@app.get(f"{settings.API_V1_PREFIX}/debug/my-tokens")
async def debug_my_tokens(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Lista tokens do usuário atual"""
    tokens = db.query(DeviceToken).filter(DeviceToken.user_id == current_user.id).all()
    
    return {
        "user_id": current_user.id,
        "user_name": current_user.name,
        "token_count": len(tokens),
        "tokens": [
            {
                "id": t.id,
                "token": t.token[:40] + "...",
                "created_at": str(t.created_at)
            }
            for t in tokens
        ]
    }


@app.post(f"{settings.API_V1_PREFIX}/debug/test-push")
async def debug_test_push(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Envia notificação de teste para TODOS os outros usuários"""
    try:
        # Buscar todos os tokens EXCETO do usuário atual
        tokens = db.query(DeviceToken).filter(
            DeviceToken.user_id != current_user.id
        ).all()
        
        if not tokens:
            return {
                "success": False,
                "message": "Nenhum token de outros usuários encontrado",
                "debug": {
                    "current_user_id": current_user.id,
                    "current_user_name": current_user.name
                }
            }
        
        token_list = [t.token for t in tokens]
        
        result = FirebaseService.send_push(
            tokens=token_list,
            title="🧪 TESTE de Notificação",
            body=f"Enviado por {current_user.name} às {datetime.now().strftime('%H:%M:%S')}",
            data={"action": "test", "sender": current_user.name}
        )
        
        return {
            "success": True,
            "message": f"Push enviado para {len(token_list)} dispositivos",
            "result": result,
            "tokens_sent_to": [t.token[:30] + "..." for t in tokens]
        }
        
    except Exception as e:
        return {
            "success": False,
            "error": str(e),
            "error_type": type(e).__name__
        }


@app.post(f"{settings.API_V1_PREFIX}/debug/test-push-self")
async def debug_test_push_self(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Envia notificação de teste para o PRÓPRIO usuário"""
    try:
        # Buscar tokens do usuário atual
        tokens = db.query(DeviceToken).filter(
            DeviceToken.user_id == current_user.id
        ).all()
        
        if not tokens:
            return {
                "success": False,
                "message": "Você não tem nenhum token registrado!",
                "help": "Habilite as notificações no app primeiro"
            }
        
        token_list = [t.token for t in tokens]
        
        result = FirebaseService.send_push(
            tokens=token_list,
            title="🎉 Auto-Teste Funcionou!",
            body=f"Notificação recebida às {datetime.now().strftime('%H:%M:%S')}",
            data={"action": "self_test"}
        )
        
        return {
            "success": True,
            "message": f"Push enviado para {len(token_list)} de seus dispositivos",
            "result": result
        }
        
    except Exception as e:
        return {
            "success": False,
            "error": str(e),
            "error_type": type(e).__name__
        }



# ============================================================================
# NOTIFICATION PREFERENCES
# ============================================================================

@app.get(f"{settings.API_V1_PREFIX}/notification-preferences")
async def get_notification_preferences(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get notification preferences for current user"""
    from models import NotificationPreferences
    
    prefs = db.query(NotificationPreferences).filter(
        NotificationPreferences.user_id == current_user.id
    ).first()
    
    if not prefs:
        # Retornar defaults se não existir
        return {
            "notify_new_expense": True,
            "notify_edit_expense": False,
            "notify_delete_expense": False,
            "notify_reminders": True,
            "reminder_time": "09:00"
        }
    
    return {
        "notify_new_expense": prefs.notify_new_expense,
        "notify_edit_expense": prefs.notify_edit_expense,
        "notify_delete_expense": prefs.notify_delete_expense,
        "notify_reminders": prefs.notify_reminders,
        "reminder_time": prefs.reminder_time
    }


@app.put(f"{settings.API_V1_PREFIX}/notification-preferences")
async def update_notification_preferences(
    data: NotificationPreferencesUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Update notification preferences for current user"""
    from models import NotificationPreferences
    
    prefs = db.query(NotificationPreferences).filter(
        NotificationPreferences.user_id == current_user.id
    ).first()
    
    if not prefs:
        # Criar se não existir
        prefs = NotificationPreferences(
            user_id=current_user.id,
            notify_new_expense=data.notify_new_expense,
            notify_edit_expense=data.notify_edit_expense,
            notify_delete_expense=data.notify_delete_expense,
            notify_reminders=data.notify_reminders,
            reminder_time=data.reminder_time
        )
        db.add(prefs)
    else:
        # Atualizar existente
        prefs.notify_new_expense = data.notify_new_expense
        prefs.notify_edit_expense = data.notify_edit_expense
        prefs.notify_delete_expense = data.notify_delete_expense
        prefs.notify_reminders = data.notify_reminders
        prefs.reminder_time = data.reminder_time
    
    db.commit()
    
    return {"message": "Preferences updated"}


@app.get(f"{settings.API_V1_PREFIX}/debug/firebase-status")
async def debug_firebase_status():
    """Verifica status do Firebase Admin SDK"""
    return {
        "firebase_initialized": FirebaseService._app is not None,
        "project_id": FirebaseService._app.project_id if FirebaseService._app else None
    }


@app.get(f"{settings.API_V1_PREFIX}/debug/cross-user-check")
async def debug_cross_user_check(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Diagnóstico completo de por que notificações cross-user não funcionam
    """
    try:
        result = {
            "current_user": {
                "id": current_user.id,
                "name": current_user.name
            },
            "profiles": [],
            "all_tokens": [],
            "diagnosis": []
        }
        
        # 1. Buscar todos os perfis onde o usuário atual está
        my_profiles = db.query(SplitProfileUser).filter(
            SplitProfileUser.user_id == current_user.id
        ).all()
        
        if not my_profiles:
            result["diagnosis"].append("❌ Você não está em nenhum perfil de divisão!")
            return result
        
        # 2. Para cada perfil, verificar quem mais está nele
        for mp in my_profiles:
            profile = db.query(SplitProfile).filter(SplitProfile.id == mp.profile_id).first()
            
            # Outros usuários no mesmo perfil
            other_users_in_profile = db.query(SplitProfileUser).filter(
                SplitProfileUser.profile_id == mp.profile_id,
                SplitProfileUser.user_id != current_user.id
            ).all()
            
            profile_info = {
                "profile_id": mp.profile_id,
                "profile_name": profile.name if profile else "?",
                "other_users": []
            }
            
            for ou in other_users_in_profile:
                user = db.query(User).filter(User.id == ou.user_id).first()
                
                # Tokens desse usuário
                tokens = db.query(DeviceToken).filter(DeviceToken.user_id == ou.user_id).all()
                
                profile_info["other_users"].append({
                    "user_id": ou.user_id,
                    "user_name": user.name if user else "?",
                    "token_count": len(tokens),
                    "tokens": [t.token[:30] + "..." for t in tokens]
                })
            
            if not other_users_in_profile:
                result["diagnosis"].append(f"⚠️ Perfil '{profile.name if profile else '?'}': Você é o único usuário!")
            else:
                users_with_tokens = sum(1 for u in profile_info["other_users"] if u["token_count"] > 0)
                users_without_tokens = sum(1 for u in profile_info["other_users"] if u["token_count"] == 0)
                
                if users_without_tokens > 0:
                    names = [u["user_name"] for u in profile_info["other_users"] if u["token_count"] == 0]
                    result["diagnosis"].append(
                        f"⚠️ Perfil '{profile.name if profile else '?'}': {', '.join(names)} não tem token registrado!"
                    )
                
                if users_with_tokens > 0:
                    result["diagnosis"].append(
                        f"✅ Perfil '{profile.name if profile else '?'}': {users_with_tokens} usuário(s) podem receber push"
                    )
            
            result["profiles"].append(profile_info)
        
        # 3. Listar todos os tokens no sistema
        all_tokens = db.query(DeviceToken).all()
        for t in all_tokens:
            user = db.query(User).filter(User.id == t.user_id).first()
            result["all_tokens"].append({
                "user_id": t.user_id,
                "user_name": user.name if user else "?",
                "token": t.token[:30] + "...",
                "is_current_user": t.user_id == current_user.id
            })
        
        # 4. Resumo final
        if not result["diagnosis"]:
            result["diagnosis"].append("✅ Tudo parece OK! Verifique os logs do servidor ao criar despesa.")
        
        return result
        
    except Exception as e:
        import traceback
        return {
            "error": str(e),
            "traceback": traceback.format_exc(),
            "current_user_id": current_user.id if current_user else None
        }

# ============================================================================
# TARGET ENDPOINTS
# ============================================================================

def _target_dict(t: Target) -> dict:
    return {
        "id": t.id,
        "user_id": t.user_id,
        "name": t.name,
        "emoji": t.emoji,
        "monthly_amount": float(t.monthly_amount),
        "category_ids": json.loads(t.category_ids) if t.category_ids else [],
        "payment_methods": json.loads(t.payment_methods) if t.payment_methods else [],
        "display_mode": t.display_mode,
        "ticket_months": t.ticket_months,
        "sort_order": t.sort_order,
    }

@app.get(f"{settings.API_V1_PREFIX}/targets")
async def list_targets(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """List targets for the current user, ordered by sort_order."""
    targets = db.query(Target).filter(
        Target.user_id == current_user.id, Target.is_active == True
    ).order_by(Target.sort_order).all()
    return [_target_dict(t) for t in targets]

@app.post(f"{settings.API_V1_PREFIX}/targets")
async def create_target(data: TargetCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """Create a new target for the current user."""
    max_order = db.query(func.max(Target.sort_order)).filter(Target.user_id == current_user.id).scalar() or 0
    target = Target(
        user_id=current_user.id,
        name=data.name,
        emoji=data.emoji,
        monthly_amount=Decimal(str(data.monthly_amount)),
        category_ids=json.dumps(data.category_ids) if data.category_ids else None,
        payment_methods=json.dumps(data.payment_methods) if data.payment_methods else None,
        display_mode=data.display_mode,
        ticket_months=data.ticket_months,
        sort_order=max_order + 1,
    )
    db.add(target)
    db.commit()
    db.refresh(target)
    return _target_dict(target)

@app.put(f"{settings.API_V1_PREFIX}/targets/{{target_id}}")
async def update_target(target_id: int, data: TargetCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """Update a target (owner only)."""
    target = db.query(Target).filter(Target.id == target_id, Target.user_id == current_user.id).first()
    if not target:
        raise HTTPException(status_code=404, detail="Target not found")
    target.name = data.name
    target.emoji = data.emoji
    target.monthly_amount = Decimal(str(data.monthly_amount))
    target.category_ids = json.dumps(data.category_ids) if data.category_ids else None
    target.payment_methods = json.dumps(data.payment_methods) if data.payment_methods else None
    target.display_mode = data.display_mode
    target.ticket_months = data.ticket_months
    db.commit()
    return _target_dict(target)

@app.delete(f"{settings.API_V1_PREFIX}/targets/{{target_id}}")
async def delete_target(target_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """Delete (soft) a target (owner only)."""
    target = db.query(Target).filter(Target.id == target_id, Target.user_id == current_user.id).first()
    if not target:
        raise HTTPException(status_code=404, detail="Target not found")
    target.is_active = False
    db.commit()
    return {"message": "Target deleted"}

@app.put(f"{settings.API_V1_PREFIX}/targets/{{target_id}}/reorder")
async def reorder_target(target_id: int, data: dict, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """Update sort_order of a target (owner only)."""
    target = db.query(Target).filter(Target.id == target_id, Target.user_id == current_user.id).first()
    if not target:
        raise HTTPException(status_code=404, detail="Target not found")
    target.sort_order = data.get("sort_order", 0)
    db.commit()
    return {"message": "Reordered"}

@app.get(f"{settings.API_V1_PREFIX}/targets/{{target_id}}/stats")
async def get_target_stats(
    target_id: int,
    month: str = Query(..., description="Current month YYYY-MM"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Calculates inflation-adjusted avg ticket for a target.
    Returns:
      avg_ticket_adj: float — avg spend per transaction (adj) over last ticket_months
      times_left: float | None — how many more transactions fit in remaining budget
      remaining: float — target - spent this month
      spent: float — amount spent this month in target categories
    """
    from sqlalchemy import text
    from collections import defaultdict

    target = db.query(Target).filter(Target.id == target_id, Target.user_id == current_user.id).first()
    if not target:
        raise HTTPException(status_code=404, detail="Target not found")

    cat_ids = set(json.loads(target.category_ids)) if target.category_ids else set()
    pm_filter_list = json.loads(target.payment_methods) if target.payment_methods else []
    current_year, current_mon = map(int, month.split('-'))

    # ── 1. Get available IPCA months for this location ──
    user_d1c = current_user.preferred_ipca_location or 1
    ipca_months_raw = db.execute(text(
        'SELECT DISTINCT "D3C" FROM ipca WHERE "D1C" = :d1c AND "D2C" = 63 AND "V" IS NOT NULL ORDER BY "D3C" DESC'
    ), {"d1c": user_d1c}).fetchall()
    available_ipca_months = {row[0] for row in ipca_months_raw}  # set of YYYYMM ints

    # ── 2. Build history months — only months that have IPCA data, going back ticket_months ──
    history_months = []
    y, m = current_year, current_mon
    attempts = 0
    while len(history_months) < target.ticket_months and attempts < 120:
        m -= 1
        if m == 0:
            m = 12; y -= 1
        attempts += 1
        month_int = y * 100 + m
        if month_int in available_ipca_months:
            history_months.append(month_int)

    all_months_needed = history_months + [current_year * 100 + current_mon]

    # ── 2. Fetch expense splits for those months ──
    cat_filter = ""
    pm_sql_filter = ""
    params: dict = {"uid": current_user.id}
    if cat_ids:
        cat_filter = f"AND e.category_id = ANY(:cats)"
        params["cats"] = list(cat_ids)
    if pm_filter_list:
        pm_sql_filter = "AND e.payment_method = ANY(:pms)"
        params["pms"] = pm_filter_list

    rows = db.execute(text(f"""
        SELECT es.user_amount, es.due_date, e.category_id, c.ipca_category_code,
               COALESCE(es.user_percentage, 1.0) as user_pct
        FROM expense_splits es
        JOIN expenses e ON es.expense_id = e.id
        JOIN categories c ON e.category_id = c.id
        WHERE es.user_id = :uid
          AND (EXTRACT(YEAR FROM es.due_date)*100 + EXTRACT(MONTH FROM es.due_date)) = ANY(:months)
          {cat_filter}
          {pm_sql_filter}
        ORDER BY es.due_date
    """), {**params, "months": all_months_needed}).fetchall()

    if not rows:
        return {"avg_ticket_adj": None, "times_left": None, "remaining": float(target.monthly_amount), "spent": 0.0}

    # ── 3. Fetch IPCA rates (D2C=63 monthly, localidade do usuário) ──
    unique_codes = {r[3] for r in rows if r[3]}
    ipca_dict: dict = {}
    if unique_codes:
        ipca_rows = db.execute(text("""
            SELECT "D4C", "D3C", "V" FROM ipca
            WHERE "D1C" = :d1c AND "D2C" = 63 AND "V" IS NOT NULL
              AND "D4C" = ANY(:codes)
        """), {"d1c": user_d1c, "codes": list(unique_codes)}).fetchall()
        ipca_dict = {(r[0], r[1]): float(r[2]) for r in ipca_rows}

    # Suffix-sum: v_accum[code][month_int] = sum of IPCA for months AFTER month_int
    max_month_int = current_year * 100 + current_mon
    v_accum_cache: dict = {}
    for code in unique_codes:
        running = 0.0
        v_accum_cache[code] = {}
        for m_int in sorted(all_months_needed, reverse=True):
            v_accum_cache[code][m_int] = running
            running += ipca_dict.get((code, m_int), 0.0)

    # ── 4. Compute spent (current month) and history transactions ──
    current_month_int = current_year * 100 + current_mon
    spent_nominal = 0.0
    history_adj_amounts = []
    history_adj_by_date: dict = {}   # date → total adj (for ticket_day)

    for user_amount, due_date, category_id, ipca_code, user_pct in rows:
        m_int = due_date.year * 100 + due_date.month
        v_accum = v_accum_cache.get(ipca_code, {}).get(m_int, 0.0) if ipca_code else 0.0
        adj = float(user_amount) * (1 + v_accum / 100)

        if m_int == current_month_int:
            spent_nominal += float(user_amount)
        else:
            history_adj_amounts.append(adj)
            history_adj_by_date[due_date] = history_adj_by_date.get(due_date, 0.0) + adj

    # ── 5. Avg ticket (per-transaction or per-day depending on mode) ──
    avg_ticket_adj = None
    times_left = None
    remaining = float(target.monthly_amount) - spent_nominal

    if target.display_mode == 'ticket_day':
        # ticket/day = total adj spend in history / distinct days
        if history_adj_by_date:
            total_adj = sum(history_adj_by_date.values())
            distinct_days = len(history_adj_by_date)
            avg_ticket_adj = round(total_adj / distinct_days, 2)
            if avg_ticket_adj > 0 and remaining > 0:
                times_left = round(remaining / avg_ticket_adj, 1)
            else:
                times_left = 0.0
    else:
        # ticket = total adj spend / number of transactions
        if history_adj_amounts:
            avg_ticket_adj = round(sum(history_adj_amounts) / len(history_adj_amounts), 2)
            if avg_ticket_adj > 0 and remaining > 0:
                times_left = round(remaining / avg_ticket_adj, 1)
            else:
                times_left = 0.0

    return {
        "avg_ticket_adj": avg_ticket_adj,
        "times_left": times_left,
        "remaining": round(remaining, 2),
        "spent": round(spent_nominal, 2),
    }
