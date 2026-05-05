"""
Network analysis and persisted user scan history endpoints.
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.schemas.scan import NetworkScanRequest, NetworkAnalysisResponse
from app.services.analyzer import NetworkAnalyzer
from app.api.endpoints.auth import get_current_user, get_current_user_optional
from app.models.scan_session import ScanSession
from app.models.user import User

router = APIRouter()


@router.post("/analyze-network", response_model=NetworkAnalysisResponse)
async def analyze_network(
    scan_request: NetworkScanRequest,
    db: Session = Depends(get_db),
    user: User | None = Depends(get_current_user_optional),
):
    """
    Analyze network scan results and return vulnerability assessment
    
    Accepts a list of devices with their open ports and returns
    a comprehensive security analysis with risk scores and recommendations.
    """
    try:
        analyzer = NetworkAnalyzer(db)
        analysis = analyzer.analyze_network(scan_request)
        if user:
            db.add(
                ScanSession(
                    user_id=user.id,
                    network_score=analysis.network_score,
                    overall_risk=str(analysis.overall_risk),
                    analysis_payload=analysis.model_dump(mode="json"),
                )
            )
            db.commit()
        return analysis
    except Exception as e:
        # If database error, try without database
        try:
            from app.database import SessionLocal
            # Create a dummy session for fallback
            dummy_db = SessionLocal()
            analyzer = NetworkAnalyzer(dummy_db)
            analysis = analyzer.analyze_network(scan_request)
            return analysis
        except Exception as e2:
            raise HTTPException(status_code=500, detail=f"Analysis failed: {str(e2)}")


@router.get("/scan-history")
async def scan_history(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    rows = (
        db.query(ScanSession)
        .filter(ScanSession.user_id == user.id)
        .order_by(ScanSession.created_at.desc())
        .limit(100)
        .all()
    )
    return [
        {
            "id": row.id,
            "created_at": row.created_at,
            "network_score": row.network_score,
            "overall_risk": row.overall_risk,
            "analysis": row.analysis_payload,
        }
        for row in rows
    ]
