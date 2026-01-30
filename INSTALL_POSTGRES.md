# Installing PostgreSQL for SecureNet

## Quick Decision Guide

**Do you have Docker Desktop?**
- ✅ Yes → Use **Option 1: Docker** (5 minutes)
- ❌ No → Use **Option 2: Local Install** (15 minutes)

---

## Option 1: Docker (Recommended) 🐳

### Why Docker?
- ✅ Easy setup
- ✅ No system-wide installation
- ✅ Easy to remove later
- ✅ Works on any OS

### Steps:

1. **Download Docker Desktop:**
   - https://www.docker.com/products/docker-desktop/
   - Install and restart computer

2. **Start PostgreSQL:**
   ```powershell
   cd backend
   docker-compose up -d
   ```

3. **Create tables:**
   ```powershell
   .\venv\Scripts\Activate.ps1
   python -c "from app.database import Base, engine; from app.models import *; Base.metadata.create_all(bind=engine)"
   python scripts/seed_data.py
   ```

**That's it!** ✅

---

## Option 2: Local PostgreSQL Installation 💾

### Steps:

1. **Download PostgreSQL:**
   - https://www.postgresql.org/download/windows/
   - Choose version 15 or 16
   - Run installer

2. **During Installation:**
   - Port: `5432` (default)
   - Password: `securenet123` (or remember it)
   - Components: Install everything

3. **Create Database:**
   
   **Option A: Using pgAdmin (GUI)**
   - Open pgAdmin 4
   - Right-click "Databases" → Create → Database
   - Name: `securenet`
   - Click Save
   
   **Option B: Using psql (Command Line)**
   ```sql
   -- Open psql (search "psql" in Start menu)
   CREATE DATABASE securenet;
   CREATE USER securenet WITH PASSWORD 'securenet123';
   GRANT ALL PRIVILEGES ON DATABASE securenet TO securenet;
   \q
   ```

4. **Update Config (if different password):**
   - Edit `backend/app/config.py`
   - Update `DATABASE_URL` with your password

5. **Create Tables:**
   ```powershell
   cd backend
   .\venv\Scripts\Activate.ps1
   python -c "from app.database import Base, engine; from app.models import *; Base.metadata.create_all(bind=engine)"
   python scripts/seed_data.py
   ```

**Done!** ✅

---

## Verify Installation

```powershell
cd backend
.\venv\Scripts\Activate.ps1
python scripts/test_database.py
```

Should show:
- ✅ Found X manufacturers
- ✅ Found X default credentials
- ✅ Found X insecure ports
- ✅ Found X known vulnerabilities

---

## Troubleshooting

### "Connection refused"
- PostgreSQL not running
- Check Windows Services: `services.msc` → Find "postgresql"
- Start the service

### "Authentication failed"
- Wrong password in `config.py`
- Check PostgreSQL user exists

### "Database does not exist"
- Create database (see Step 3 above)

---

## Next Steps

After PostgreSQL is set up:

1. **Restart backend:**
   ```powershell
   python -m uvicorn app.main:app --reload
   ```

2. **Test the API:**
   - Visit: http://localhost:8000/docs
   - Try the `/analyze-network` endpoint

3. **Run a scan in the app:**
   - Use Demo Mode or Real Scan
   - Should now use database for vulnerability analysis

---

**Need help?** Check `POSTGRESQL_SETUP.md` for detailed instructions.
