"""
Quick test script for SecureNet API
"""
import requests
import json
from datetime import datetime

API_BASE = "http://localhost:8000"

def test_health():
    """Test health check endpoint"""
    print("Testing health check...")
    try:
        response = requests.get(f"{API_BASE}/api/v1/health")
        print(f"Status: {response.status_code}")
        print(f"Response: {response.json()}")
        return response.status_code == 200
    except Exception as e:
        print(f"Error: {e}")
        return False

def test_analyze_network():
    """Test network analysis endpoint"""
    print("\nTesting network analysis...")
    
    test_data = {
        "devices": [
            {
                "ip_address": "192.168.1.1",
                "mac_address": "00:11:22:33:44:55",
                "device_name": "Netgear-Router",
                "open_ports": [23, 80, 443],
                "vendor": "Netgear"
            },
            {
                "ip_address": "192.168.1.100",
                "mac_address": "AA:BB:CC:DD:EE:FF",
                "device_name": "Unknown Device",
                "open_ports": [80],
                "vendor": "Unknown"
            }
        ],
        "scan_timestamp": datetime.utcnow().isoformat()
    }
    
    try:
        response = requests.post(
            f"{API_BASE}/api/v1/analyze-network",
            json=test_data,
            headers={"Content-Type": "application/json"}
        )
        print(f"Status: {response.status_code}")
        if response.status_code == 200:
            result = response.json()
            print(f"\nNetwork Score: {result['network_score']}/100")
            print(f"Overall Risk: {result['overall_risk']}")
            print(f"Total Devices: {result['total_devices']}")
            print(f"Critical Issues: {result['critical_issues']}")
            print(f"High Risk Devices: {result['high_risk_devices']}")
            print(f"\nDevices:")
            for device in result['devices']:
                print(f"  - {device['device_name']}: {device['security_score']}/100 ({device['risk_level']})")
                print(f"    Issues: {len(device['issues'])}")
                for issue in device['issues']:
                    print(f"      • {issue['type']}: {issue['severity']} - {issue['description']}")
            return True
        else:
            print(f"Error: {response.text}")
            return False
    except Exception as e:
        print(f"Error: {e}")
        return False

def test_vulnerabilities():
    """Test vulnerabilities endpoint"""
    print("\nTesting vulnerabilities endpoint...")
    try:
        response = requests.get(f"{API_BASE}/api/v1/vulnerabilities?limit=5")
        print(f"Status: {response.status_code}")
        if response.status_code == 200:
            result = response.json()
            print(f"Total vulnerabilities: {result['total']}")
            return True
        else:
            print(f"Error: {response.text}")
            return False
    except Exception as e:
        print(f"Error: {e}")
        return False

if __name__ == "__main__":
    print("=" * 50)
    print("SecureNet API Test Suite")
    print("=" * 50)
    
    # Test health
    health_ok = test_health()
    
    if health_ok:
        # Test vulnerabilities
        test_vulnerabilities()
        
        # Test analysis
        test_analyze_network()
        
        print("\n" + "=" * 50)
        print("Tests completed!")
        print("=" * 50)
    else:
        print("\n❌ API is not running. Please start the server first:")
        print("   uvicorn app.main:app --reload")
