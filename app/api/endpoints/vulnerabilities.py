"""
Vulnerability Information API Endpoints
"""
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.known_vulnerability import KnownVulnerability

router = APIRouter()


@router.get("/vulnerabilities")
async def get_vulnerabilities(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    """Get list of known vulnerabilities"""
    vulnerabilities = db.query(KnownVulnerability).offset(skip).limit(limit).all()
    return {
        "total": len(vulnerabilities),
        "vulnerabilities": [
            {
                "id": v.id,
                "cve_id": v.cve_id,
                "device_model": v.device_model,
                "manufacturer": v.manufacturer,
                "severity": v.severity,
                "description": v.description
            }
            for v in vulnerabilities
        ]
    }
