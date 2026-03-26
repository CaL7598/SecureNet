"""
Authentication-related API endpoints.

Currently implements password reset request/confirm flow used by mobile app.
"""
from datetime import datetime, timedelta, timezone
import hashlib
import re
import secrets

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from app.config import settings
from app.database import get_db
from app.models.password_reset_token import PasswordResetToken
from app.services.email_service import send_password_reset_code

router = APIRouter()

_EMAIL_RE = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")


class PasswordResetRequestIn(BaseModel):
    email: str


class PasswordResetConfirmIn(BaseModel):
    email: str
    code: str = Field(min_length=4, max_length=12)
    new_password: str = Field(min_length=8, max_length=256)


class ApiMessageOut(BaseModel):
    message: str


def _hash_code(code: str) -> str:
    return hashlib.sha256(code.encode("utf-8")).hexdigest()


@router.post("/auth/password-reset/request", response_model=ApiMessageOut)
async def request_password_reset(
    payload: PasswordResetRequestIn,
    db: Session = Depends(get_db),
):
    """
    Generate a one-time reset code for an email.

    Note:
    - Returns generic success message to avoid user enumeration.
    - For now, code delivery is simulated by logging/return flow only.
      Integrate an email/SMS provider in production.
    """
    now = datetime.now(timezone.utc)
    email = payload.email.lower().strip()
    if not _EMAIL_RE.match(email):
        raise HTTPException(status_code=422, detail="Invalid email.")

    latest = (
        db.query(PasswordResetToken)
        .filter(PasswordResetToken.email == email)
        .order_by(PasswordResetToken.requested_at.desc())
        .first()
    )
    if latest and (now - latest.requested_at).total_seconds() < settings.PASSWORD_RESET_REQUEST_COOLDOWN_SECONDS:
        raise HTTPException(
            status_code=429,
            detail="Please wait before requesting another reset code.",
        )

    # Mark stale, unused tokens as used to keep confirm logic straightforward.
    db.query(PasswordResetToken).filter(
        PasswordResetToken.email == email,
        PasswordResetToken.used_at.is_(None),
    ).update({PasswordResetToken.used_at: now}, synchronize_session=False)

    code = f"{secrets.randbelow(1_000_000):06d}"
    expires_at = now + timedelta(minutes=settings.PASSWORD_RESET_CODE_TTL_MINUTES)

    token = PasswordResetToken(
        email=email,
        code_hash=_hash_code(code),
        expires_at=expires_at,
        requested_at=now,
        used_at=None,
    )
    db.add(token)
    db.commit()

    send_password_reset_code(email=email, code=code)
    return ApiMessageOut(message="If that account exists, a reset code has been sent.")


@router.post("/auth/password-reset/confirm", response_model=ApiMessageOut)
async def confirm_password_reset(
    payload: PasswordResetConfirmIn,
    db: Session = Depends(get_db),
):
    """
    Validate reset code and accept new password.

    Note:
    - This endpoint currently validates code flow only.
    - Integrate with a real user/auth table to persist new password hash.
    """
    email = payload.email.lower().strip()
    if not _EMAIL_RE.match(email):
        raise HTTPException(status_code=422, detail="Invalid email.")

    now = datetime.now(timezone.utc)
    token = (
        db.query(PasswordResetToken)
        .filter(
            PasswordResetToken.email == email,
            PasswordResetToken.used_at.is_(None),
        )
        .order_by(PasswordResetToken.requested_at.desc())
        .first()
    )
    if not token:
        raise HTTPException(status_code=400, detail="Invalid or expired reset code.")

    if now > token.expires_at:
        token.used_at = now
        db.commit()
        raise HTTPException(status_code=400, detail="Invalid or expired reset code.")

    if _hash_code(payload.code.strip()) != token.code_hash:
        raise HTTPException(status_code=400, detail="Invalid or expired reset code.")

    token.used_at = now
    db.commit()

    # TODO: integrate with real auth user table and persist password hash update.
    _ = payload.new_password

    return ApiMessageOut(message="Password has been reset successfully.")

