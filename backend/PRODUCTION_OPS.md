# SecureNet Production Ops Baseline

## Included in this build

- Request logging middleware with method/path/status/latency.
- In-memory rate limiting (`RATE_LIMIT_REQUESTS_PER_MINUTE` per client IP).
- Incident capture for unhandled server exceptions with `incident_id`.
- Incident feed endpoint: `GET /api/v1/ops/incidents`.

## Backup and recovery

- PostgreSQL backup: use managed provider PITR + daily logical dump.
- Keep dumps encrypted and retained for at least 30 days.
- Recovery drill: restore latest dump to staging weekly and run smoke tests.

## Recommended next hardening

- Replace in-memory rate limiting with Redis-backed distributed limiter.
- Send incidents/errors to Sentry, Datadog, or Grafana Cloud.
- Add structured JSON logging and a centralized retention policy.
- Add audit logs for auth actions (login success/failure, reset, profile change).
