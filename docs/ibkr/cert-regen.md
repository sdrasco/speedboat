---
name: Regenerate the CP Gateway TLS cert
description: Recipe to replace the IBKR Client Portal Gateway's broken default self-signed cert with one Chrome and password managers will accept on macOS.
type: reference
---

# Regenerating the CP Gateway's TLS cert

IBKR's Client Portal Gateway ships with a self-signed cert whose CN
is `Client Portal Web API` (no SAN) and which expired May 2019.
Chrome rejects it on hostname mismatch regardless of whether you
trust it, and password managers refuse to autofill on the origin
while it's flagged.

The fix is to replace the keystore with a self-signed cert where
CN=`localhost` and SAN=DNS:localhost,IP:127.0.0.1, then trust it in
the macOS login keychain. Result: clean Chrome padlock, password-
manager autofill works.

This recipe assumes you have unpacked the gateway under
`third_party/clientportal.gw/` at the repo root. Adjust paths if you
keep it elsewhere.

## When you need to redo this

- After re-downloading or reinstalling the gateway — the default
  install restores the broken cert.
- On a new Mac (login keychain doesn't migrate cleanly by default).
- When the regenerated cert approaches its 10-year expiry.

## Prerequisites

- Java toolchain with `keytool` on PATH (Homebrew Temurin etc.).
- `openssl` and `security` — both stock on macOS.
- Gateway **stopped** for steps 1–3, **started** for step 4.

## Steps

### 1. Back up the default keystore

```
cp third_party/clientportal.gw/root/vertx.jks third_party/clientportal.gw/root/vertx.jks.orig
```

Password and alias come from
`third_party/clientportal.gw/root/conf.yaml`: `sslPwd: "mywebapi"`
and the keystore's alias is `localhost`. If either has been changed
there, adjust the commands below to match.

### 2. Generate the replacement keypair

```
keytool -genkeypair \
    -alias localhost \
    -keyalg RSA -keysize 2048 \
    -validity 3650 \
    -keystore third_party/clientportal.gw/root/vertx.jks \
    -storetype JKS \
    -storepass mywebapi -keypass mywebapi \
    -dname "CN=localhost, OU=local, O=local, L=Edinburgh, C=GB" \
    -ext "SAN=DNS:localhost,IP:127.0.0.1"
```

The alias **must** be `localhost` — that's what the gateway looks
for in the keystore. The `-storepass`/`-keypass` must match
`sslPwd` in `conf.yaml`.

Because `-keystore` points at the live file, the new entry replaces
the old. If you'd rather build it somewhere safe first and swap, use
`/tmp/vertx-new.jks` then `mv` it over once verified.

### 3. Clear the gateway's keystore cache

```
rm -rf third_party/clientportal.gw/.vertx
```

The gateway caches extracted files from its distribution; without
this, a restart may still serve the old cert.

### 4. Start the gateway, then export the served cert

```
cd third_party/clientportal.gw && bin/run.sh root/conf.yaml
```

(Run that in a separate terminal, or via a spinup script if you have
one.)

Then, from the repo root:

```
openssl s_client -connect localhost:5000 -servername localhost </dev/null 2>/dev/null \
  | openssl x509 -outform PEM \
  -out third_party/clientportal.gw/root/vertx-localhost.pem
```

Sanity check — should show CN=localhost and a SAN including
`DNS:localhost`:

```
openssl x509 -in third_party/clientportal.gw/root/vertx-localhost.pem \
  -noout -subject -dates -ext subjectAltName
```

### 5. Trust the cert in the macOS login keychain

```
security add-trusted-cert -r trustRoot \
  -k ~/Library/Keychains/login.keychain-db \
  third_party/clientportal.gw/root/vertx-localhost.pem
```

macOS will prompt for your user password (or Touch ID) to authorise
the trust-store modification. Scope is user-only — no `sudo`, no
System keychain.

### 6. Verify

With the gateway running:

```
curl -sS --max-time 3 https://localhost:5000/v1/api/iserver/auth/status
```

No `-k` needed; should return JSON (a 401-ish unauthenticated
response is fine — what matters is that TLS verified). In Chrome,
reload `https://localhost:5000` and confirm a clean padlock with no
interstitial.

## Cleanup of prior trust entries (optional)

Each regeneration adds a new cert to the keychain; old ones with the
same CN=`localhost` stay until removed. List and delete by SHA-1:

```
security find-certificate -a -c localhost -Z ~/Library/Keychains/login.keychain-db \
  | grep -E '^(SHA-1|    "labl")'
security delete-certificate -Z <sha1-hash> ~/Library/Keychains/login.keychain-db
```

Not strictly necessary — keeping old trusted certs around is
harmless — but tidy if you regenerate often.

## Files touched

| Path | Role |
|------|------|
| `third_party/clientportal.gw/root/vertx.jks` | live keystore (regenerated) |
| `third_party/clientportal.gw/root/vertx.jks.orig` | backup of the original broken keystore |
| `third_party/clientportal.gw/root/vertx-localhost.pem` | exported cert, kept alongside for re-trusting on other machines |
| `~/Library/Keychains/login.keychain-db` | macOS login keychain, holds the trust entry |
