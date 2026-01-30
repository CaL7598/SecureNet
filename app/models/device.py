"""
Device Manufacturer Model
"""
from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base


class DeviceManufacturer(Base):
    """Device manufacturer model for MAC address prefix matching"""
    
    __tablename__ = "device_manufacturers"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), unique=True, nullable=False, index=True)
    mac_prefix = Column(String(8), nullable=False, index=True)  # First 3 bytes (6 hex chars)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    default_credentials = relationship("DefaultCredential", back_populates="manufacturer")
