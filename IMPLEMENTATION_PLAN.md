# SecureNet - Mobile Security-Auditing Tool Implementation Plan

## 1. Project Overview

**Project Name:** SecureNet - Wi-Fi Security Auditor  
**Type:** Cross-platform Mobile Application  
**Purpose:** Enable non-technical users to identify security vulnerabilities on their home Wi-Fi networks

## 2. Technology Stack Decisions

### Frontend (Mobile App)
- **Framework:** React Native (chosen for cross-platform compatibility and strong community support)
- **State Management:** Redux Toolkit or Zustand
- **UI Library:** React Native Paper or NativeBase (for Material Design components)
- **Navigation:** React Navigation v6
- **Network Scanning:** 
  - `react-native-network-info` for network information
  - Custom native modules for ARP scanning and port scanning
  - `react-native-tcp-socket` for port scanning
- **Storage:** AsyncStorage for local data, React Native MMKV for performance

### Backend (API Server)
- **Framework:** FastAPI (chosen for modern async support, automatic API docs, and better performance than Flask)
- **Language:** Python 3.11+
- **Database:** PostgreSQL 15+ (chosen for robustness and advanced features)
- **ORM:** SQLAlchemy 2.0 (async)
- **Authentication:** JWT tokens for API security
- **Validation:** Pydantic v2
- **Deployment:** Docker + Docker Compose

### Database
- **Primary DB:** PostgreSQL
- **Tables:**
  - Device Manufacturers
  - Default Credentials
  - Known Vulnerabilities
  - Insecure Ports
  - Scan History (optional, for analytics)

### Development Tools
- **Version Control:** Git
- **CI/CD:** GitHub Actions (optional)
- **API Documentation:** FastAPI auto-generated Swagger/OpenAPI
- **Testing:** Jest (frontend), pytest (backend)

## 3. Project Structure

```
SecureNet/
├── mobile-app/                 # React Native application
│   ├── src/
│   │   ├── components/         # Reusable UI components
│   │   │   ├── DeviceCard.tsx
│   │   │   ├── SecurityScore.tsx
│   │   │   ├── ScanButton.tsx
│   │   │   └── SettingsToggle.tsx
│   │   ├── screens/            # Screen components
│   │   │   ├── ScanScreen.tsx
│   │   │   ├── ResultsScreen.tsx
│   │   │   ├── DeviceDetailScreen.tsx
│   │   │   ├── SettingsScreen.tsx
│   │   │   ├── HistoryScreen.tsx
│   │   │   └── MapScreen.tsx
│   │   ├── navigation/         # Navigation setup
│   │   │   └── AppNavigator.tsx
│   │   ├── services/           # API and business logic
│   │   │   ├── api.ts          # API client
│   │   │   ├── networkScanner.ts  # Network scanning logic
│   │   │   └── storage.ts      # Local storage
│   │   ├── store/              # State management
│   │   │   ├── slices/
│   │   │   │   ├── scanSlice.ts
│   │   │   │   ├── deviceSlice.ts
│   │   │   │   └── settingsSlice.ts
│   │   │   └── store.ts
│   │   ├── types/              # TypeScript types
│   │   │   └── index.ts
│   │   ├── utils/              # Utility functions
│   │   │   ├── validators.ts
│   │   │   └── formatters.ts
│   │   └── theme/              # Theme configuration
│   │       └── colors.ts
│   ├── android/                # Android native code
│   ├── ios/                    # iOS native code
│   ├── package.json
│   └── app.json
│
├── backend/                    # FastAPI backend
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py             # FastAPI app entry point
│   │   ├── config.py           # Configuration
│   │   ├── database.py         # Database connection
│   │   ├── models/             # SQLAlchemy models
│   │   │   ├── device.py
│   │   │   ├── vulnerability.py
│   │   │   └── default_credential.py
│   │   ├── schemas/            # Pydantic schemas
│   │   │   ├── scan.py
│   │   │   ├── device.py
│   │   │   └── vulnerability.py
│   │   ├── api/                # API routes
│   │   │   ├── __init__.py
│   │   │   ├── endpoints/
│   │   │   │   ├── analyze.py  # /analyze-network endpoint
│   │   │   │   ├── devices.py
│   │   │   │   └── vulnerabilities.py
│   │   │   └── dependencies.py # Shared dependencies
│   │   ├── services/           # Business logic
│   │   │   ├── analyzer.py     # Vulnerability analysis logic
│   │   │   ├── device_matcher.py
│   │   │   └── port_checker.py
│   │   └── utils/              # Utility functions
│   │       └── security.py
│   ├── migrations/             # Alembic migrations
│   ├── scripts/
│   │   └── seed_data.py        # Populate initial vulnerability data
│   ├── tests/
│   │   ├── test_analyzer.py
│   │   └── test_api.py
│   ├── requirements.txt
│   ├── Dockerfile
│   └── docker-compose.yml
│
├── database/                   # Database scripts
│   ├── init.sql                # Initial schema
│   └── seed_data.sql           # Initial vulnerability data
│
├── docs/                       # Documentation
│   ├── API.md                  # API documentation
│   ├── DATABASE_SCHEMA.md      # ERD and schema docs
│   └── SEQUENCE_DIAGRAMS.md    # API call sequences
│
└── README.md
```

## 4. Feature Breakdown

### 4.1 Core Features

#### A. Network Scanning
- **Device Discovery:**
  - ARP table scanning to discover devices on local network
  - MAC address extraction and vendor identification
  - IP address detection
  - Device name resolution (if available)
  
- **Port Scanning:**
  - Scan common high-risk ports: 23 (Telnet), 22 (SSH), 80 (HTTP), 443 (HTTPS), 21 (FTP), 3389 (RDP), 5900 (VNC)
  - Configurable port range
  - Timeout handling
  - Parallel scanning for performance

#### B. Vulnerability Analysis
- **Default Credential Checking:**
  - Match device manufacturer/model against database
  - Check for known default username/password combinations
  - Flag devices with default credentials
  
- **Port Security Analysis:**
  - Identify insecure open ports (Telnet, unencrypted HTTP)
  - Check for unnecessary services
  - Flag high-risk port combinations
  
- **Protocol Analysis:**
  - Detect weak Wi-Fi protocols (WEP, WPA)
  - Check for unencrypted services
  
- **Risk Scoring:**
  - Calculate security score (0-100)
  - Categorize devices: Secure, Low Risk, Medium Risk, High Risk, Critical
  - Aggregate network risk level

#### C. User Interface
- **Scan Screen:**
  - Large "Start Scan" button
  - Scan mode toggle (Real Network Scan / Demo Mode)
  - Feature list with checkmarks
  - Progress indicator during scan
  
- **Results Screen:**
  - Security score display (circular progress indicator)
  - Summary metrics (Total Devices, Critical Issues, High Risk Devices)
  - Device list with risk indicators
  - Device detail view on tap
  
- **Settings Screen:**
  - Scan interval configuration (Manual, 1 hour, 6 hours, 24 hours)
  - Default scan mode selection
  - Notification toggles:
    - Enable Notifications
    - Critical Vulnerability Alerts
    - High Risk Device Alerts
  
- **History Screen:**
  - List of past scans
  - Scan date/time
  - Security score trend
  - Quick access to previous results
  
- **Map Screen (Future Enhancement):**
  - Visual network topology
  - Device relationships
  - Connection visualization

### 4.2 Additional Features

- **Notifications:**
  - Push notifications for critical vulnerabilities
  - Scheduled scan reminders
  - Alert system for new high-risk devices
  
- **Demo Mode:**
  - Simulated scan results for testing/demo
  - No actual network access required
  - Pre-populated vulnerability data

## 5. Database Schema

### 5.1 Entity Relationship Diagram (ERD)

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
└─────────────────────┘

┌─────────────────────┐
│  KnownVulnerability │
├─────────────────────┤
│ id (PK)             │
│ cve_id              │
│ device_model        │
│ description         │
│ severity            │
│ affected_versions  │
│ mitigation          │
└─────────────────────┘
```

### 5.2 Table Definitions

#### DeviceManufacturer
```sql
CREATE TABLE device_manufacturers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    mac_prefix VARCHAR(8) NOT NULL,  -- First 3 bytes of MAC
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_mac_prefix ON device_manufacturers(mac_prefix);
```

#### DefaultCredential
```sql
CREATE TABLE default_credentials (
    id SERIAL PRIMARY KEY,
    manufacturer_id INTEGER REFERENCES device_manufacturers(id),
    model VARCHAR(100),
    username VARCHAR(50),
    password VARCHAR(100),
    is_common BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_manufacturer_model ON default_credentials(manufacturer_id, model);
```

#### InsecurePort
```sql
CREATE TABLE insecure_ports (
    id SERIAL PRIMARY KEY,
    port_number INTEGER NOT NULL UNIQUE,
    protocol VARCHAR(10) NOT NULL,  -- TCP, UDP
    risk_level VARCHAR(20) NOT NULL,  -- LOW, MEDIUM, HIGH, CRITICAL
    description TEXT,
    recommendation TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_port_number ON insecure_ports(port_number);
```

#### KnownVulnerability
```sql
CREATE TABLE known_vulnerabilities (
    id SERIAL PRIMARY KEY,
    cve_id VARCHAR(20) UNIQUE,
    device_model VARCHAR(100),
    manufacturer VARCHAR(100),
    description TEXT,
    severity VARCHAR(20) NOT NULL,  -- LOW, MEDIUM, HIGH, CRITICAL
    affected_versions TEXT,
    mitigation TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_device_model ON known_vulnerabilities(device_model);
CREATE INDEX idx_severity ON known_vulnerabilities(severity);
```

## 6. API Design

### 6.1 Endpoints

#### POST /api/v1/analyze-network
**Description:** Analyze network scan results and return vulnerability assessment

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

#### GET /api/v1/devices/{device_id}
**Description:** Get detailed information about a specific device

#### GET /api/v1/vulnerabilities
**Description:** Get list of known vulnerabilities (for reference)

#### GET /api/v1/health
**Description:** Health check endpoint

### 6.2 Authentication
- API Key authentication for mobile app
- JWT tokens for future user accounts (optional)

## 7. UI/UX Components

### 7.1 Design System
- **Theme:** Dark mode (as shown in images)
- **Primary Color:** Light Blue (#00D4FF or similar)
- **Accent Colors:**
  - Green: Secure status
  - Orange: Medium risk
  - Red: Critical issues
  - Purple: Icons/accents
- **Typography:** System fonts (San Francisco on iOS, Roboto on Android)

### 7.2 Component Library
- **Buttons:** Primary (light blue), Secondary (outlined)
- **Cards:** Dark gray background with rounded corners
- **Icons:** Custom icon set matching design
- **Progress Indicators:** Circular progress for security score
- **Lists:** Device cards with icons, status badges
- **Toggles:** Light blue switches for settings

## 8. Implementation Phases

### Phase 1: Project Setup & Backend Foundation (Week 1-2)
- [ ] Initialize React Native project
- [ ] Set up FastAPI backend structure
- [ ] Configure PostgreSQL database
- [ ] Create database schema and migrations
- [ ] Populate initial vulnerability data (seed script)
- [ ] Set up Docker environment
- [ ] Create basic API health check endpoint

### Phase 2: Backend Development (Week 3-4)
- [ ] Implement device manufacturer matching logic
- [ ] Build default credential checking service
- [ ] Create port risk analysis service
- [ ] Develop vulnerability analyzer service
- [ ] Implement risk scoring algorithm
- [ ] Create /analyze-network API endpoint
- [ ] Write unit tests for backend services
- [ ] Set up API documentation (Swagger)

### Phase 3: Mobile App Core Features (Week 5-7)
- [ ] Set up navigation structure
- [ ] Create theme and design system
- [ ] Build Scan Screen UI
- [ ] Implement network scanning module (ARP, port scanning)
- [ ] Create Results Screen UI
- [ ] Implement API integration
- [ ] Build Device Detail Screen
- [ ] Add loading states and error handling

### Phase 4: Mobile App Additional Features (Week 8-9)
- [ ] Build Settings Screen
- [ ] Implement local storage for settings
- [ ] Create History Screen
- [ ] Add notification system
- [ ] Implement demo mode
- [ ] Add scan scheduling (if time permits)

### Phase 5: Testing & Refinement (Week 10-11)
- [ ] End-to-end testing on real devices
- [ ] Test on multiple network configurations
- [ ] Performance optimization
- [ ] UI/UX refinements
- [ ] Bug fixes
- [ ] Security audit

### Phase 6: Documentation & Deployment (Week 12)
- [ ] Write comprehensive project report
- [ ] Create API documentation
- [ ] Generate ERD diagrams
- [ ] Create sequence diagrams
- [ ] Deploy backend API
- [ ] Build production mobile app binaries
- [ ] Prepare Git repository with proper structure

## 9. Risk Scoring Algorithm

### Security Score Calculation (0-100)
```
Base Score: 100

Deductions:
- Default credentials detected: -30 points
- Critical port open (Telnet, unencrypted services): -25 points
- High-risk port open (SSH with default creds): -20 points
- Medium-risk port open: -10 points
- Unknown device (can't verify): -5 points
- Multiple vulnerabilities: Additional -10 per extra issue

Risk Level Assignment:
- 90-100: Secure (Green)
- 70-89: Low Risk (Light Green)
- 50-69: Medium Risk (Orange)
- 30-49: High Risk (Red)
- 0-29: Critical (Dark Red)
```

## 10. Testing Strategy

### Backend Testing
- Unit tests for all services
- Integration tests for API endpoints
- Database query performance testing
- Load testing for API

### Mobile App Testing
- Component testing (Jest + React Native Testing Library)
- Integration testing for network scanning
- UI testing on real devices (iOS and Android)
- Network scanning accuracy validation
- Error handling and edge cases

### End-to-End Testing
- Full scan workflow testing
- API communication testing
- Data persistence testing
- Cross-platform compatibility

## 11. Security Considerations

- API rate limiting
- Input validation and sanitization
- Secure storage of API keys
- Network scanning permissions (user consent)
- No storage of sensitive network data
- HTTPS for all API communications

## 12. Future Enhancements

- User accounts and cloud sync
- Network topology visualization (Map screen)
- Automated remediation suggestions
- Integration with router APIs
- Machine learning for device identification
- Community vulnerability database

## 13. Deliverables Checklist

- [ ] Functional cross-platform mobile app (.apk and .ipa)
- [ ] Deployed REST API (production-ready)
- [ ] Populated PostgreSQL database
- [ ] Comprehensive project report
- [ ] ERD diagrams
- [ ] Sequence diagrams for API calls
- [ ] Git repository with clean commit history
- [ ] API documentation
- [ ] User manual/guide
- [ ] Test results and validation reports

---

## Next Steps

1. Review and approve this plan
2. Set up development environment
3. Initialize Git repository
4. Begin Phase 1 implementation
