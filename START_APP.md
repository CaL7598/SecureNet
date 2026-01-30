# How to Start SecureNet App

## Quick Start (Step by Step)

### Step 1: Start the Backend API

Open a terminal and run:

```bash
# Navigate to backend directory
cd backend

# Start PostgreSQL database (if not already running)
docker-compose up -d

# Create and activate virtual environment (first time only)
python -m venv venv

# Windows:
venv\Scripts\activate

# macOS/Linux:
source venv/bin/activate

# Install dependencies (first time only)
pip install -r requirements.txt

# Seed the database with initial data (first time only)
python scripts/seed_data.py

# Start the API server
uvicorn app.main:app --reload
```

✅ **Backend is running!** You should see:
```
INFO:     Uvicorn running on http://127.0.0.1:8000
INFO:     Application startup complete.
```

**API is available at:**
- Main API: http://localhost:8000
- API Docs: http://localhost:8000/docs
- Health Check: http://localhost:8000/api/v1/health

---

### Step 2: Start the Mobile App

Open a **NEW terminal window** (keep backend running) and run:

```bash
# Navigate to mobile app directory
cd mobile-app

# Install dependencies (first time only)
npm install
# or
yarn install

# Start the Expo development server
npm start
# or
yarn start
```

✅ **Mobile app is starting!** You should see:
- A QR code in the terminal
- Options to press:
  - `a` - Open Android emulator
  - `i` - Open iOS simulator
  - `w` - Open in web browser

---

### Step 3: Run on Your Device/Simulator

#### Option A: Physical Device (Recommended)

1. Install **Expo Go** app on your phone:
   - iOS: [App Store](https://apps.apple.com/app/expo-go/id982107779)
   - Android: [Play Store](https://play.google.com/store/apps/details?id=host.exp.exponent)

2. Scan the QR code from the terminal with:
   - **iOS**: Camera app
   - **Android**: Expo Go app

#### Option B: iOS Simulator (macOS only)

```bash
# Press 'i' in the Expo terminal, or:
npm run ios
```

#### Option C: Android Emulator

```bash
# Press 'a' in the Expo terminal, or:
npm run android
```

**Note:** Make sure Android Studio emulator is running first!

---

## Testing the App

### 1. Test Demo Mode (No Network Required)

1. Open the app
2. On the Scan screen, select **"Demo Mode"** (right toggle)
3. Tap **"Start Scan"**
4. View the results!

### 2. Test Real Network Scan

1. Select **"Real Network Scan"** (left toggle)
2. Tap **"Start Scan"**
3. Wait for the scan to complete
4. View results

**Note:** Real network scanning requires native modules to be registered (see below).

---

## Troubleshooting

### Backend Issues

**Port 8000 already in use?**
```bash
# Use a different port
uvicorn app.main:app --reload --port 8001
```

**Database connection error?**
```bash
# Check if Docker is running
docker ps

# Restart database
docker-compose down
docker-compose up -d
```

**Module not found errors?**
```bash
# Make sure virtual environment is activated
# Windows: venv\Scripts\activate
# macOS/Linux: source venv/bin/activate

# Reinstall dependencies
pip install -r requirements.txt
```

### Mobile App Issues

**Can't connect to API?**

The app needs to reach `http://localhost:8000`. Use:

- **iOS Simulator**: `localhost` works ✅
- **Android Emulator**: Use `10.0.2.2` instead of `localhost`
  - Edit `mobile-app/src/services/api.ts`:
  ```typescript
  const API_BASE_URL = __DEV__ 
    ? 'http://10.0.2.2:8000'  // Android emulator
    : 'https://api.securenet.app';
  ```
- **Physical Device**: Use your computer's IP address
  - Find your IP: `ipconfig` (Windows) or `ifconfig` (macOS/Linux)
  - Edit `mobile-app/src/services/api.ts`:
  ```typescript
  const API_BASE_URL = __DEV__ 
    ? 'http://192.168.1.XXX:8000'  // Your computer's IP
    : 'https://api.securenet.app';
  ```

**npm install fails?**
```bash
# Clear cache and reinstall
rm -rf node_modules package-lock.json
npm install
```

**Expo won't start?**
```bash
# Clear Expo cache
npm start -- --reset-cache
```

**Build errors?**
```bash
# Clear all caches
npm start -- --clear
```

---

## Verify Everything Works

### Test Backend

Open browser and visit:
- http://localhost:8000/docs - Should show API documentation
- http://localhost:8000/api/v1/health - Should return `{"status":"healthy"}`

Or run the test script:
```bash
cd backend
python test_api.py
```

### Test Mobile App

1. ✅ App opens without errors
2. ✅ Can navigate between tabs (Scan, Map, History, Settings)
3. ✅ Demo mode scan works
4. ✅ Results screen shows data
5. ✅ Settings can be changed

---

## Development Tips

### Keep Backend Running
- Leave the `uvicorn` command running in one terminal
- It auto-reloads when you change backend code

### Keep Mobile App Running
- Leave `npm start` running in another terminal
- Press `r` to reload the app
- Press `m` to toggle menu

### View Logs
- Backend logs appear in the terminal running `uvicorn`
- Mobile app logs appear in Expo terminal or device console

---

## Next Steps

Once everything is running:

1. ✅ Test demo mode scan
2. ✅ Explore all screens
3. ✅ Try changing settings
4. ✅ Check scan history
5. 📱 Test on a real device for best experience

**Happy coding! 🚀**
