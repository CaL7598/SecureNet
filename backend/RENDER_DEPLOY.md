# Deploy SecureNet API on Render

Goal: a public `https://…` API so the Flutter app works from any network.

## Avoid Render free PostgreSQL (time-limited)

Render’s **free Postgres** databases **expire**. After expiration, the instance stops and data may be **deleted** unless you upgrade to a paid plan. If you already hit that, do **not** recreate the same pattern for anything you care about.

**Stable options for `DATABASE_URL`:**

| Approach | What to expect |
|----------|------------------|
| **[Neon](https://neon.tech)** (serverless Postgres) | Free tier with usage/scale limits; data is not on the same “expire in N days unless upgrade” model as Render’s old free DB. Good pairing: **Neon DB + Render Web Service (free)**. |
| **[Supabase](https://supabase.com)** | Managed Postgres + extras; free tier has its own limits—read their docs. |
| **Paid [Render PostgreSQL](https://render.com/docs/postgresql-creating-connecting)** | Smallest instance (e.g. `basic-256mb`) is **monthly cost** but **does not use the free-tier expiration** behavior. |
| **Other hosts** | Railway, Fly.io, RDS, etc.—any Postgres URL works if reachable from Render. |

The repo `render.yaml` deploys **only the Web Service**. You create the database **elsewhere**, then paste the connection string into Render as `DATABASE_URL`.

## Using Supabase as Postgres

Supabase is **PostgreSQL**. This backend does not need the Supabase JS/Flutter SDK for the database—only a **connection URI** the same way as local Postgres.

1. **[supabase.com](https://supabase.com)** → New project → pick region → set a database password (save it).
2. **Project Settings** (gear) → **Database**.
3. Under **Connection string**, choose **URI** (or **SQLAlchemy** if shown). Copy the string. It should look like:
   `postgresql://postgres.[ref]:[YOUR-PASSWORD]@aws-0-[region].pooler.supabase.com:6543/postgres`
   or port **5432** for a direct host (see below).
4. Replace `[YOUR-PASSWORD]` with the password you set (URL-encode special characters in the password, e.g. `@` → `%40`).
5. In **Render** → your Web Service → **Environment** → set **`DATABASE_URL`** to that full string → save → redeploy.

**Pooler vs direct**

- **Port 6543** (Supabase **connection pooler**, often “transaction” or “session” mode in the UI) works well from a small cloud host. If the dashboard offers **Session** mode for ORMs / long-lived apps, prefer that for SQLAlchemy; **Transaction** mode is aimed at very short connections.
- **Port 5432** (direct to the DB) is fine if your host can reach it; some networks have **IPv6** requirements—if Render cannot connect, try the **pooler** URI instead.

The app appends **`sslmode=require`** automatically when the URL looks like Supabase and SSL is not already set (Supabase requires TLS).

**Tables**

On startup the API runs `create_all` against **your** Supabase Postgres (same as any Postgres). You do **not** need to enable “Supabase Auth” or Row Level Security for this—those are optional extras if you later build features on top of Supabase’s auth.

**Optional later**

- **Flutter + Supabase Auth**: a different path from “FastAPI owns users”; only add if you want login/sign-up handled by Supabase instead of your API.
- **Supabase Storage / Realtime**: unrelated to replacing Render Postgres; use when you have a concrete feature.

## What Render runs

- **Web Service** (Docker): FastAPI from `backend/Dockerfile`.
- **Postgres:** not defined in this Blueprint—you supply `DATABASE_URL`.

Tables are created on startup (`create_all`). Optionally seed once (see end).

## Recommended flow (Neon + Render)

1. Create a project in **Neon** (or Supabase), create a database, copy the **connection string** (often `postgresql://…`; use the URL intended for server/backend apps).
2. Push this repo to **GitHub** (with `render.yaml` at the **repository root**).
3. Render → **New** → **Blueprint** → connect repo → **Apply** (creates `securenet-api` only).
4. Render → **securenet-api** → **Environment** → add **`DATABASE_URL`** = your Neon (or other) URL → **Save** → **Manual Deploy** if the first deploy failed without it.

The app accepts `postgres://` or `postgresql://` and normalizes for SQLAlchemy.

5. Open `https://<your-service>.onrender.com/api/v1/health` (try from **cellular** to confirm off-LAN).

## Manual Web Service (no Blueprint)

1. **New → Web Service** → your repo.
   - **Dockerfile path:** `backend/Dockerfile`
   - **Docker build context:** `backend`
2. **Environment:** `DATABASE_URL` (required), `DEBUG` = `false` (recommended).
3. **Health check path:** `/api/v1/health`

## Flutter app (phone anywhere)

```bash
flutter run --dart-define=API_BASE_URL=https://<your-service>.onrender.com
flutter build apk --dart-define=API_BASE_URL=https://<your-service>.onrender.com
```

## Optional: seed vulnerability data

Render **Shell** for the service:

```bash
cd /app && python scripts/seed_data.py
```

## Email (SendGrid)

Verification and password-reset codes are sent over **SMTP** when enabled.

1. [SendGrid](https://sendgrid.com) → create an API key (Mail Send permission).
2. **Settings → Sender Authentication** → verify a **Single Sender** or your domain.
3. On Render → **Environment**:

| Variable | Value |
|----------|--------|
| `EMAIL_DELIVERY_ENABLED` | `true` |
| `SENDGRID_API_KEY` | your API key (do not commit to git) |
| `EMAIL_FROM` | the **exact** verified sender address in SendGrid |

SendGrid SMTP defaults apply automatically (`smtp.sendgrid.net`, user `apikey`). Optional overrides: `SMTP_HOST`, `SMTP_USERNAME`, `SMTP_PASSWORD`.

After deploy, test **Resend verification** or **Forgot password** from the app; check Render **Logs** if delivery fails (unverified `EMAIL_FROM` is the usual cause).

## Notes

- **Free Web** on Render **sleeps** when idle; first request after a while can be slow—normal, not the same as DB deletion.
- **CORS** defaults to `["*"]` for a mobile-only demo.
- **Docs:** `https://<your-service>.onrender.com/docs`
