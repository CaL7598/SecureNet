"""
Email delivery service hooks.

Sends verification and reset codes over SMTP when configured.
"""
import smtplib
from email.message import EmailMessage

from app.config import settings


def _masked(email: str) -> str:
    return email[:2] + "***" + email[email.find("@") :] if "@" in email else "***"


def _deliver_email(*, to_email: str, subject: str, body: str) -> bool:
    if not settings.EMAIL_DELIVERY_ENABLED:
        return False
    if not settings.SMTP_HOST or not settings.SMTP_USERNAME or not settings.SMTP_PASSWORD:
        return False

    msg = EmailMessage()
    msg["Subject"] = subject
    msg["From"] = settings.EMAIL_FROM
    msg["To"] = to_email
    msg.set_content(body)

    try:
        with smtplib.SMTP(settings.SMTP_HOST, settings.SMTP_PORT, timeout=15) as server:
            server.ehlo()
            if settings.SMTP_USE_TLS:
                server.starttls()
                server.ehlo()
            server.login(settings.SMTP_USERNAME, settings.SMTP_PASSWORD)
            server.send_message(msg)
        return True
    except Exception as exc:  # noqa: BLE001
        print(f"[EmailDelivery] failed for {_masked(to_email)}: {exc}")
        return False


def send_password_reset_code(email: str, code: str) -> None:
    if settings.DEBUG:
        print(f"[PasswordReset] code for {email}: {code}")
        return

    # SMTP temporarily disabled: keep log fallback for now.
    print(f"[PasswordReset] fallback log for {_masked(email)}: code={code}")


def send_email_verification_code(email: str, code: str) -> None:
    if settings.DEBUG:
        print(f"[EmailVerification] code for {email}: {code}")
        return

    # SMTP temporarily disabled: keep log fallback for now.
    print(f"[EmailVerification] fallback log for {_masked(email)}: code={code}")

