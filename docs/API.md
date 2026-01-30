# SecureNet API Documentation

## Base URL

- **Development**: `http://localhost:8000`
- **Production**: `https://api.securenet.app` (to be configured)

## Authentication

Currently, the API uses a simple API key system. In production, implement proper authentication.

## Endpoints

### Health Check

**GET** `/api/v1/health`

Check if the API is running.

**Response:**
```json
{
  "status": "healthy",
  "service": "SecureNet API"
}
```

---

### Analyze Network

**POST** `/api/v1/analyze-network`

Analyze network scan results and return vulnerability assessment.

**Request Body:**
```json
{
  "devices": [
    {
      "ip_address": "192.168.1.1",
      "mac_address": "00:11:22:33:44:55",
      "device_name": "Netgear-Router",
      "open_ports": [23, 80, 443],
      "vendor": "Netgear"
    }
  ],
  "scan_timestamp": "2024-01-15T10:30:00Z"
}
```

**Response:**
```json
{
  "network_score": 75,
  "overall_risk": "MEDIUM",
  "total_devices": 1,
  "critical_issues": 0,
  "high_risk_devices": 1,
  "devices": [
    {
      "ip_address": "192.168.1.1",
      "mac_address": "00:11:22:33:44:55",
      "device_name": "Netgear-Router",
      "risk_level": "HIGH",
      "security_score": 40,
      "issues": [
        {
          "type": "INSECURE_PORT",
          "severity": "HIGH",
          "port": 23,
          "description": "Telnet port is open and unencrypted",
          "recommendation": "Disable Telnet and use SSH (port 22) instead"
        },
        {
          "type": "DEFAULT_CREDENTIALS",
          "severity": "CRITICAL",
          "description": "Device may be using default credentials",
          "recommendation": "Change default username 'admin' and password 'password'"
        }
      ]
    }
  ]
}
```

**Risk Levels:**
- `SECURE`: Score 90-100
- `LOW`: Score 70-89
- `MEDIUM`: Score 50-69
- `HIGH`: Score 30-49
- `CRITICAL`: Score 0-29

**Issue Types:**
- `INSECURE_PORT`: Open port with security risk
- `DEFAULT_CREDENTIALS`: Potential default credentials
- `KNOWN_VULNERABILITY`: Known CVE or vulnerability
- `WEAK_PROTOCOL`: Weak encryption or protocol

---

### Get Vulnerabilities

**GET** `/api/v1/vulnerabilities`

Get list of known vulnerabilities.

**Query Parameters:**
- `skip` (int, default: 0): Number of records to skip
- `limit` (int, default: 100): Maximum number of records to return

**Response:**
```json
{
  "total": 2,
  "vulnerabilities": [
    {
      "id": 1,
      "cve_id": "CVE-2020-8958",
      "device_model": "Netgear Router",
      "manufacturer": "Netgear",
      "severity": "CRITICAL",
      "description": "Remote code execution vulnerability"
    }
  ]
}
```

---

### Get Device Details

**GET** `/api/v1/devices/{device_id}`

Get detailed information about a specific device.

**Status**: To be implemented

---

## Error Responses

All errors follow this format:

```json
{
  "detail": "Error message description"
}
```

**Status Codes:**
- `200`: Success
- `400`: Bad Request
- `404`: Not Found
- `500`: Internal Server Error

---

## Interactive Documentation

FastAPI provides automatic interactive documentation:

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

You can test all endpoints directly from the Swagger UI.
