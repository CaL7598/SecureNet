"""
Test database connection and data
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

from app.database import SessionLocal
from app.models.device import DeviceManufacturer
from app.models.default_credential import DefaultCredential
from app.models.insecure_port import InsecurePort
from app.models.known_vulnerability import KnownVulnerability

def test_database():
    """Test database connection and query data"""
    db = SessionLocal()
    
    try:
        print("Testing database connection...")
        
        # Test manufacturers
        manufacturers = db.query(DeviceManufacturer).limit(5).all()
        print(f"\n✅ Found {len(manufacturers)} manufacturers:")
        for mfg in manufacturers:
            print(f"   - {mfg.name} (MAC prefix: {mfg.mac_prefix})")
        
        # Test credentials
        credentials = db.query(DefaultCredential).limit(5).all()
        print(f"\n✅ Found {len(credentials)} default credentials:")
        for cred in credentials:
            mfg_name = cred.manufacturer.name if cred.manufacturer else "Generic"
            print(f"   - {mfg_name}: {cred.username}/{cred.password}")
        
        # Test ports
        ports = db.query(InsecurePort).all()
        print(f"\n✅ Found {len(ports)} insecure ports:")
        for port in ports:
            print(f"   - Port {port.port_number} ({port.protocol}): {port.risk_level}")
        
        # Test vulnerabilities
        vulnerabilities = db.query(KnownVulnerability).limit(5).all()
        print(f"\n✅ Found {len(vulnerabilities)} known vulnerabilities:")
        for vuln in vulnerabilities:
            print(f"   - {vuln.cve_id or 'N/A'}: {vuln.severity} - {vuln.device_model}")
        
        print("\n✅ Database connection successful!")
        return True
        
    except Exception as e:
        print(f"\n❌ Database error: {e}")
        return False
    finally:
        db.close()

if __name__ == "__main__":
    test_database()
