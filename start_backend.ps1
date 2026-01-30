# PowerShell script to start the backend server
# Run this from the backend directory

Write-Host "Starting SecureNet Backend..." -ForegroundColor Green

# Activate virtual environment
if (Test-Path "venv\Scripts\Activate.ps1") {
    Write-Host "Activating virtual environment..." -ForegroundColor Yellow
    .\venv\Scripts\Activate.ps1
} else {
    Write-Host "Virtual environment not found. Creating..." -ForegroundColor Yellow
    python -m venv venv
    .\venv\Scripts\Activate.ps1
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    pip install fastapi uvicorn[standard] sqlalchemy pydantic pydantic-settings python-dotenv httpx
}

# Check if database is needed (for now, skip if psycopg2 fails)
Write-Host "Starting API server..." -ForegroundColor Green
Write-Host "API will be available at: http://localhost:8000" -ForegroundColor Cyan
Write-Host "API Docs at: http://localhost:8000/docs" -ForegroundColor Cyan
Write-Host ""

# Start the server
python -m uvicorn app.main:app --reload --host 0.0.0.0
