"""
Network Analysis API Endpoint
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.schemas.scan import NetworkScanRequest, NetworkAnalysisResponse
from app.services.analyzer import NetworkAnalyzer

router = APIRouter()


@router.post("/analyze-network", response_model=NetworkAnalysisResponse)
async def analyze_network(
    scan_request: NetworkScanRequest,
    db: Session = Depends(get_db)
):
    """
    Analyze network scan results and return vulnerability assessment
    
    Accepts a list of devices with their open ports and returns
    a comprehensive security analysis with risk scores and recommendations.
    """
    try:
        analyzer = NetworkAnalyzer(db)
        analysis = analyzer.analyze_network(scan_request)
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
