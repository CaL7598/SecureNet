# Running SecureNet on Your PC

Yes! You can run the mobile app on your PC in several ways:

## Option 1: Web Browser (Easiest) 🌐

Expo supports running React Native apps in a web browser!

### Steps:

1. **Start the backend** (if not already running):
   ```bash
   cd backend
   uvicorn app.main:app --reload
   ```

2. **Start the app in web mode**:
   ```bash
   cd mobile-app
   npm start
   ```

3. **Press `w`** in the Expo terminal, or:
   ```bash
   npm run web
   ```

4. **App opens in your browser!** 🎉

**Note:** Some native features (like network scanning) won't work in web mode, but you can test:
- ✅ All UI screens
- ✅ Navigation
- ✅ Demo mode scanning
- ✅ Settings
- ✅ History

---

## Option 2: Android Emulator 📱

Run the full Android app on your PC using Android Studio emulator.

### Setup (First Time):

1. **Install Android Studio**:
   - Download: https://developer.android.com/studio
   - Install Android SDK and create an emulator

2. **Start Android Emulator**:
   - Open Android Studio
   - Tools > Device Manager
   - Create/Start an emulator

3. **Start the app**:
   ```bash
   cd mobile-app
   npm start
   ```

4. **Press `a`** in the Expo terminal, or:
   ```bash
   npm run android
   ```

**API Connection:** The app automatically uses `http://10.0.2.2:8000` for Android emulator (already configured!)

---

## Option 3: Windows Subsystem for Android (WSA) 🪟

If you have Windows 11, you can use Windows Subsystem for Android.

1. **Install WSA** (if not already installed)
2. **Install Expo Go** in WSA
3. **Start the app**:
   ```bash
   cd mobile-app
   npm start
   ```
4. **Scan QR code** with Expo Go in WSA

---

## Option 4: iOS Simulator (macOS only) 🍎

If you're on macOS:

```bash
cd mobile-app
npm start
# Press 'i' or:
npm run ios
```

---

## Recommended: Web Browser for Quick Testing

For the fastest way to test on PC:

```bash
# Terminal 1: Backend
cd backend
uvicorn app.main:app --reload

# Terminal 2: Web App
cd mobile-app
npm run web
```

The app will open in your default browser at `http://localhost:19006`

---

## What Works in Each Mode

### Web Browser ✅
- All UI screens
- Navigation
- Demo mode
- Settings
- History
- API calls (if backend running)

### Android/iOS Emulator ✅
- Everything from web, PLUS:
- Native modules (when configured)
- Real network scanning (when native modules registered)
- Full mobile experience

---

## Quick Start: Web Mode

```bash
# 1. Start backend
cd backend
uvicorn app.main:app --reload

# 2. In new terminal, start web app
cd mobile-app
npm run web
```

That's it! App opens in browser automatically. 🚀
