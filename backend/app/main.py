"""
SecureNet Backend - FastAPI Application Entry Point
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.api.endpoints import analyze, auth, devices, vulnerabilities

app = FastAPI(
    title="SecureNet API",
    description="Wi-Fi Security Auditing Tool Backend API",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# CORS middleware for mobile app
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(analyze.router, prefix="/api/v1", tags=["Analysis"])
app.include_router(auth.router, prefix="/api/v1", tags=["Auth"])
app.include_router(devices.router, prefix="/api/v1", tags=["Devices"])
app.include_router(vulnerabilities.router, prefix="/api/v1", tags=["Vulnerabilities"])


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "SecureNet API",
        "version": "1.0.0",
        "docs": "/docs"
    }


@app.get("/api/v1/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "service": "SecureNet API"}
