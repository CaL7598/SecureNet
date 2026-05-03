# Set up Supabase for SecureNet (Postgres only)

Your FastAPI backend uses **one environment variable**: `DATABASE_URL`. Supabase hosts Postgres; you do **not** need the Supabase Flutter SDK for this step.

---

## 1. Create a Supabase project

1. Go to [https://supabase.com](https://supabase.com) and sign in.
2. **New project** → choose **Organization**, **Name**, **Database password**.
3. **Save the password** in a password manager (you need it for the URI and cannot view it later in plain text from every screen).
4. Pick a **Region** close to you (or close to Render if the API runs on Render).
5. Wait until the project finishes provisioning.

---

## 2. Get the connection string (URI)

The URI is **not** on **Table editor**, **Indexes**, or empty-schema pages. Use one of these:

### A. **Connect** button (most common in current UI)

1. Open your project in the Supabase dashboard.
2. Click the green **Connect** button at the **top** of the page (center toolbar).
3. In the panel, choose a tab such as **ORMs**, **App frameworks**, or **Connection string** / **URI**.
4. Copy the **PostgreSQL URI**, insert your **database password** where shown, and URL-encode special characters in the password if needed.

### B. **Project Settings → Database**

1. Click the **gear** icon (**Project Settings**) at the bottom of the left icon rail.
2. Open **Database** in the settings sidebar.
3. Scroll to **Connection string** and copy the **URI** (see table below for pooler vs direct).

### C. **Database → Settings** (inner sidebar)

From **Database** in the main left nav, under **CONFIGURATION**, open **Settings** if your layout sends you there instead of the top **Connect** flow.

Configure the string like this:

| Setting | Recommendation for this app |
|--------|------------------------------|
| **Type** | **URI** |
| **Source** | Often “Primary database” / default |
| **Mode** | If Supabase shows **“Not IPv4 compatible”** for **Direct connection**, use **Session pooler** (often port **6543**) for **Render**, **home Wi‑Fi**, and most servers — they are IPv4-only. **Direct** (`db....supabase.co:5432`) is fine only when the host can reach the DB over **IPv6**, or you enable Supabase’s **IPv4 add-on**. Prefer **Session pooler** for this FastAPI app unless you know you have IPv6. |

5. Copy the URI. It will still contain a **placeholder** for the password (`[YOUR-PASSWORD]` or similar) or show `postgres` user — paste **your real database password** where required.

**Special characters in the password** must be **URL-encoded** in the URI (e.g. `@` → `%40`, `#` → `%23`, space → `%20`).  
Quick check in Python (replace the password):

```bash
python -c "import urllib.parse; print(urllib.parse.quote('YOUR_PLAIN_PASSWORD', safe=''))"
```

Put that encoded value in the URI as the password segment.

---

## 3. Point the SecureNet backend at Supabase

### Option A — Local development (`backend/.env`)

1. In the `backend` folder, copy the example env file:

   ```bash
   cd backend
   copy .env.example .env
   ```

   (macOS/Linux: `cp .env.example .env`)

2. Edit **`.env`** and set **`DATABASE_URL`** to the full Supabase URI (with encoded password).

3. Start the API:

   ```bash
   uvicorn app.main:app --reload
   ```

4. Open [http://127.0.0.1:8000/api/v1/health](http://127.0.0.1:8000/api/v1/health) — you should see `healthy`.

On first successful start, the app runs **`create_all`** and creates tables in **your** Supabase Postgres (same schema as local dev).

### Option B — Render (or any host)

1. Open your **Web Service** → **Environment**.
2. Add or edit **`DATABASE_URL`** → paste the same Supabase URI → **Save**.
3. **Redeploy** the service.

Do **not** commit `.env` to git (it is already in `.gitignore`).

---

## 4. Optional: seed vulnerability reference data

Richer analysis uses seeded rows (same as local Postgres docs):

```bash
cd backend
# Activate your venv first if you use one
set DATABASE_URL=...   # Windows: same URI as .env, or rely on .env if you load it
python scripts/seed_data.py
```

On Render, use **Shell** in the dashboard and run `python scripts/seed_data.py` from the app directory if `seed_data.py` reads `DATABASE_URL` from the environment (check script — if it uses `app.config.settings`, Render’s env is enough).

---

## 5. Point the Flutter app at your API (not Supabase directly)

The mobile app talks to **your FastAPI URL**, not to Supabase:

```bash
flutter run --dart-define=API_BASE_URL=https://YOUR-RENDER-SERVICE.onrender.com
```

Supabase is only the **database behind** that API.

---

## Authentication → URL Configuration (only if you use Supabase Auth)

The screen **Authentication → URL Configuration** controls **redirects** for Supabase-hosted login (magic links, email confirm, OAuth). It does **not** affect Postgres or your FastAPI `DATABASE_URL`.

| Your setup | What to do |
|------------|------------|
| **Postgres only** (SecureNet API uses `DATABASE_URL`; Flutter logs in via your own stub / future FastAPI auth) | You can **leave** Site URL as `http://localhost:3000` or any placeholder. It is unused until you wire **Supabase Auth** into a client. |
| **Supabase Auth in a Flutter app** | Set **Site URL** to your primary post-login destination, often a **custom URL scheme** you registered (e.g. `io.supabase.securenet://login-callback`) — exact value must match what your Flutter `signInWithOAuth` / `getSessionFromUrl` flow expects. Add the same (and any variants) under **Redirect URLs** (wildcards allowed, e.g. `io.supabase.securenet://**`). |
| **Supabase Auth + a real web app** (e.g. Next on port 3000) | **Site URL** = that web origin, e.g. `https://your-app.onrender.com` or `http://localhost:3000` for local dev. Add every allowed callback under **Redirect URLs**. |

`http://localhost:3000` is Supabase’s default for **web** templates; it is **not** required for your current “API + Postgres only” path.

---

## Troubleshooting

| Problem | What to try |
|--------|--------------|
| **SSL / connection refused** | The code adds `sslmode=require` for Supabase-style hosts. Ensure the URI is complete and the password is URL-encoded. |
| **IPv6 / timeout from Render** | Switch URI from **direct 5432** to **pooler 6543** (or the other way around) in the Supabase connection UI. |
| **Authentication failed** | Wrong password or password not encoded in the URI. Reset DB password in Supabase (Database settings) if needed and update `DATABASE_URL`. |

Supabase product docs: [Connecting to Postgres](https://supabase.com/docs/guides/database/connecting-to-postgres).
