"""
Email delivery service hooks.

This module currently provides a placeholder sender that logs reset codes.
Swap this implementation with SMTP/provider integration in production.
"""
from app.config import settings


def send_password_reset_code(email: str, code: str) -> None:
    """
    Send password reset code to end user.

    Current behavior:
    - Debug mode: prints reset code to server logs for local testing.
    - Production: still prints a masked delivery placeholder until a provider is configured.
    """
    if settings.DEBUG:
        print(f"[PasswordReset] code for {email}: {code}")
        return

    # TODO: integrate SMTP/provider (SendGrid, SES, Mailgun, etc.)
    masked = email[:2] + "***" + email[email.find("@"):] if "@" in email else "***"
    print(f"[PasswordReset] email delivery placeholder for {masked}")

