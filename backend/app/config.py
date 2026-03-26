"""
Application Configuration
"""
from pydantic_settings import BaseSettings
from typing import List


class Settings(BaseSettings):
    """Application settings"""
    
    # Database
    DATABASE_URL: str = "postgresql://securenet:securenet123@localhost:5432/securenet"
    
    # API
    API_V1_PREFIX: str = "/api/v1"
    ALLOWED_ORIGINS: List[str] = ["*"]  # Configure for production
    
    # Security
    API_KEY: str = "dev-api-key-change-in-production"
    PASSWORD_RESET_CODE_TTL_MINUTES: int = 15
    PASSWORD_RESET_REQUEST_COOLDOWN_SECONDS: int = 45
    
    # App
    APP_NAME: str = "SecureNet"
    DEBUG: bool = True
    
    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
