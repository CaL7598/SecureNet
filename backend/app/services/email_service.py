"""
Email delivery service hooks.

Sends verification and reset codes over SMTP when configured.
"""
import smtplib
from email.message import EmailMessage

from app.config import settings


def _masked(email: str) -> str:
    return email[:2] + "***" + email[email.find("@") :] if "@" in email else "***"


def _deliver_email(
    *,
    to_email: str,
    subject: str,
    body: str,
    html_body: str | None = None,
) -> bool:
    if not settings.EMAIL_DELIVERY_ENABLED:
        return False
    if not settings.SMTP_HOST or not settings.SMTP_USERNAME or not settings.SMTP_PASSWORD:
        return False

    msg = EmailMessage()
    msg["Subject"] = subject
    msg["From"] = settings.EMAIL_FROM
    msg["To"] = to_email
    msg.set_content(body)
    if html_body:
        msg.add_alternative(html_body, subtype="html")

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


def send_registration_welcome_email(
    email: str,
    code: str,
    *,
    full_name: str | None = None,
) -> None:
    """Welcome new users; verification is optional and done in app settings."""
    display_name = full_name.strip() if full_name and full_name.strip() else None
    greeting = f"Hi {display_name}," if display_name else "Hi,"
    body = (
        f"{greeting}\n\n"
        "Welcome to SecureNet. Your account is now active, and you can start scanning networks immediately.\n\n"
        "Verification is optional right now.\n"
        "If you choose to verify later, open Settings in the app and use this code:\n"
        f"{code}\n"
        f"This code expires in {settings.EMAIL_VERIFICATION_CODE_TTL_MINUTES} minutes.\n\n"
        "If you did not create this account, you can ignore this email.\n\n"
        "Best regards,\n"
        "SecureNet Team"
    )
    html_body = f"""\
<!doctype html>
<html>
  <body style="margin:0;padding:0;background:#f4f6f8;font-family:Arial,sans-serif;color:#111827;">
    <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="padding:24px 12px;">
      <tr>
        <td align="center">
          <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="max-width:560px;background:#ffffff;border:1px solid #e5e7eb;border-radius:12px;overflow:hidden;">
            <tr>
              <td style="padding:24px;border-bottom:1px solid #e5e7eb;background:#0f172a;color:#ffffff;">
                <h1 style="margin:0;font-size:20px;line-height:1.3;">Welcome to SecureNet</h1>
              </td>
            </tr>
            <tr>
              <td style="padding:24px;">
                <p style="margin:0 0 14px 0;font-size:15px;line-height:1.6;">{greeting}</p>
                <p style="margin:0 0 14px 0;font-size:15px;line-height:1.6;">
                  Your account is now active, and you can start scanning networks immediately.
                </p>
                <p style="margin:0 0 14px 0;font-size:15px;line-height:1.6;">
                  Verification is optional right now. If you choose to verify later, open <strong>Settings</strong> in the app and enter this code:
                </p>
                <div style="margin:0 0 14px 0;padding:12px;border:1px dashed #94a3b8;border-radius:10px;background:#f8fafc;text-align:center;">
                  <span style="font-size:28px;letter-spacing:4px;font-weight:700;color:#0f172a;">{code}</span>
                </div>
                <p style="margin:0 0 14px 0;font-size:14px;line-height:1.6;color:#4b5563;">
                  This code expires in {settings.EMAIL_VERIFICATION_CODE_TTL_MINUTES} minutes.
                </p>
                <p style="margin:0;font-size:13px;line-height:1.6;color:#6b7280;">
                  If you did not create this account, you can ignore this email.
                </p>
              </td>
            </tr>
            <tr>
              <td style="padding:16px 24px;border-top:1px solid #e5e7eb;background:#f9fafb;">
                <p style="margin:0;font-size:12px;line-height:1.5;color:#6b7280;">SecureNet Team</p>
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
  </body>
</html>
"""
    if settings.DEBUG:
        print(f"[WelcomeEmail] code for {email}: {code}")
    sent = _deliver_email(
        to_email=email,
        subject="Welcome to SecureNet",
        body=body,
        html_body=html_body,
    )
    if not sent:
        print(f"[WelcomeEmail] fallback log for {_masked(email)}: code={code}")


def send_email_verification_code(email: str, code: str) -> None:
    body = (
        "You requested an email verification code for SecureNet.\n\n"
        f"Your code is: {code}\n\n"
        f"This code expires in {settings.EMAIL_VERIFICATION_CODE_TTL_MINUTES} minutes."
    )
    if settings.DEBUG:
        print(f"[EmailVerification] code for {email}: {code}")
    sent = _deliver_email(
        to_email=email,
        subject="SecureNet email verification code",
        body=body,
    )
    if not sent:
        print(f"[EmailVerification] fallback log for {_masked(email)}: code={code}")

