"""
Device Information API Endpoints
"""
from fastapi import APIRouter

router = APIRouter()


@router.get("/devices/{device_id}")
async def get_device(device_id: int):
    """Get detailed information about a specific device"""
    # TODO: Implement device detail endpoint
    return {"message": "Device endpoint - to be implemented", "device_id": device_id}
