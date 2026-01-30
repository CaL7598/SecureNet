# SecureNet Database Schema

## Entity Relationship Diagram

```
┌─────────────────────┐
│  DeviceManufacturer │
├─────────────────────┤
│ id (PK)             │
│ name                │
│ mac_prefix          │
│ created_at          │
└─────────────────────┘
         │
         │ 1:N
         │
┌─────────────────────┐
│  DefaultCredential   │
├─────────────────────┤
│ id (PK)             │
│ manufacturer_id (FK)│
│ model               │
│ username            │
│ password            │
│ is_common           │
│ created_at          │
└─────────────────────┘

┌─────────────────────┐
│  InsecurePort       │
├─────────────────────┤
│ id (PK)             │
│ port_number         │
│ protocol            │
│ risk_level          │
│ description         │
│ recommendation      │
│ created_at          │
└─────────────────────┘

┌─────────────────────┐
│  KnownVulnerability │
├─────────────────────┤
│ id (PK)             │
│ cve_id              │
│ device_model        │
│ manufacturer        │
│ description         │
│ severity            │
│ affected_versions   │
│ mitigation          │
│ created_at          │
└─────────────────────┘
```

## Tables

### device_manufacturers

Stores device manufacturer information for MAC address prefix matching.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INTEGER | PRIMARY KEY | Auto-increment ID |
| name | VARCHAR(100) | UNIQUE, NOT NULL | Manufacturer name |
| mac_prefix | VARCHAR(8) | NOT NULL, INDEX | First 3 bytes of MAC (6 hex chars) |
| created_at | TIMESTAMP | DEFAULT NOW() | Creation timestamp |

**Indexes:**
- `idx_mac_prefix` on `mac_prefix`
- Unique index on `name`

---

### default_credentials

Stores known default username/password combinations for devices.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INTEGER | PRIMARY KEY | Auto-increment ID |
| manufacturer_id | INTEGER | FOREIGN KEY | Reference to device_manufacturers |
| model | VARCHAR(100) | NULLABLE, INDEX | Device model (optional) |
| username | VARCHAR(50) | NOT NULL | Default username |
| password | VARCHAR(100) | NOT NULL | Default password |
| is_common | BOOLEAN | DEFAULT TRUE | Common/default credential flag |
| created_at | TIMESTAMP | DEFAULT NOW() | Creation timestamp |

**Foreign Keys:**
- `manufacturer_id` → `device_manufacturers.id`

**Indexes:**
- `idx_manufacturer_model` on `(manufacturer_id, model)`

---

### insecure_ports

Stores information about insecure ports and their risk levels.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INTEGER | PRIMARY KEY | Auto-increment ID |
| port_number | INTEGER | UNIQUE, NOT NULL, INDEX | Port number (0-65535) |
| protocol | VARCHAR(10) | NOT NULL | Protocol (TCP/UDP) |
| risk_level | VARCHAR(20) | NOT NULL, INDEX | Risk level (LOW/MEDIUM/HIGH/CRITICAL) |
| description | TEXT | NULLABLE | Port description |
| recommendation | TEXT | NULLABLE | Security recommendation |
| created_at | TIMESTAMP | DEFAULT NOW() | Creation timestamp |

**Indexes:**
- `idx_port_number` on `port_number`
- `idx_risk_level` on `risk_level`

**Common Ports:**
- 23 (Telnet) - CRITICAL
- 21 (FTP) - HIGH
- 80 (HTTP) - MEDIUM
- 22 (SSH) - LOW (if properly configured)
- 443 (HTTPS) - LOW
- 3389 (RDP) - HIGH
- 5900 (VNC) - HIGH

---

### known_vulnerabilities

Stores known vulnerabilities (CVE) for devices.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INTEGER | PRIMARY KEY | Auto-increment ID |
| cve_id | VARCHAR(20) | UNIQUE, NULLABLE, INDEX | CVE identifier (e.g., CVE-2020-8958) |
| device_model | VARCHAR(100) | NULLABLE, INDEX | Affected device model |
| manufacturer | VARCHAR(100) | NULLABLE, INDEX | Device manufacturer |
| description | TEXT | NULLABLE | Vulnerability description |
| severity | VARCHAR(20) | NOT NULL, INDEX | Severity (LOW/MEDIUM/HIGH/CRITICAL) |
| affected_versions | TEXT | NULLABLE | Affected firmware/software versions |
| mitigation | TEXT | NULLABLE | Mitigation steps |
| created_at | TIMESTAMP | DEFAULT NOW() | Creation timestamp |

**Indexes:**
- `idx_device_model` on `device_model`
- `idx_manufacturer` on `manufacturer`
- `idx_severity` on `severity`
- Unique index on `cve_id`

---

## Relationships

1. **DeviceManufacturer → DefaultCredential** (One-to-Many)
   - One manufacturer can have multiple default credential entries
   - Used to match devices by MAC prefix or vendor name

2. **No direct relationships** between other tables
   - Tables are queried independently based on scan results

## Data Population

Initial data is populated via `backend/scripts/seed_data.py`:

- **Manufacturers**: Common router/device manufacturers
- **Default Credentials**: Common username/password combinations
- **Insecure Ports**: High-risk ports with descriptions
- **Known Vulnerabilities**: Sample CVE entries

## Usage in Analysis

The analyzer service queries these tables to:

1. **Match devices** by MAC prefix or vendor name
2. **Check for default credentials** based on manufacturer/model
3. **Identify insecure ports** from the open ports list
4. **Find known vulnerabilities** by device model/manufacturer

## Future Enhancements

- Add `scan_history` table for storing past scan results
- Add `user_devices` table for device management
- Add `vulnerability_updates` table for tracking CVE updates
- Add full-text search indexes for better matching
