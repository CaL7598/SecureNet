# Quick PostgreSQL Setup

## Option 1: Docker (Easiest)

### Step 1: Install Docker Desktop
1. Download: https://www.docker.com/products/docker-desktop/
2. Install and restart computer
3. Start Docker Desktop

### Step 2: Start PostgreSQL
```powershell
cd backend
docker-compose up -d
```

### Step 3: Create Tables & Seed Data
```powershell
.\venv\Scripts\Activate.ps1
python -c "from app.database import Base, engine; from app.models import *; Base.metadata.create_all(bind=engine)"
python scripts/seed_data.py
```

Done! ✅

---

## Option 2: Local PostgreSQL

### Step 1: Install PostgreSQL
1. Download: https://www.postgresql.org/download/windows/
2. Install with:
   - Port: `5432`
   - Password: `securenet123` (or remember your password)

### Step 2: Create Database
Open **pgAdmin** or **psql** and run:

```sql
CREATE DATABASE securenet;
CREATE USER securenet WITH PASSWORD 'securenet123';
GRANT ALL PRIVILEGES ON DATABASE securenet TO securenet;
```

### Step 3: Update Config (if needed)
If you used a different password, edit `backend/app/config.py`:
```python
DATABASE_URL: str = "postgresql://securenet:YOUR_PASSWORD@localhost:5432/securenet"
```

### Step 4: Create Tables & Seed
```powershell
cd backend
.\venv\Scripts\Activate.ps1
python -c "from app.database import Base, engine; from app.models import *; Base.metadata.create_all(bind=engine)"
python scripts/seed_data.py
```

Done! ✅

---

## Verify Setup

```powershell
python scripts/test_database.py
```

Should show database data.

---

## Start Backend

```powershell
python -m uvicorn app.main:app --reload
```

Backend will now use PostgreSQL! 🎉
