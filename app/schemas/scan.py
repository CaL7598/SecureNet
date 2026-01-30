"""
Pydantic schemas for network scanning and analysis
"""
from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime
from enum import Enum


class RiskLevel(str, Enum):
    """Risk level enumeration"""
    SECURE = "SECURE"
    LOW = "LOW"
    MEDIUM = "MEDIUM"
    HIGH = "HIGH"
    CRITICAL = "CRITICAL"


class IssueType(str, Enum):
    """Issue type enumeration"""
    INSECURE_PORT = "INSECURE_PORT"
    DEFAULT_CREDENTIALS = "DEFAULT_CREDENTIALS"
    KNOWN_VULNERABILITY = "KNOWN_VULNERABILITY"
    WEAK_PROTOCOL = "WEAK_PROTOCOL"


class Severity(str, Enum):
    """Severity enumeration"""
    LOW = "LOW"
    MEDIUM = "MEDIUM"
    HIGH = "HIGH"
    CRITICAL = "CRITICAL"


class DeviceScanRequest(BaseModel):
    """Device information from mobile app scan"""
    ip_address: str = Field(..., description="Device IP address")
    mac_address: str = Field(..., description="Device MAC address")
    device_name: Optional[str] = Field(None, description="Device name if available")
    open_ports: List[int] = Field(default_factory=list, description="List of open ports")
    vendor: Optional[str] = Field(None, description="Device vendor/manufacturer")


class NetworkScanRequest(BaseModel):
    """Network scan request from mobile app"""
    devices: List[DeviceScanRequest] = Field(..., description="List of discovered devices")
    scan_timestamp: Optional[datetime] = Field(default_factory=datetime.utcnow)


class Issue(BaseModel):
    """Security issue found on a device"""
    type: IssueType
    severity: Severity
    port: Optional[int] = None
    description: str
    recommendation: str


class DeviceAnalysis(BaseModel):
    """Analysis result for a single device"""
    ip_address: str
    mac_address: str
    device_name: Optional[str]
    risk_level: RiskLevel
    security_score: int = Field(..., ge=0, le=100)
    issues: List[Issue] = Field(default_factory=list)


class NetworkAnalysisResponse(BaseModel):
    """Complete network analysis response"""
    network_score: int = Field(..., ge=0, le=100, description="Overall network security score")
    overall_risk: RiskLevel
    total_devices: int
    critical_issues: int
    high_risk_devices: int
    devices: List[DeviceAnalysis]
