"""
Default Credential Model
"""
from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base


class DefaultCredential(Base):
    """Default username/password combinations for devices"""
    
    __tablename__ = "default_credentials"
    
    id = Column(Integer, primary_key=True, index=True)
    manufacturer_id = Column(Integer, ForeignKey("device_manufacturers.id"), nullable=True)
    model = Column(String(100), nullable=True, index=True)
    username = Column(String(50), nullable=False)
    password = Column(String(100), nullable=False)
    is_common = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    manufacturer = relationship("DeviceManufacturer", back_populates="default_credentials")
