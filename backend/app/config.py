"""
Application Configuration
"""
from typing import List

from pydantic import field_validator, model_validator
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

    @field_validator("SENDGRID_API_KEY", "EMAIL_FROM", "SMTP_HOST", "SMTP_USERNAME", "SMTP_PASSWORD", mode="before")
    @classmethod
    def strip_strings(cls, v: object) -> object:
        if isinstance(v, str):
            return v.strip()
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

    # Email delivery (SendGrid SMTP or generic SMTP)
    EMAIL_DELIVERY_ENABLED: bool = False
    SENDGRID_API_KEY: str = ""
    SMTP_HOST: str = ""
    SMTP_PORT: int = 587
    SMTP_USERNAME: str = ""
    SMTP_PASSWORD: str = ""
    SMTP_USE_TLS: bool = True
    EMAIL_FROM: str = "noreply@securenet.app"
    
    # App
    APP_NAME: str = "SecureNet"
    DEBUG: bool = True

    @model_validator(mode="after")
    def apply_sendgrid_defaults(self) -> "Settings":
        """When SENDGRID_API_KEY is set, default to SendGrid delivery."""
        if self.SENDGRID_API_KEY:
            if not self.SMTP_HOST:
                object.__setattr__(self, "SMTP_HOST", "smtp.sendgrid.net")
            if not self.SMTP_USERNAME:
                object.__setattr__(self, "SMTP_USERNAME", "apikey")
            if not self.SMTP_PASSWORD:
                object.__setattr__(self, "SMTP_PASSWORD", self.SENDGRID_API_KEY)
            object.__setattr__(self, "EMAIL_DELIVERY_ENABLED", True)
        return self
    
    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
