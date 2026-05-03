"""
Database Configuration and Session Management
"""
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

from app.config import settings


def _database_url_for_engine(url: str) -> str:
    """Supabase requires TLS; connection strings should include sslmode=require."""
    u = url.lower()
    if "supabase" not in u:
        return url
    if "sslmode=" in url:
        return url
    return f"{url}{'&' if '?' in url else '?'}sslmode=require"


# Create database engine
engine = create_engine(
    _database_url_for_engine(settings.DATABASE_URL),
    pool_pre_ping=True,
    echo=settings.DEBUG,
)

# Create session factory
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base class for models
Base = declarative_base()


def get_db():
    """Dependency for getting database session"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
