"""
Application Configuration
"""
from typing import List

from pydantic import field_validator
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Application settings"""
    
    # Database (Render/Heroku often use postgres://; SQLAlchemy expects postgresql://)
    DATABASE_URL: str = "postgresql://securenet:securenet123@localhost:5432/securenet"

    @field_validator("DATABASE_URL", mode="before")
    @classmethod
    def normalize_database_url(cls, v: object) -> object:
        if isinstance(v, str) and v.startswith("postgres://"):
            return "postgresql://" + v[len("postgres://"):]
        return v
    
    # API
    API_V1_PREFIX: str = "/api/v1"
    ALLOWED_ORIGINS: List[str] = ["*"]  # Configure for production
    
    # Security
    API_KEY: str = "dev-api-key-change-in-production"
    JWT_SECRET: str = "dev-jwt-secret-change-in-production"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24
    REFRESH_TOKEN_EXPIRE_DAYS: int = 30
    PASSWORD_RESET_CODE_TTL_MINUTES: int = 15
    PASSWORD_RESET_REQUEST_COOLDOWN_SECONDS: int = 45
    EMAIL_VERIFICATION_CODE_TTL_MINUTES: int = 20
    RATE_LIMIT_REQUESTS_PER_MINUTE: int = 120
    
    # App
    APP_NAME: str = "SecureNet"
    DEBUG: bool = True
    
    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
