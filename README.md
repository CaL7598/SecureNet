# SecureNet - Wi-Fi Security Auditor

A cross-platform mobile application that scans home Wi-Fi networks, identifies connected devices, and detects common security vulnerabilities.

## Project Structure

```
SecureNet/
├── mobile-app/          # React Native mobile application
├── backend/             # FastAPI backend server
├── database/            # Database scripts and migrations
└── docs/               # Documentation
```

## Technology Stack

- **Frontend:** React Native (iOS & Android)
- **Backend:** FastAPI (Python)
- **Database:** PostgreSQL
- **Containerization:** Docker & Docker Compose

## Quick Start

### Prerequisites

- Node.js 18+ and npm/yarn
- Python 3.11+
- Docker and Docker Compose
- React Native development environment (Xcode for iOS, Android Studio for Android)

### Backend Setup

1. Navigate to backend directory:
```bash
cd backend
```

2. Create virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

4. Start database with Docker:
```bash
docker-compose up -d
```

5. Run database migrations:
```bash
alembic upgrade head
```

6. Seed initial data:
```bash
python scripts/seed_data.py
```

7. Start the API server:
```bash
uvicorn app.main:app --reload
```

The API will be available at `http://localhost:8000`
API documentation at `http://localhost:8000/docs`

### Mobile App Setup

1. Navigate to mobile-app directory:
```bash
cd mobile-app
```

2. Install dependencies:
```bash
npm install
# or
yarn install
```

3. For iOS:
```bash
cd ios && pod install && cd ..
npm run ios
```

4. For Android:
```bash
npm run android
```

## Features

- 🔍 Network device discovery via ARP scanning
- 🔌 Port scanning for common vulnerabilities
- 🛡️ Vulnerability analysis and risk scoring
- 📊 User-friendly security reports
- ⚙️ Configurable scan settings
- 📱 Cross-platform (iOS & Android)

## Development

See [IMPLEMENTATION_PLAN.md](./IMPLEMENTATION_PLAN.md) for detailed implementation plan and architecture.

## License

This project is for educational purposes.
