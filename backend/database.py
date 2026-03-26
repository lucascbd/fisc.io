"""Database connection and session management"""
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from config import settings

engine = create_engine(
    settings.DATABASE_URL,
    connect_args={"client_encoding": "utf8"},
    pool_pre_ping=True,   # valida conexão antes de usar (evita "connection closed" após idle)
    pool_recycle=1800,    # recicla conexões a cada 30 min (evita timeout do Postgres)
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
