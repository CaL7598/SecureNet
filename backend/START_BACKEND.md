# How to Start the Backend

## Quick Start (PowerShell)

```powershell
# Navigate to backend directory
cd backend

# Activate virtual environment
.\venv\Scripts\Activate.ps1

# Start the server
python -m uvicorn app.main:app --reload --host 0.0.0.0
```

## Or Use the Script

```powershell
cd backend
.\start_backend.ps1
```

## Verify It's Running

Open in browser: http://localhost:8000/docs

Should show the API documentation.

## Health Check

http://localhost:8000/api/v1/health

Should return: `{"status":"healthy"}`

## Note

The backend will work without PostgreSQL for testing. It uses in-memory fallbacks for vulnerability data.
