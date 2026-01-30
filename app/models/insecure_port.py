"""
Insecure Port Model
"""
from sqlalchemy import Column, Integer, String, Text, DateTime
from sqlalchemy.sql import func
from app.database import Base


class InsecurePort(Base):
    """Insecure ports and their risk levels"""
    
    __tablename__ = "insecure_ports"
    
    id = Column(Integer, primary_key=True, index=True)
    port_number = Column(Integer, unique=True, nullable=False, index=True)
    protocol = Column(String(10), nullable=False)  # TCP, UDP
    risk_level = Column(String(20), nullable=False, index=True)  # LOW, MEDIUM, HIGH, CRITICAL
    description = Column(Text)
    recommendation = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
