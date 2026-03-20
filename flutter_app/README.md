# SecureNet (Flutter)

Flutter version of the SecureNet Wi-Fi security auditing app. Runs on **iOS**, **Android**, and web. Same flow and design as the React Native app: splash → login/signup → main app (Scan, Map, History, Settings).

## Run

```bash
cd flutter_app
flutter pub get
flutter run
```

- **Android (device or emulator):** `flutter run -d android`
- **iOS (simulator or device, macOS only):** `flutter run -d ios`
- **Web:** `flutter run -d chrome`

The app picks the API base URL by platform: **Android emulator** uses `http://10.0.2.2:8000`, **iOS simulator** and **web** use `http://localhost:8000`.  

**Physical phone (USB debug):** Set your PC’s LAN IP in `lib/services/api_base_url_io.dart`:

```dart
const String? kPhysicalDeviceHost = '192.168.1.100';  // your PC’s IP
```

Find your IP: Windows `ipconfig`, macOS/Linux `ifconfig`. Keep the phone and PC on the same Wi‑Fi. Set back to `null` when using the emulator.

## Backend

Uses the same FastAPI backend. Start it from the repo root:

```bash
cd backend
uvicorn app.main:app --reload
```

HTTP is allowed for local development (Android: `usesCleartextTraffic`; iOS: `NSAllowsLocalNetworking`).

## Features

- Splash screen with Get Started
- Login and Sign up (stubbed; no backend auth yet)
- Main tabs: Scan (demo + API), Map (placeholder), History (empty state), Settings
- Scan sends device list to `/api/v1/analyze-network` and shows results
- Device detail and risk/issue list
