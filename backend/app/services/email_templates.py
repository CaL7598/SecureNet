"""HTML + plain-text templates for transactional email."""
from app.config import settings

# Brand palette (matches Flutter AppTheme)
_BG = "#0A0A0F"
_SURFACE = "#12121A"
_PRIMARY = "#00F5FF"
_TEXT = "#E4E4E8"
_MUTED = "#9CA3AF"
_ACCENT = "#B388FF"


def _asset_url(filename: str) -> str:
    base = settings.PUBLIC_API_BASE_URL.rstrip("/")
    return f"{base}/static/email/{filename}"


def _greeting(full_name: str | None) -> str:
    if full_name and full_name.strip():
        return f"Hi {full_name.strip()},"
    return "Hi there,"


def build_welcome_plain(*, full_name: str | None) -> tuple[str, str]:
    greeting = _greeting(full_name)
    subject = "Welcome to SecureNet — you're all set"
    body = (
        f"{greeting}\n\n"
        "Welcome to SecureNet! Your account is ready.\n\n"
        "Here's what you can do next:\n"
        "• Scan your Wi-Fi network for connected devices\n"
        "• View your live network map\n"
        "• Get remediation tips if risks are found\n\n"
        "Email verification is optional. If you want to verify later, "
        "open the app → Settings → Verify email.\n\n"
        "If you didn't create this account, you can ignore this message.\n\n"
        "— The SecureNet Team"
    )
    return subject, body


def build_welcome_html(*, full_name: str | None) -> str:
    greeting = _greeting(full_name)
    hero = _asset_url("welcome-hero.png")
    return f"""\
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1"/>
  <title>Welcome to SecureNet</title>
</head>
<body style="margin:0;padding:0;background:{_BG};font-family:'Segoe UI',Roboto,Arial,sans-serif;color:{_TEXT};">
  <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background:{_BG};padding:32px 16px;">
    <tr>
      <td align="center">
        <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="max-width:560px;background:{_SURFACE};border-radius:20px;overflow:hidden;border:1px solid #2a2a3a;">
          <tr>
            <td style="padding:0;text-align:center;background:linear-gradient(135deg,#0f172a 0%,#1a1035 50%,#0a1628 100%);">
              <img src="{hero}" alt="SecureNet" width="120" height="120" style="display:block;margin:28px auto 12px;border-radius:24px;"/>
              <p style="margin:0 0 24px;font-size:13px;letter-spacing:0.2em;text-transform:uppercase;color:{_PRIMARY};font-weight:600;">SecureNet</p>
            </td>
          </tr>
          <tr>
            <td style="padding:32px 28px 8px;">
              <h1 style="margin:0 0 8px;font-size:26px;font-weight:700;color:#ffffff;line-height:1.25;">Welcome aboard</h1>
              <p style="margin:0 0 20px;font-size:16px;line-height:1.6;color:{_MUTED};">{greeting} your account is active.</p>
              <p style="margin:0 0 24px;font-size:15px;line-height:1.65;color:{_TEXT};">
                You're ready to scan Wi-Fi networks, map connected devices, and get clear remediation guidance when risks appear.
              </p>
            </td>
          </tr>
          <tr>
            <td style="padding:0 28px 28px;">
              <table role="presentation" width="100%" cellspacing="0" cellpadding="0">
                <tr>
                  <td style="padding:14px 16px;background:#1a1a26;border-radius:12px;border-left:3px solid {_PRIMARY};">
                    <p style="margin:0;font-size:14px;font-weight:600;color:#fff;">Scan your network</p>
                    <p style="margin:6px 0 0;font-size:13px;color:{_MUTED};line-height:1.5;">Discover devices and security issues in one tap.</p>
                  </td>
                </tr>
                <tr><td style="height:10px;"></td></tr>
                <tr>
                  <td style="padding:14px 16px;background:#1a1a26;border-radius:12px;border-left:3px solid {_ACCENT};">
                    <p style="margin:0;font-size:14px;font-weight:600;color:#fff;">Live network map</p>
                    <p style="margin:6px 0 0;font-size:13px;color:{_MUTED};line-height:1.5;">See routers and connected devices visually.</p>
                  </td>
                </tr>
                <tr><td style="height:10px;"></td></tr>
                <tr>
                  <td style="padding:14px 16px;background:#1a1a26;border-radius:12px;border-left:3px solid #34D399;">
                    <p style="margin:0;font-size:14px;font-weight:600;color:#fff;">Remediation tips</p>
                    <p style="margin:6px 0 0;font-size:13px;color:{_MUTED};line-height:1.5;">Actionable fixes when vulnerabilities are found.</p>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          <tr>
            <td style="padding:0 28px 28px;">
              <p style="margin:0;padding:16px;background:#0d0d14;border-radius:12px;font-size:13px;line-height:1.55;color:{_MUTED};text-align:center;">
                Want to verify your email later? Open <strong style="color:{_TEXT};">Settings → Verify email</strong> in the app — we'll send a separate verification code.
              </p>
            </td>
          </tr>
          <tr>
            <td style="padding:20px 28px;border-top:1px solid #2a2a3a;text-align:center;">
              <p style="margin:0;font-size:12px;color:#6b7280;line-height:1.5;">
                If you didn't create this account, you can safely ignore this email.<br/>
                © SecureNet · Wi-Fi security for your home network
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
"""


def build_verification_plain(*, code: str) -> tuple[str, str]:
    subject = "Your SecureNet verification code"
    body = (
        "You requested to verify your email for SecureNet.\n\n"
        f"Your verification code is: {code}\n\n"
        f"This code expires in {settings.EMAIL_VERIFICATION_CODE_TTL_MINUTES} minutes.\n"
        "Enter it in the app under Settings → Verify email.\n\n"
        "If you didn't request this, you can ignore this email.\n\n"
        "— The SecureNet Team"
    )
    return subject, body


def build_verification_html(*, code: str) -> str:
    hero = _asset_url("welcome-hero.png")
    return f"""\
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1"/>
  <title>Verify your email</title>
</head>
<body style="margin:0;padding:0;background:#f4f6f8;font-family:'Segoe UI',Roboto,Arial,sans-serif;color:#111827;">
  <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="padding:32px 16px;">
    <tr>
      <td align="center">
        <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="max-width:520px;background:#ffffff;border-radius:16px;overflow:hidden;border:1px solid #e5e7eb;box-shadow:0 4px 24px rgba(0,0,0,0.06);">
          <tr>
            <td style="padding:28px 24px 16px;text-align:center;background:linear-gradient(180deg,#0f172a 0%,#1e293b 100%);">
              <img src="{hero}" alt="" width="64" height="64" style="border-radius:14px;opacity:0.9;"/>
              <p style="margin:12px 0 0;font-size:12px;letter-spacing:0.15em;text-transform:uppercase;color:{_PRIMARY};font-weight:600;">Email verification</p>
            </td>
          </tr>
          <tr>
            <td style="padding:28px 32px 12px;text-align:center;">
              <h1 style="margin:0 0 10px;font-size:22px;font-weight:700;color:#0f172a;">Confirm your email</h1>
              <p style="margin:0 0 24px;font-size:15px;line-height:1.6;color:#4b5563;">
                Enter this code in SecureNet under <strong>Settings → Verify email</strong>
              </p>
              <div style="display:inline-block;padding:20px 32px;background:#f8fafc;border:2px dashed #94a3b8;border-radius:14px;">
                <span style="font-size:36px;font-weight:800;letter-spacing:8px;color:#0f172a;font-family:ui-monospace,Consolas,monospace;">{code}</span>
              </div>
              <p style="margin:20px 0 0;font-size:13px;color:#6b7280;">
                Expires in {settings.EMAIL_VERIFICATION_CODE_TTL_MINUTES} minutes
              </p>
            </td>
          </tr>
          <tr>
            <td style="padding:16px 32px 28px;text-align:center;">
              <p style="margin:0;font-size:12px;color:#9ca3af;line-height:1.5;">
                Didn't request this? Ignore this message — your account stays secure.
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
"""
