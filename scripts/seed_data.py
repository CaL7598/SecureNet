"""
Seed script to populate database with initial vulnerability data
"""
import sys
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from sqlalchemy.orm import Session
from app.database import SessionLocal, engine, Base
from app.models.device import DeviceManufacturer
from app.models.default_credential import DefaultCredential
from app.models.insecure_port import InsecurePort
from app.models.known_vulnerability import KnownVulnerability


def create_tables():
    """Create all database tables"""
    Base.metadata.create_all(bind=engine)


def seed_data():
    """Populate database with initial data"""
    db: Session = SessionLocal()
    
    try:
        # Create manufacturers
        manufacturers_data = [
            {"name": "Netgear", "mac_prefix": "001122"},
            {"name": "TP-Link", "mac_prefix": "001E8C"},
            {"name": "Linksys", "mac_prefix": "001731"},
            {"name": "D-Link", "mac_prefix": "001CF0"},
            {"name": "ASUS", "mac_prefix": "001731"},
            {"name": "Belkin", "mac_prefix": "001AFA"},
            {"name": "Cisco", "mac_prefix": "001B0D"},
            {"name": "Apple", "mac_prefix": "001451"},
            {"name": "Samsung", "mac_prefix": "001451"},
            {"name": "Xiaomi", "mac_prefix": "001451"},
        ]
        
        manufacturers = {}
        for mfg_data in manufacturers_data:
            mfg = db.query(DeviceManufacturer).filter(
                DeviceManufacturer.name == mfg_data["name"]
            ).first()
            if not mfg:
                mfg = DeviceManufacturer(**mfg_data)
                db.add(mfg)
            manufacturers[mfg_data["name"]] = mfg
        
        db.commit()
        
        # Create default credentials
        credentials_data = [
            {
                "manufacturer": "Netgear",
                "model": None,
                "username": "admin",
                "password": "password",
                "is_common": True
            },
            {
                "manufacturer": "Netgear",
                "model": None,
                "username": "admin",
                "password": "1234",
                "is_common": True
            },
            {
                "manufacturer": "TP-Link",
                "model": None,
                "username": "admin",
                "password": "admin",
                "is_common": True
            },
            {
                "manufacturer": "Linksys",
                "model": None,
                "username": "admin",
                "password": "admin",
                "is_common": True
            },
            {
                "manufacturer": "D-Link",
                "model": None,
                "username": "admin",
                "password": "",
                "is_common": True
            },
            {
                "manufacturer": "ASUS",
                "model": None,
                "username": "admin",
                "password": "admin",
                "is_common": True
            },
            {
                "manufacturer": "Belkin",
                "model": None,
                "username": "",
                "password": "",
                "is_common": True
            },
            {
                "manufacturer": None,
                "model": None,
                "username": "admin",
                "password": "admin",
                "is_common": True
            },
            {
                "manufacturer": None,
                "model": None,
                "username": "root",
                "password": "root",
                "is_common": True
            },
        ]
        
        for cred_data in credentials_data:
            manufacturer = manufacturers.get(cred_data.pop("manufacturer")) if cred_data.get("manufacturer") else None
            cred = DefaultCredential(
                manufacturer_id=manufacturer.id if manufacturer else None,
                **{k: v for k, v in cred_data.items() if k != "manufacturer"}
            )
            db.add(cred)
        
        db.commit()
        
        # Create insecure ports
        ports_data = [
            {
                "port_number": 23,
                "protocol": "TCP",
                "risk_level": "CRITICAL",
                "description": "Telnet port - unencrypted remote access",
                "recommendation": "Disable Telnet and use SSH (port 22) instead"
            },
            {
                "port_number": 21,
                "protocol": "TCP",
                "risk_level": "HIGH",
                "description": "FTP port - unencrypted file transfer",
                "recommendation": "Use SFTP (port 22) or FTPS instead"
            },
            {
                "port_number": 80,
                "protocol": "TCP",
                "risk_level": "MEDIUM",
                "description": "HTTP port - unencrypted web traffic",
                "recommendation": "Use HTTPS (port 443) for sensitive data"
            },
            {
                "port_number": 22,
                "protocol": "TCP",
                "risk_level": "LOW",
                "description": "SSH port - secure remote access",
                "recommendation": "Ensure SSH uses strong authentication and is properly configured"
            },
            {
                "port_number": 3389,
                "protocol": "TCP",
                "risk_level": "HIGH",
                "description": "RDP port - Remote Desktop Protocol",
                "recommendation": "Restrict RDP access and use strong passwords"
            },
            {
                "port_number": 5900,
                "protocol": "TCP",
                "risk_level": "HIGH",
                "description": "VNC port - Virtual Network Computing",
                "recommendation": "Use VNC over SSH tunnel or disable if not needed"
            },
            {
                "port_number": 443,
                "protocol": "TCP",
                "risk_level": "LOW",
                "description": "HTTPS port - encrypted web traffic",
                "recommendation": "Ensure valid SSL/TLS certificates are used"
            },
            {
                "port_number": 8080,
                "protocol": "TCP",
                "risk_level": "MEDIUM",
                "description": "HTTP alternate port",
                "recommendation": "Ensure proper authentication and encryption"
            },
        ]
        
        for port_data in ports_data:
            port = db.query(InsecurePort).filter(
                InsecurePort.port_number == port_data["port_number"]
            ).first()
            if not port:
                port = InsecurePort(**port_data)
                db.add(port)
        
        db.commit()
        
        # Create known vulnerabilities
        vulnerabilities_data = [
            {
                "cve_id": "CVE-2020-8958",
                "device_model": "Netgear Router",
                "manufacturer": "Netgear",
                "description": "Remote code execution vulnerability in Netgear routers",
                "severity": "CRITICAL",
                "affected_versions": "Firmware versions < 1.0.0.78",
                "mitigation": "Update router firmware to latest version"
            },
            {
                "cve_id": "CVE-2019-19824",
                "device_model": "TP-Link Router",
                "manufacturer": "TP-Link",
                "description": "Authentication bypass vulnerability",
                "severity": "HIGH",
                "affected_versions": "Multiple models",
                "mitigation": "Update firmware and change default credentials"
            },
        ]
        
        for vuln_data in vulnerabilities_data:
            vuln = db.query(KnownVulnerability).filter(
                KnownVulnerability.cve_id == vuln_data["cve_id"]
            ).first()
            if not vuln:
                vuln = KnownVulnerability(**vuln_data)
                db.add(vuln)
        
        db.commit()
        print("✅ Database seeded successfully!")
        
    except Exception as e:
        db.rollback()
        print(f"❌ Error seeding database: {e}")
        raise
    finally:
        db.close()


if __name__ == "__main__":
    print("Creating database tables...")
    create_tables()
    print("Seeding database with initial data...")
    seed_data()
