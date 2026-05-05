"""
Persisted user scan session snapshots.
"""
from sqlalchemy import JSON, Column, DateTime, ForeignKey, Integer, String
from sqlalchemy.sql import func

from app.database import Base


class ScanSession(Base):
    __tablename__ = "scan_sessions"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    network_score = Column(Integer, nullable=False)
    overall_risk = Column(String(32), nullable=False)
    analysis_payload = Column(JSON, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
