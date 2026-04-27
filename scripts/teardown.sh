#!/usr/bin/env bash
# Bring the IBKR Client Portal Gateway down gracefully:
#   - POST /logout so IBKR releases the SSO session.
#   - Stop the gateway process.
#
# Skipping the /logout step (e.g. with `pkill -f run.sh`) leaves
# IBKR's upstream session state convinced the session is still
# active, which forces a secure-challenge dialog on the next login
# instead of a clean mobile-push approval.

set -euo pipefail

GATEWAY_PORT=5000

if curl -ks --max-time 3 \
  -X POST "https://localhost:$GATEWAY_PORT/v1/api/logout" \
  >/dev/null 2>&1; then
  echo "==> Logged out of IBKR session."
else
  echo "==> No active gateway session to log out of (or it didn't respond)."
fi

# Stop the gateway daemon.
PIDS=$(pgrep -f "clientportal.gw.*run.sh" || true)
if [[ -z "$PIDS" ]]; then
  echo "==> Gateway not running."
  exit 0
fi

echo "==> Stopping gateway processes: $PIDS"
# Try graceful first.
kill $PIDS 2>/dev/null || true
sleep 1
# Force if anything's still alive.
STILL=$(pgrep -f "clientportal.gw.*run.sh" || true)
if [[ -n "$STILL" ]]; then
  kill -9 $STILL 2>/dev/null || true
fi

echo "==> Gateway stopped."
