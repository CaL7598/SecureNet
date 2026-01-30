# PostgreSQL Setup Guide

## Option 1: Using Docker (Recommended)

### Step 1: Install Docker Desktop

1. Download Docker Desktop for Windows: https://www.docker.com/products/docker-desktop/
2. Install and restart your computer
3. Start Docker Desktop

### Step 2: Start PostgreSQL Container

```powershell
cd backend
docker-compose up -d
```

### Step 3: Verify Database is Running

```powershell
docker ps
```

Should show `securenet-db` container running.

---

## Option 2: Install PostgreSQL Locally

### Step 1: Download and Install PostgreSQL

1. Download PostgreSQL 15: https://www.postgresql.org/download/windows/
2. Install with these settings:
   - Username: `postgres`
   - Password: `securenet123` (or remember your password)
   - Port: `5432`

### Step 2: Create Database

Open pgAdmin or use psql:

```sql
CREATE DATABASE securenet;
CREATE USER securenet WITH PASSWORD 'securenet123';
GRANT ALL PRIVILEGES ON DATABASE securenet TO securenet;
```

### Step 3: Update Connection String

Edit `backend/app/config.py`:

```python
DATABASE_URL: str = "postgresql://securenet:securenet123@localhost:5432/securenet"
```

---

## Step 4: Install Python Dependencies

```powershell
cd backend
.\venv\Scripts\Activate.ps1
pip install psycopg2-binary
```

---

## Step 5: Create Database Tables

```powershell
cd backend
.\venv\Scripts\Activate.ps1
python -c "from app.database import Base, engine; from app.models import *; Base.metadata.create_all(bind=engine)"
```

---

## Step 6: Seed Initial Data

```powershell
python scripts/seed_data.py
```

---

## Step 7: Restart Backend

```powershell
python -m uvicorn app.main:app --reload --host 0.0.0.0
```

---

## Verify Setup

1. Check database connection:
   ```python
   python scripts/test_database.py
   ```

2. Test API:
   ```python
   python test_api.py
   ```

---

## Troubleshooting

### "Connection refused"
- Check PostgreSQL is running
- Verify port 5432 is not blocked
- Check firewall settings

### "Authentication failed"
- Verify username and password in `config.py`
- Check PostgreSQL user permissions

### "Database does not exist"
- Create the database (see Step 2)

---

## Quick Test

After setup, test the API:

```bash
curl http://localhost:8000/api/v1/health
```

Should return: `{"status":"healthy"}`
