"""
Authentication endpoints with JWT + verification + reset support.
"""
from datetime import datetime, timedelta, timezone
import hashlib
import re
import secrets

from fastapi import APIRouter, Depends, Header, HTTPException
from jose import JWTError, jwt
from passlib.context import CryptContext
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from app.config import settings
from app.database import get_db
from app.models.email_verification_token import EmailVerificationToken
from app.models.password_reset_token import PasswordResetToken
from app.models.refresh_token import RefreshToken
from app.models.user import User
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


class RegisterIn(BaseModel):
    email: str
    password: str = Field(min_length=8, max_length=256)
    full_name: str | None = None


class LoginIn(BaseModel):
    email: str
    password: str = Field(min_length=8, max_length=256)


class VerifyEmailIn(BaseModel):
    email: str
    code: str = Field(min_length=4, max_length=12)


class ProfileOut(BaseModel):
    id: int
    email: str
    full_name: str | None = None
    is_email_verified: bool


class TokenOut(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    user: ProfileOut


class ProfileUpdateIn(BaseModel):
    full_name: str | None = Field(default=None, max_length=120)


class RefreshIn(BaseModel):
    refresh_token: str


def _hash_code(code: str) -> str:
    return hashlib.sha256(code.encode("utf-8")).hexdigest()


def _hash_token(token: str) -> str:
    return hashlib.sha256(token.encode("utf-8")).hexdigest()


# Keep backward compatibility for previously stored bcrypt hashes while
# defaulting new hashes to PBKDF2 for deploy stability.
pwd_context = CryptContext(schemes=["pbkdf2_sha256", "bcrypt"], deprecated="auto")


def _create_access_token(user: User) -> str:
    now = datetime.now(timezone.utc)
    expire = now + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    payload = {
        "sub": str(user.id),
        "email": user.email,
        "exp": int(expire.timestamp()),
        "iat": int(now.timestamp()),
    }
    return jwt.encode(payload, settings.JWT_SECRET, algorithm=settings.JWT_ALGORITHM)


def _to_profile(user: User) -> ProfileOut:
    return ProfileOut(
        id=user.id,
        email=user.email,
        full_name=user.full_name,
        is_email_verified=bool(user.is_email_verified),
    )


def _issue_refresh_token(user: User, db: Session) -> str:
    raw = secrets.token_urlsafe(48)
    now = datetime.now(timezone.utc)
    db.add(
        RefreshToken(
            user_id=user.id,
            token_hash=_hash_token(raw),
            expires_at=now + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS),
            revoked=False,
        )
    )
    db.commit()
    return raw


def get_current_user(
    authorization: str | None = Header(default=None),
    db: Session = Depends(get_db),
) -> User:
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing bearer token.")
    token = authorization.removeprefix("Bearer ").strip()
    try:
        payload = jwt.decode(token, settings.JWT_SECRET, algorithms=[settings.JWT_ALGORITHM])
        subject = payload.get("sub")
        if not subject:
            raise HTTPException(status_code=401, detail="Invalid token.")
        user = db.query(User).filter(User.id == int(subject)).first()
        if not user:
            raise HTTPException(status_code=401, detail="User not found.")
        return user
    except (JWTError, ValueError):
        raise HTTPException(status_code=401, detail="Invalid token.")


def get_current_user_optional(
    authorization: str | None = Header(default=None),
    db: Session = Depends(get_db),
) -> User | None:
    if not authorization or not authorization.startswith("Bearer "):
        return None
    try:
        return get_current_user(authorization=authorization, db=db)
    except HTTPException:
        return None


def _send_verification_code(email: str, code: str) -> None:
    # Reuse existing mail abstraction for now.
    send_password_reset_code(email=email, code=code)


@router.post("/auth/register", response_model=TokenOut)
async def register(payload: RegisterIn, db: Session = Depends(get_db)):
    email = payload.email.lower().strip()
    if not _EMAIL_RE.match(email):
        raise HTTPException(status_code=422, detail="Invalid email.")
    existing = db.query(User).filter(User.email == email).first()
    if existing:
        raise HTTPException(status_code=409, detail="Email already registered.")

    user = User(
        email=email,
        full_name=payload.full_name.strip() if payload.full_name else None,
        password_hash=pwd_context.hash(payload.password),
        is_email_verified=False,
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    code = f"{secrets.randbelow(1_000_000):06d}"
    now = datetime.now(timezone.utc)
    db.add(
        EmailVerificationToken(
            user_id=user.id,
            code_hash=_hash_code(code),
            expires_at=now + timedelta(minutes=settings.EMAIL_VERIFICATION_CODE_TTL_MINUTES),
            used_at=None,
        )
    )
    db.commit()
    _send_verification_code(email=email, code=code)

    return TokenOut(
        access_token=_create_access_token(user),
        refresh_token=_issue_refresh_token(user, db),
        user=_to_profile(user),
    )


@router.post("/auth/login", response_model=TokenOut)
async def login(payload: LoginIn, db: Session = Depends(get_db)):
    email = payload.email.lower().strip()
    user = db.query(User).filter(User.email == email).first()
    if not user or not pwd_context.verify(payload.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Invalid email or password.")
    return TokenOut(
        access_token=_create_access_token(user),
        refresh_token=_issue_refresh_token(user, db),
        user=_to_profile(user),
    )


@router.post("/auth/refresh", response_model=TokenOut)
async def refresh(payload: RefreshIn, db: Session = Depends(get_db)):
    now = datetime.now(timezone.utc)
    stored = (
        db.query(RefreshToken)
        .filter(
            RefreshToken.token_hash == _hash_token(payload.refresh_token),
            RefreshToken.revoked.is_(False),
        )
        .first()
    )
    if not stored or now > stored.expires_at:
        raise HTTPException(status_code=401, detail="Invalid refresh token.")
    user = db.query(User).filter(User.id == stored.user_id).first()
    if not user:
        raise HTTPException(status_code=401, detail="User not found.")

    stored.revoked = True
    db.commit()
    return TokenOut(
        access_token=_create_access_token(user),
        refresh_token=_issue_refresh_token(user, db),
        user=_to_profile(user),
    )


@router.post("/auth/logout", response_model=ApiMessageOut)
async def logout(payload: RefreshIn, db: Session = Depends(get_db)):
    stored = (
        db.query(RefreshToken)
        .filter(RefreshToken.token_hash == _hash_token(payload.refresh_token))
        .first()
    )
    if stored:
        stored.revoked = True
        db.commit()
    return ApiMessageOut(message="Logged out.")


@router.get("/auth/me", response_model=ProfileOut)
async def me(user: User = Depends(get_current_user)):
    return _to_profile(user)


@router.put("/auth/profile", response_model=ProfileOut)
async def update_profile(
    payload: ProfileUpdateIn,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    user.full_name = payload.full_name.strip() if payload.full_name else None
    db.commit()
    db.refresh(user)
    return _to_profile(user)


@router.post("/auth/verify-email", response_model=ApiMessageOut)
async def verify_email(payload: VerifyEmailIn, db: Session = Depends(get_db)):
    email = payload.email.lower().strip()
    user = db.query(User).filter(User.email == email).first()
    if not user:
        raise HTTPException(status_code=400, detail="Invalid verification code.")
    now = datetime.now(timezone.utc)
    token = (
        db.query(EmailVerificationToken)
        .filter(
            EmailVerificationToken.user_id == user.id,
            EmailVerificationToken.used_at.is_(None),
        )
        .order_by(EmailVerificationToken.requested_at.desc())
        .first()
    )
    if not token or now > token.expires_at or token.code_hash != _hash_code(payload.code.strip()):
        raise HTTPException(status_code=400, detail="Invalid verification code.")

    token.used_at = now
    user.is_email_verified = True
    db.commit()
    return ApiMessageOut(message="Email verified successfully.")


@router.post("/auth/resend-verification", response_model=ApiMessageOut)
async def resend_verification(payload: PasswordResetRequestIn, db: Session = Depends(get_db)):
    email = payload.email.lower().strip()
    user = db.query(User).filter(User.email == email).first()
    if not user:
        return ApiMessageOut(message="If the account exists, a code has been sent.")
    now = datetime.now(timezone.utc)
    code = f"{secrets.randbelow(1_000_000):06d}"
    db.add(
        EmailVerificationToken(
            user_id=user.id,
            code_hash=_hash_code(code),
            expires_at=now + timedelta(minutes=settings.EMAIL_VERIFICATION_CODE_TTL_MINUTES),
            used_at=None,
        )
    )
    db.commit()
    _send_verification_code(email=email, code=code)
    return ApiMessageOut(message="If the account exists, a code has been sent.")


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

    user = db.query(User).filter(User.email == email).first()
    if user:
        user.password_hash = pwd_context.hash(payload.new_password)
        db.commit()

    return ApiMessageOut(message="Password has been reset successfully.")

