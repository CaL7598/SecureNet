"""
Basic production ops middleware: request logging, in-memory rate limiting,
and incident tracking IDs for server errors.
"""
from collections import defaultdict, deque
from datetime import datetime, timedelta, timezone
import uuid

from fastapi import Request
from fastapi.responses import JSONResponse
from starlette.middleware.base import BaseHTTPMiddleware

from app.config import settings

INCIDENT_LOG: deque[dict] = deque(maxlen=500)
_RATE_BUCKETS: dict[str, deque[datetime]] = defaultdict(deque)


class RateLimitMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        client = request.client.host if request.client else "unknown"
        now = datetime.now(timezone.utc)
        window_start = now - timedelta(minutes=1)
        bucket = _RATE_BUCKETS[client]
        while bucket and bucket[0] < window_start:
            bucket.popleft()
        if len(bucket) >= settings.RATE_LIMIT_REQUESTS_PER_MINUTE:
            return JSONResponse(
                status_code=429,
                content={"detail": "Rate limit exceeded. Try again shortly."},
            )
        bucket.append(now)
        return await call_next(request)


class OpsMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        started = datetime.now(timezone.utc)
        try:
            response = await call_next(request)
            duration_ms = int((datetime.now(timezone.utc) - started).total_seconds() * 1000)
            print(f"[REQ] {request.method} {request.url.path} {response.status_code} {duration_ms}ms")
            return response
        except Exception as exc:  # noqa: BLE001
            incident_id = uuid.uuid4().hex[:12]
            INCIDENT_LOG.append(
                {
                    "incident_id": incident_id,
                    "at": datetime.now(timezone.utc).isoformat(),
                    "path": request.url.path,
                    "method": request.method,
                    "error": str(exc),
                }
            )
            return JSONResponse(
                status_code=500,
                content={
                    "detail": "Internal server error.",
                    "incident_id": incident_id,
                },
            )
