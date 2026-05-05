# SecureNet (Flutter)

Flutter version of the SecureNet Wi-Fi security auditing app. Runs on **iOS**, **Android**, and web. Same flow and design as the React Native app: splash → login/signup → main app (Scan, Map, History, Settings).

## Run

```bash
cd flutter_app
flutter pub get
flutter run --dart-define=API_BASE_URL=https://api.yourdomain.com
```

- **Android (device or emulator):** `flutter run -d android`
- **iOS (simulator or device, macOS only):** `flutter run -d ios`
- **Web:** `flutter run -d chrome`

The app is now locked to **hosted API mode only**. Localhost/LAN fallbacks are disabled.  

Build or run with your public HTTPS origin (no trailing slash required):

```bash
flutter run --dart-define=API_BASE_URL=https://api.yourdomain.com
flutter build apk --dart-define=API_BASE_URL=https://api.yourdomain.com
```

Set the backend’s `ALLOWED_ORIGINS` (or `*` only for quick tests) and use a **managed PostgreSQL** URL in `DATABASE_URL` on the host.

**Render + DB:** Deploy the API with the repo-root `render.yaml` or `backend/RENDER_DEPLOY.md`. For **Supabase** step-by-step (connection URI, `.env`, Render), use **`backend/SUPABASE_SETUP.md`**. Use your Web Service URL in `API_BASE_URL`.

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
