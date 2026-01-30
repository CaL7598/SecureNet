"""
Network Vulnerability Analyzer Service
"""
from sqlalchemy.orm import Session
from app.schemas.scan import (
    NetworkScanRequest,
    NetworkAnalysisResponse,
    DeviceAnalysis,
    Issue,
    RiskLevel,
    IssueType,
    Severity
)
from app.models.device import DeviceManufacturer
from app.models.default_credential import DefaultCredential
from app.models.insecure_port import InsecurePort
from app.models.known_vulnerability import KnownVulnerability


class NetworkAnalyzer:
    """Analyzes network scan results for vulnerabilities"""
    
    def __init__(self, db: Session):
        self.db = db
    
    def analyze_network(self, scan_request: NetworkScanRequest) -> NetworkAnalysisResponse:
        """Analyze entire network and return comprehensive report"""
        device_analyses = []
        total_critical = 0
        total_high_risk = 0
        
        for device_scan in scan_request.devices:
            analysis = self._analyze_device(device_scan)
            device_analyses.append(analysis)
            
            if analysis.risk_level == RiskLevel.CRITICAL:
                total_critical += 1
            elif analysis.risk_level == RiskLevel.HIGH:
                total_high_risk += 1
        
        # Calculate overall network score
        if device_analyses:
            network_score = sum(d.security_score for d in device_analyses) // len(device_analyses)
        else:
            network_score = 100
        
        # Determine overall risk
        if network_score >= 90:
            overall_risk = RiskLevel.SECURE
        elif network_score >= 70:
            overall_risk = RiskLevel.LOW
        elif network_score >= 50:
            overall_risk = RiskLevel.MEDIUM
        elif network_score >= 30:
            overall_risk = RiskLevel.HIGH
        else:
            overall_risk = RiskLevel.CRITICAL
        
        return NetworkAnalysisResponse(
            network_score=network_score,
            overall_risk=overall_risk,
            total_devices=len(device_analyses),
            critical_issues=total_critical,
            high_risk_devices=total_high_risk,
            devices=device_analyses
        )
    
    def _analyze_device(self, device_scan) -> DeviceAnalysis:
        """Analyze a single device for vulnerabilities"""
        issues = []
        base_score = 100
        
        # Check for insecure ports
        for port in device_scan.open_ports:
            port_issue = self._check_port(port)
            if port_issue:
                issues.append(port_issue)
                # Deduct points based on severity
                if port_issue.severity == Severity.CRITICAL:
                    base_score -= 25
                elif port_issue.severity == Severity.HIGH:
                    base_score -= 20
                elif port_issue.severity == Severity.MEDIUM:
                    base_score -= 10
                else:
                    base_score -= 5
        
        # Check for default credentials
        credential_issue = self._check_default_credentials(device_scan)
        if credential_issue:
            issues.append(credential_issue)
            base_score -= 30
        
        # Check for known vulnerabilities
        vulnerability_issues = self._check_vulnerabilities(device_scan)
        issues.extend(vulnerability_issues)
        for vuln in vulnerability_issues:
            if vuln.severity == Severity.CRITICAL:
                base_score -= 20
            elif vuln.severity == Severity.HIGH:
                base_score -= 15
        
        # Unknown device penalty
        if not device_scan.device_name or device_scan.device_name.lower() == "unknown":
            base_score -= 5
        
        # Multiple issues penalty
        if len(issues) > 1:
            base_score -= (len(issues) - 1) * 10
        
        # Ensure score is within bounds
        security_score = max(0, min(100, base_score))
        
        # Determine risk level
        if security_score >= 90:
            risk_level = RiskLevel.SECURE
        elif security_score >= 70:
            risk_level = RiskLevel.LOW
        elif security_score >= 50:
            risk_level = RiskLevel.MEDIUM
        elif security_score >= 30:
            risk_level = RiskLevel.HIGH
        else:
            risk_level = RiskLevel.CRITICAL
        
        return DeviceAnalysis(
            ip_address=device_scan.ip_address,
            mac_address=device_scan.mac_address,
            device_name=device_scan.device_name,
            risk_level=risk_level,
            security_score=security_score,
            issues=issues
        )
    
    def _check_port(self, port: int) -> Issue | None:
        """Check if a port is insecure"""
        # In-memory port definitions (fallback if database not available)
        port_definitions = {
            23: {"risk_level": "CRITICAL", "description": "Telnet port - unencrypted remote access", "recommendation": "Disable Telnet and use SSH (port 22) instead"},
            21: {"risk_level": "HIGH", "description": "FTP port - unencrypted file transfer", "recommendation": "Use SFTP (port 22) or FTPS instead"},
            80: {"risk_level": "MEDIUM", "description": "HTTP port - unencrypted web traffic", "recommendation": "Use HTTPS (port 443) for sensitive data"},
            3389: {"risk_level": "HIGH", "description": "RDP port - Remote Desktop Protocol", "recommendation": "Restrict RDP access and use strong passwords"},
            5900: {"risk_level": "HIGH", "description": "VNC port - Virtual Network Computing", "recommendation": "Use VNC over SSH tunnel or disable if not needed"},
        }
        
        try:
            insecure_port = self.db.query(InsecurePort).filter(
                InsecurePort.port_number == port
            ).first()
            
            if insecure_port:
                return Issue(
                    type=IssueType.INSECURE_PORT,
                    severity=Severity(insecure_port.risk_level),
                    port=port,
                    description=insecure_port.description or f"Port {port} ({insecure_port.protocol}) is open and insecure",
                    recommendation=insecure_port.recommendation or f"Close port {port} or secure it with encryption"
                )
        except Exception:
            # Database not available, use in-memory definitions
            pass
        
        # Check in-memory definitions
        if port in port_definitions:
            port_def = port_definitions[port]
            return Issue(
                type=IssueType.INSECURE_PORT,
                severity=Severity(port_def["risk_level"]),
                port=port,
                description=port_def["description"],
                recommendation=port_def["recommendation"]
            )
        
        return None
    
    def _check_default_credentials(self, device_scan) -> Issue | None:
        """Check if device might be using default credentials"""
        # Common default credentials (in-memory fallback)
        common_defaults = [
            {"username": "admin", "password": "admin"},
            {"username": "admin", "password": "password"},
            {"username": "admin", "password": "1234"},
            {"username": "root", "password": "root"},
        ]
        
        try:
            # Try to match by manufacturer/vendor
            manufacturer = None
            if device_scan.vendor:
                manufacturer = self.db.query(DeviceManufacturer).filter(
                    DeviceManufacturer.name.ilike(f"%{device_scan.vendor}%")
                ).first()
            
            # Try to match by MAC prefix
            if not manufacturer and device_scan.mac_address:
                mac_prefix = device_scan.mac_address.replace(":", "").upper()[:6]
                manufacturer = self.db.query(DeviceManufacturer).filter(
                    DeviceManufacturer.mac_prefix == mac_prefix
                ).first()
            
            # Check for default credentials
            if manufacturer:
                credentials = self.db.query(DefaultCredential).filter(
                    DefaultCredential.manufacturer_id == manufacturer.id
                ).first()
                
                if credentials:
                    return Issue(
                        type=IssueType.DEFAULT_CREDENTIALS,
                        severity=Severity.CRITICAL,
                        description=f"Device may be using default credentials: {credentials.username}/{credentials.password}",
                        recommendation="Change default username and password immediately. Use a strong, unique password."
                    )
            
            # Check common defaults
            db_defaults = self.db.query(DefaultCredential).filter(
                DefaultCredential.is_common == True
            ).limit(5).all()
            
            if db_defaults:
                return Issue(
                    type=IssueType.DEFAULT_CREDENTIALS,
                    severity=Severity.HIGH,
                    description="Device may be using common default credentials",
                    recommendation="Verify and change any default usernames and passwords on this device."
                )
        except Exception:
            # Database not available, use in-memory defaults
            pass
        
        # Check vendor-specific defaults
        vendor_lower = (device_scan.vendor or "").lower()
        if "netgear" in vendor_lower or "router" in (device_scan.device_name or "").lower():
            return Issue(
                type=IssueType.DEFAULT_CREDENTIALS,
                severity=Severity.CRITICAL,
                description="Device may be using default credentials: admin/password",
                recommendation="Change default username and password immediately. Use a strong, unique password."
            )
        
        # Generic warning for common defaults
        return Issue(
            type=IssueType.DEFAULT_CREDENTIALS,
            severity=Severity.HIGH,
            description="Device may be using common default credentials",
            recommendation="Verify and change any default usernames and passwords on this device."
        )
    
    def _check_vulnerabilities(self, device_scan) -> list[Issue]:
        """Check for known vulnerabilities"""
        vulnerabilities = []
        
        try:
            # Search by device model
            if device_scan.device_name:
                vulns = self.db.query(KnownVulnerability).filter(
                    KnownVulnerability.device_model.ilike(f"%{device_scan.device_name}%")
                ).all()
                
                for vuln in vulns:
                    vulnerabilities.append(Issue(
                        type=IssueType.KNOWN_VULNERABILITY,
                        severity=Severity(vuln.severity),
                        description=vuln.description or f"Known vulnerability: {vuln.cve_id or 'N/A'}",
                        recommendation=vuln.mitigation or "Update device firmware to latest version"
                    ))
        except Exception:
            # Database not available, skip vulnerability check
            pass
        
        return vulnerabilities
