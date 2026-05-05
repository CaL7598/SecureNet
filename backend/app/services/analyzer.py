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
        confidence_score = self._network_confidence_score(scan_request)
        
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
            confidence_score=confidence_score,
            devices=device_analyses
        )

    def _network_confidence_score(self, scan_request: NetworkScanRequest) -> int:
        devices = scan_request.devices or []
        if not devices:
            return 95
        points = 50
        known_names = sum(
            1 for d in devices if d.device_name and d.device_name.lower().strip() not in {"unknown", ""}
        )
        known_macs = sum(1 for d in devices if d.mac_address and d.mac_address.upper() != "UNKNOWN")
        devices_with_ports = sum(1 for d in devices if (d.open_ports or []))
        points += int((known_names / len(devices)) * 15)
        points += int((known_macs / len(devices)) * 20)
        points += int((devices_with_ports / len(devices)) * 15)
        return max(0, min(100, points))
    
    def _analyze_device(self, device_scan) -> DeviceAnalysis:
        """Analyze a single device for vulnerabilities"""
        issues = []
        base_score = 100
        manufacturer = self._resolve_manufacturer(device_scan)
        device_kind = self._classify_device_kind(device_scan)
        
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

        # Detect weak/legacy protocols from service surface.
        weak_protocol_issues = self._check_weak_protocols(device_scan)
        issues.extend(weak_protocol_issues)
        for item in weak_protocol_issues:
            if item.severity == Severity.CRITICAL:
                base_score -= 20
            elif item.severity == Severity.HIGH:
                base_score -= 12
            elif item.severity == Severity.MEDIUM:
                base_score -= 8

        # Heuristic firmware hygiene signal when model/version cannot be verified.
        firmware_issue = self._check_firmware_hygiene(
            device_scan=device_scan,
            manufacturer=manufacturer,
            device_kind=device_kind,
            known_vulnerability_count=len(vulnerability_issues),
        )
        if firmware_issue:
            issues.append(firmware_issue)
            base_score -= 8
        
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
            manufacturer=manufacturer,
            device_kind=device_kind,
            risk_level=risk_level,
            security_score=security_score,
            issues=issues
        )

    def _resolve_manufacturer(self, device_scan) -> str | None:
        """Resolve manufacturer from vendor hint, MAC prefix DB, or device name."""
        vendor = (device_scan.vendor or "").strip()
        if vendor and vendor.lower() != "unknown":
            return vendor

        try:
            if device_scan.mac_address and device_scan.mac_address.upper() != "UNKNOWN":
                mac_prefix = device_scan.mac_address.replace(":", "").upper()[:6]
                if mac_prefix:
                    manufacturer = self.db.query(DeviceManufacturer).filter(
                        DeviceManufacturer.mac_prefix == mac_prefix
                    ).first()
                    if manufacturer:
                        return manufacturer.name
        except Exception:
            pass

        name_lower = (device_scan.device_name or "").lower()
        vendor_keywords = {
            "netgear": "Netgear",
            "tp-link": "TP-Link",
            "tplink": "TP-Link",
            "linksys": "Linksys",
            "d-link": "D-Link",
            "asus": "ASUS",
            "huawei": "Huawei",
            "xiaomi": "Xiaomi",
            "apple": "Apple",
            "samsung": "Samsung",
            "canon": "Canon",
            "hp ": "HP",
            "epson": "Epson",
        }
        for key, label in vendor_keywords.items():
            if key in name_lower:
                return label
        return None

    def _classify_device_kind(self, device_scan) -> str:
        """Classify device kind from known ports and name hints."""
        ports = set(device_scan.open_ports or [])
        name = (device_scan.device_name or "").lower()

        if {554, 8000}.intersection(ports) or "camera" in name or "ipcam" in name:
            return "camera"
        if {9100, 631, 515}.intersection(ports) or "printer" in name:
            return "printer"
        if {53, 67, 68, 1900}.intersection(ports) and ({80, 443}.intersection(ports) or "router" in name):
            return "router"
        if {445, 139, 3389}.intersection(ports):
            return "workstation"
        if {22, 443, 8080, 8443}.intersection(ports) and len(ports) >= 4:
            return "server"
        if "tv" in name or "chromecast" in name or "roku" in name:
            return "media"
        if "phone" in name or "android" in name or "iphone" in name:
            return "mobile"
        return "iot"
    
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
        
        # Heuristic-only warning: avoid blanket false positives on every device.
        name_lower = (device_scan.device_name or "").lower()
        is_infrastructure = (
            "router" in name_lower
            or "camera" in name_lower
            or "ipcam" in name_lower
            or any(v in vendor_lower for v in ["netgear", "tp-link", "linksys", "d-link", "asus", "huawei"])
        )
        risky_mgmt_ports = {21, 23, 80, 443, 554, 8080}
        has_mgmt_surface = any(port in risky_mgmt_ports for port in (device_scan.open_ports or []))
        if is_infrastructure and has_mgmt_surface:
            return Issue(
                type=IssueType.DEFAULT_CREDENTIALS,
                severity=Severity.HIGH,
                description="Device may be using default credentials",
                recommendation="Verify admin credentials and replace default passwords with a strong unique passphrase."
            )

        return None
    
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

    def _check_weak_protocols(self, device_scan) -> list[Issue]:
        """Detect weak/legacy protocol exposure from open ports."""
        issues = []
        ports = set(device_scan.open_ports or [])
        if 23 in ports:
            issues.append(Issue(
                type=IssueType.WEAK_PROTOCOL,
                severity=Severity.CRITICAL,
                port=23,
                description="Legacy Telnet protocol is exposed",
                recommendation="Disable Telnet and use SSH with key-based authentication."
            ))
        if 21 in ports:
            issues.append(Issue(
                type=IssueType.WEAK_PROTOCOL,
                severity=Severity.HIGH,
                port=21,
                description="FTP is exposed without transport encryption",
                recommendation="Disable FTP and migrate to SFTP or FTPS."
            ))
        if 80 in ports and 443 not in ports:
            issues.append(Issue(
                type=IssueType.WEAK_PROTOCOL,
                severity=Severity.MEDIUM,
                port=80,
                description="Management/API traffic may be unencrypted (HTTP only)",
                recommendation="Enable HTTPS/TLS and redirect HTTP traffic."
            ))
        if 139 in ports or 445 in ports:
            issues.append(Issue(
                type=IssueType.WEAK_PROTOCOL,
                severity=Severity.MEDIUM,
                description="Legacy SMB/NetBIOS services are reachable",
                recommendation="Restrict SMB to trusted hosts and disable older SMB protocol versions."
            ))
        return issues

    def _check_firmware_hygiene(
        self,
        device_scan,
        manufacturer: str | None,
        device_kind: str,
        known_vulnerability_count: int,
    ) -> Issue | None:
        """Heuristic for outdated firmware risk when version cannot be queried directly."""
        if known_vulnerability_count > 0:
            return None

        ports = set(device_scan.open_ports or [])
        has_remote_admin = bool({22, 23, 80, 443, 8080, 8443}.intersection(ports))
        name = (device_scan.device_name or "").lower()
        model_unknown = not device_scan.device_name or name in {"unknown", "unknown device"}
        if has_remote_admin and device_kind in {"router", "camera", "iot"} and (model_unknown or manufacturer is None):
            return Issue(
                type=IssueType.KNOWN_VULNERABILITY,
                severity=Severity.MEDIUM,
                description="Firmware version could not be verified for this internet-reachable management surface",
                recommendation="Check vendor support page and update to the latest firmware, then disable remote administration if unnecessary."
            )
        return None
