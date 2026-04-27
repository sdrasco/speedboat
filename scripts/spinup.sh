#!/usr/bin/env bash
# Bring the IBKR Client Portal Gateway up:
#   - Start the Java daemon if it isn't already running.
#   - Open https://localhost:5000 in Chrome for the IBKR login.
#   - Wait for the user to complete the IBKR Mobile push approval.
#   - Print a confirmation with the connected account.
#
# Idempotent — safe to re-run mid-session.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GATEWAY_DIR="$REPO_ROOT/third_party/clientportal.gw"
GATEWAY_PORT=5000
LOG_DIR="$GATEWAY_DIR/logs"
LOG_FILE="$LOG_DIR/spinup.log"
CERT_PEM="$GATEWAY_DIR/root/vertx-localhost.pem"

if [[ ! -d "$GATEWAY_DIR" ]]; then
  echo "Gateway not installed. Run ./scripts/download_gateway.sh first."
  exit 1
fi

is_listening() {
  lsof -nP -iTCP:"$GATEWAY_PORT" -sTCP:LISTEN >/dev/null 2>&1
}

is_authenticated() {
  local body
  body=$(curl -ks --max-time 3 \
    "https://localhost:$GATEWAY_PORT/v1/api/iserver/auth/status" || echo "")
  [[ "$body" == *'"authenticated":true'* ]]
}

if is_listening; then
  echo "==> Gateway already running on port $GATEWAY_PORT."
else
  echo "==> Starting gateway..."
  mkdir -p "$LOG_DIR"
  ( cd "$GATEWAY_DIR" && nohup bin/run.sh root/conf.yaml \
    >>"$LOG_FILE" 2>&1 & )
  # Wait for it to start listening (up to ~15s).
  for _ in $(seq 1 30); do
    if is_listening; then break; fi
    sleep 0.5
  done
  if ! is_listening; then
    echo "Gateway didn't start listening on port $GATEWAY_PORT."
    echo "Check $LOG_FILE for details."
    exit 1
  fi
fi

# On first spinup after cert regen, export the served cert so the
# user can trust it in their keychain (see docs/ibkr/cert-regen.md).
if [[ ! -f "$CERT_PEM" ]]; then
  echo "==> Exporting served cert to $CERT_PEM ..."
  ( openssl s_client -connect "localhost:$GATEWAY_PORT" \
      -servername localhost </dev/null 2>/dev/null \
    | openssl x509 -outform PEM -out "$CERT_PEM" ) || true
fi

if is_authenticated; then
  echo "==> Already authenticated."
else
  echo "==> Opening login page in Chrome..."
  open -a "Google Chrome" "https://localhost:$GATEWAY_PORT" 2>/dev/null \
    || open "https://localhost:$GATEWAY_PORT"

  echo ""
  echo "    Log in, then approve the push in IBKR Mobile."
  echo "    Waiting for authentication..."
  for _ in $(seq 1 240); do   # ~120s with sleeps below
    if is_authenticated; then break; fi
    sleep 0.5
  done
  if ! is_authenticated; then
    echo ""
    echo "Timed out waiting for authentication. The gateway is"
    echo "still running on port $GATEWAY_PORT. Either complete"
    echo "the login in your browser and re-run this script, or"
    echo "run ./scripts/teardown.sh to stop the gateway cleanly."
    exit 1
  fi
fi

echo ""
echo "==> Authenticated."

ACCT_JSON=$(curl -ks --max-time 5 \
  "https://localhost:$GATEWAY_PORT/v1/api/portfolio/accounts" \
  || echo "[]")
ACCT_ID=$(printf '%s' "$ACCT_JSON" \
  | grep -oE '"accountId":"[^"]+"' | head -1 | cut -d'"' -f4)

if [[ -n "${ACCT_ID:-}" ]]; then
  echo "    Connected account: $ACCT_ID"
fi
echo "    API base: https://localhost:$GATEWAY_PORT/v1/api"
echo ""
echo "Run ./scripts/teardown.sh when you're done."
