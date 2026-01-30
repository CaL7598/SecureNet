# SecureNet Setup Guide

This guide will help you set up and run the SecureNet application locally.

## Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js** 18+ and npm/yarn
- **Python** 3.11+
- **Docker** and Docker Compose
- **Git**

For mobile app development:
- **iOS**: Xcode (macOS only)
- **Android**: Android Studio with Android SDK

## Step 1: Clone and Navigate

```bash
cd "SecureNet app"
```

## Step 2: Backend Setup

### 2.1 Start PostgreSQL Database

```bash
cd backend
docker-compose up -d
```

This will start a PostgreSQL container on port 5432.

### 2.2 Create Python Virtual Environment

```bash
python -m venv venv

# On Windows:
venv\Scripts\activate

# On macOS/Linux:
source venv/bin/activate
```

### 2.3 Install Dependencies

```bash
pip install -r requirements.txt
```

### 2.4 Initialize Database

Create the database tables and seed initial data:

```bash
# Create tables (using SQLAlchemy)
python -c "from app.database import Base, engine; from app.models import *; Base.metadata.create_all(bind=engine)"

# Seed initial vulnerability data
python scripts/seed_data.py
```

### 2.5 Start the API Server

```bash
uvicorn app.main:app --reload
```

The API will be available at:
- **API**: http://localhost:8000
- **Documentation**: http://localhost:8000/docs
- **Health Check**: http://localhost:8000/api/v1/health

## Step 3: Mobile App Setup

### 3.1 Install Dependencies

Open a new terminal and navigate to the mobile app directory:

```bash
cd mobile-app
npm install
# or
yarn install
```

### 3.2 Configure API Endpoint

Update `src/services/api.ts` if your backend is running on a different host/port.

For Android emulator, use `10.0.2.2` instead of `localhost`:
```typescript
const API_BASE_URL = __DEV__ 
  ? 'http://10.0.2.2:8000'  // Android emulator
  : 'https://api.securenet.app';
```

### 3.3 Run the App

**For iOS:**
```bash
cd ios
pod install
cd ..
npm run ios
```

**For Android:**
```bash
npm run android
```

**Using Expo:**
```bash
npm start
```

Then scan the QR code with Expo Go app on your device.

## Step 4: Testing

### Test Backend API

```bash
# Health check
curl http://localhost:8000/api/v1/health

# Test analysis endpoint
curl -X POST http://localhost:8000/api/v1/analyze-network \
  -H "Content-Type: application/json" \
  -d '{
    "devices": [
      {
        "ip_address": "192.168.1.1",
        "mac_address": "00:11:22:33:44:55",
        "device_name": "Netgear-Router",
        "open_ports": [23, 80, 443],
        "vendor": "Netgear"
      }
    ]
  }'
```

### Test Mobile App

1. Open the app
2. Select "Demo Mode" for testing
3. Tap "Start Scan"
4. View results

## Troubleshooting

### Database Connection Issues

If you can't connect to the database:
1. Ensure Docker is running
2. Check if PostgreSQL container is up: `docker ps`
3. Verify connection string in `backend/app/config.py`

### Mobile App Can't Connect to API

1. **iOS Simulator**: Use `localhost` or `127.0.0.1`
2. **Android Emulator**: Use `10.0.2.2` instead of `localhost`
3. **Physical Device**: Use your computer's IP address (e.g., `192.168.1.100:8000`)

### Port Already in Use

If port 8000 is already in use:
```bash
# Change port in backend/app/main.py or use:
uvicorn app.main:app --reload --port 8001
```

## Next Steps

- Review the [Implementation Plan](../IMPLEMENTATION_PLAN.md)
- Check API documentation at http://localhost:8000/docs
- Customize vulnerability database in `backend/scripts/seed_data.py`

## Development Notes

- Backend uses FastAPI with automatic API documentation
- Database migrations use Alembic (not yet configured, using direct SQLAlchemy for now)
- Mobile app uses React Native with Expo
- Network scanning requires native modules (to be implemented)
