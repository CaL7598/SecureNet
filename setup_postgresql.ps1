# PowerShell script to set up PostgreSQL for SecureNet
# This script helps you set up PostgreSQL either with Docker or locally

Write-Host "=== SecureNet PostgreSQL Setup ===" -ForegroundColor Green
Write-Host ""

# Check if Docker is available
$dockerAvailable = $false
try {
    $dockerVersion = docker --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        $dockerAvailable = $true
        Write-Host "Docker is installed: $dockerVersion" -ForegroundColor Green
    }
} catch {
    Write-Host "Docker is not installed" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Choose setup method:" -ForegroundColor Cyan
Write-Host "1. Use Docker (Recommended - if Docker is installed)"
Write-Host "2. Use local PostgreSQL installation"
Write-Host "3. Skip PostgreSQL setup for now (use SQLite fallback)"
Write-Host ""

$choice = Read-Host "Enter choice (1/2/3)"

if ($choice -eq "1" -and $dockerAvailable) {
    Write-Host "Setting up PostgreSQL with Docker..." -ForegroundColor Green
    
    # Start PostgreSQL container
    docker-compose up -d
    
    Write-Host "Waiting for database to be ready..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    
    Write-Host "PostgreSQL container started!" -ForegroundColor Green
} elseif ($choice -eq "2") {
    Write-Host "Using local PostgreSQL installation" -ForegroundColor Green
    Write-Host "Make sure PostgreSQL is installed and running on port 5432" -ForegroundColor Yellow
    Write-Host "Database: securenet" -ForegroundColor Yellow
    Write-Host "User: securenet" -ForegroundColor Yellow
    Write-Host "Password: securenet123" -ForegroundColor Yellow
} elseif ($choice -eq "3") {
    Write-Host "Skipping PostgreSQL setup. Using SQLite fallback." -ForegroundColor Yellow
    exit
} else {
    Write-Host "Invalid choice or Docker not available" -ForegroundColor Red
    exit
}

Write-Host ""
Write-Host "Installing Python dependencies..." -ForegroundColor Yellow
.\venv\Scripts\Activate.ps1
pip install psycopg2-binary

Write-Host ""
Write-Host "Creating database tables..." -ForegroundColor Yellow
python -c "from app.database import Base, engine; from app.models import *; Base.metadata.create_all(bind=engine); print('Tables created!')"

Write-Host ""
Write-Host "Seeding initial data..." -ForegroundColor Yellow
python scripts/seed_data.py

Write-Host ""
Write-Host "=== Setup Complete! ===" -ForegroundColor Green
Write-Host "You can now start the backend server:" -ForegroundColor Cyan
Write-Host "  python -m uvicorn app.main:app --reload" -ForegroundColor White
