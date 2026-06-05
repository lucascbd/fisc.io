"""Configuration settings"""
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    DATABASE_URL: str
    SECRET_KEY: str
    APP_NAME: str = "Budget System"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 52560000  # 100 anos — sessão nunca expira na prática
    API_V1_PREFIX: str = "/api/v1"
    GEMINI_API_KEY: str = ""

    class Config:
        env_file = ".env"

settings = Settings()
