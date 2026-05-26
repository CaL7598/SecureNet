"""
Email delivery service hooks.

Prefers SendGrid HTTP API (works on Render where SMTP ports are often blocked).
Falls back to SMTP when configured.
"""
from datetime import datetime, timezone
import smtplib
from email.message import EmailMessage
from typing import Any

import httpx

from app.config import settings
from app.services.email_templates import (
    build_verification_html,
    build_verification_plain,
    build_welcome_html,
    build_welcome_plain,
)

LAST_EMAIL_RESULT: dict[str, Any] = {
    "ok": None,
    "channel": None,
    "detail": "No email attempted yet.",
    "to_masked": None,
    "at": None,
}


def _masked(email: str) -> str:
    return email[:2] + "***" + email[email.find("@") :] if "@" in email else "***"


def _record_result(*, ok: bool, channel: str, detail: str, to_email: str) -> None:
    LAST_EMAIL_RESULT.update(
        {
            "ok": ok,
            "channel": channel,
            "detail": detail,
            "to_masked": _masked(to_email),
            "at": datetime.now(timezone.utc).isoformat(),
        }
    )


def email_delivery_status() -> dict[str, Any]:
    key = settings.SENDGRID_API_KEY.strip()
    from_addr = settings.EMAIL_FROM.strip()
    return {
        "delivery_enabled": settings.EMAIL_DELIVERY_ENABLED,
        "sendgrid_configured": bool(key),
        "sendgrid_key_prefix": key[:7] if key else None,
        "from_address": from_addr,
        "smtp_fallback_configured": bool(
            settings.SMTP_HOST.strip() and settings.SMTP_PASSWORD.strip()
        ),
        "last_result": dict(LAST_EMAIL_RESULT),
    }


def _send_via_sendgrid_api(
    *,
    to_email: str,
    subject: str,
    body: str,
    html_body: str | None = None,
) -> bool:
    api_key = settings.SENDGRID_API_KEY.strip()
    from_email = settings.EMAIL_FROM.strip()
    if not api_key:
        _record_result(
            ok=False,
            channel="sendgrid_api",
            detail="SENDGRID_API_KEY is not set.",
            to_email=to_email,
        )
        return False
    if not from_email:
        _record_result(
            ok=False,
            channel="sendgrid_api",
            detail="EMAIL_FROM is not set.",
            to_email=to_email,
        )
        return False

    content = [{"type": "text/plain", "value": body}]
    if html_body:
        content.append({"type": "text/html", "value": html_body})

    payload = {
        "personalizations": [{"to": [{"email": to_email}]}],
        "from": {"email": from_email, "name": settings.APP_NAME},
        "reply_to": {"email": from_email, "name": settings.APP_NAME},
        "subject": subject,
        "content": content,
        "mail_settings": {
            "sandbox_mode": {"enable": False},
        },
        "tracking_settings": {
            "click_tracking": {"enable": False},
            "open_tracking": {"enable": False},
        },
    }

    try:
        response = httpx.post(
            "https://api.sendgrid.com/v3/mail/send",
            headers={
                "Authorization": f"Bearer {api_key}",
                "Content-Type": "application/json",
            },
            json=payload,
            timeout=25.0,
        )
        if response.status_code >= 400:
            detail = response.text[:500] or f"HTTP {response.status_code}"
            print(
                f"[EmailDelivery] SendGrid API failed for {_masked(to_email)}: "
                f"{response.status_code} {detail}"
            )
            _record_result(
                ok=False,
                channel="sendgrid_api",
                detail=detail,
                to_email=to_email,
            )
            return False

        message_id = response.headers.get("x-message-id", "accepted")
        print(f"[EmailDelivery] SendGrid API accepted for {_masked(to_email)} id={message_id}")
        _record_result(
            ok=True,
            channel="sendgrid_api",
            detail=f"Accepted by SendGrid (message-id={message_id}).",
            to_email=to_email,
        )
        return True
    except Exception as exc:  # noqa: BLE001
        print(f"[EmailDelivery] SendGrid API error for {_masked(to_email)}: {exc}")
        _record_result(
            ok=False,
            channel="sendgrid_api",
            detail=str(exc),
            to_email=to_email,
        )
        return False


def _send_via_smtp(
    *,
    to_email: str,
    subject: str,
    body: str,
    html_body: str | None = None,
) -> bool:
    if not settings.SMTP_HOST.strip() or not settings.SMTP_USERNAME.strip() or not settings.SMTP_PASSWORD.strip():
        return False

    msg = EmailMessage()
    msg["Subject"] = subject
    msg["From"] = settings.EMAIL_FROM.strip()
    msg["To"] = to_email
    msg.set_content(body)
    if html_body:
        msg.add_alternative(html_body, subtype="html")

    try:
        with smtplib.SMTP(settings.SMTP_HOST.strip(), settings.SMTP_PORT, timeout=20) as server:
            server.ehlo()
            if settings.SMTP_USE_TLS:
                server.starttls()
                server.ehlo()
            server.login(settings.SMTP_USERNAME.strip(), settings.SMTP_PASSWORD.strip())
            server.send_message(msg)
        print(f"[EmailDelivery] SMTP sent to {_masked(to_email)}")
        _record_result(ok=True, channel="smtp", detail="Sent via SMTP.", to_email=to_email)
        return True
    except Exception as exc:  # noqa: BLE001
        print(f"[EmailDelivery] SMTP failed for {_masked(to_email)}: {exc}")
        _record_result(ok=False, channel="smtp", detail=str(exc), to_email=to_email)
        return False


def _deliver_email(
    *,
    to_email: str,
    subject: str,
    body: str,
    html_body: str | None = None,
) -> bool:
    to_email = to_email.strip().lower()
    if not settings.EMAIL_DELIVERY_ENABLED:
        print(f"[EmailDelivery] disabled; skipped {_masked(to_email)}")
        _record_result(
            ok=False,
            channel="none",
            detail="EMAIL_DELIVERY_ENABLED is false.",
            to_email=to_email,
        )
        return False

    if settings.SENDGRID_API_KEY.strip():
        if _send_via_sendgrid_api(
            to_email=to_email,
            subject=subject,
            body=body,
            html_body=html_body,
        ):
            return True

    return _send_via_smtp(
        to_email=to_email,
        subject=subject,
        body=body,
        html_body=html_body,
    )


def send_password_reset_code(email: str, code: str) -> bool:
    body = (
        "You requested a password reset for SecureNet.\n\n"
        f"Your verification code is: {code}\n\n"
        f"This code expires in {settings.PASSWORD_RESET_CODE_TTL_MINUTES} minutes."
    )
    if settings.DEBUG:
        print(f"[PasswordReset] code for {email}: {code}")
    sent = _deliver_email(
        to_email=email,
        subject="SecureNet password reset code",
        body=body,
    )
    if not sent:
        print(f"[PasswordReset] fallback log for {_masked(email)}: code={code}")
    return sent


def send_registration_welcome_email(
    email: str,
    *,
    full_name: str | None = None,
) -> bool:
    """Welcome email only — no verification code (use send_email_verification_code for that)."""
    subject, body = build_welcome_plain(full_name=full_name)
    html_body = build_welcome_html(full_name=full_name)
    if settings.DEBUG:
        print(f"[WelcomeEmail] sending welcome to {email}")
    sent = _deliver_email(
        to_email=email,
        subject=subject,
        body=body,
        html_body=html_body,
    )
    if not sent:
        print(f"[WelcomeEmail] delivery failed for {_masked(email)}")
    return sent


def send_email_verification_code(email: str, code: str) -> bool:
    subject, body = build_verification_plain(code=code)
    html_body = build_verification_html(code=code)
    if settings.DEBUG:
        print(f"[EmailVerification] code for {email}: {code}")
    sent = _deliver_email(
        to_email=email,
        subject=subject,
        body=body,
        html_body=html_body,
    )
    if not sent:
        print(f"[EmailVerification] fallback log for {_masked(email)}: code={code}")
    return sent
