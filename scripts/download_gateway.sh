#!/usr/bin/env bash
# Download IBKR's Client Portal Gateway, unzip it into third_party/,
# and (by default) regenerate its TLS certificate so Chrome and
# password managers will accept it.
#
# Usage:
#   ./scripts/download_gateway.sh           # fetch + regen cert + trust
#   ./scripts/download_gateway.sh --skip-cert  # fetch only

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
THIRD_PARTY="$REPO_ROOT/third_party"
GATEWAY_DIR="$THIRD_PARTY/clientportal.gw"
GATEWAY_URL="https://download2.interactivebrokers.com/portal/clientportal.gw.zip"
KEYSTORE="$GATEWAY_DIR/root/vertx.jks"
SSL_PWD="mywebapi"   # the password the shipped conf.yaml expects

SKIP_CERT=0
if [[ "${1:-}" == "--skip-cert" ]]; then
  SKIP_CERT=1
fi

echo "==> Fetching gateway zip from IBKR..."
mkdir -p "$THIRD_PARTY"
TMPZIP="$(mktemp -t cpgw.XXXXXX).zip"
curl -fsSL -o "$TMPZIP" "$GATEWAY_URL"

echo "==> Unpacking into $GATEWAY_DIR..."
rm -rf "$GATEWAY_DIR"
mkdir -p "$GATEWAY_DIR"
unzip -q "$TMPZIP" -d "$GATEWAY_DIR"
rm -f "$TMPZIP"

if [[ "$SKIP_CERT" -eq 1 ]]; then
  echo "==> --skip-cert set; not regenerating the TLS certificate."
  echo "    Chrome will reject the default cert (expired May 2019,"
  echo "    CN mismatch). To regenerate later, re-run without"
  echo "    --skip-cert, or follow docs/ibkr/cert-regen.md."
  exit 0
fi

echo "==> Backing up the default keystore..."
cp "$KEYSTORE" "$KEYSTORE.orig"

echo "==> Generating a fresh self-signed cert with CN=localhost..."
keytool -genkeypair \
  -alias localhost \
  -keyalg RSA -keysize 2048 \
  -validity 3650 \
  -keystore "$KEYSTORE" \
  -storetype JKS \
  -storepass "$SSL_PWD" -keypass "$SSL_PWD" \
  -dname "CN=localhost, OU=local, O=local, C=GB" \
  -ext "SAN=DNS:localhost,IP:127.0.0.1" \
  > /dev/null

echo "==> Clearing the gateway's keystore cache..."
rm -rf "$GATEWAY_DIR/.vertx"

echo ""
echo "==> Gateway downloaded and cert regenerated."
echo ""
echo "To trust the cert system-wide on macOS so Chrome and password"
echo "managers accept it, do the following once after your first"
echo "spinup (the cert is exported by spinup.sh on first run):"
echo ""
echo "  security add-trusted-cert -r trustRoot \\"
echo "    -k ~/Library/Keychains/login.keychain-db \\"
echo "    third_party/clientportal.gw/root/vertx-localhost.pem"
echo ""
echo "macOS will prompt for your user password. Scope is user-only;"
echo "no sudo, no System keychain. See docs/ibkr/cert-regen.md for"
echo "background."
