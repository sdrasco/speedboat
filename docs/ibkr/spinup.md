# Bringing the IBKR gateway up

speedboat talks to IBKR through the **Client Portal Gateway** — a
small first-party Java daemon that runs on your machine, takes the
browser login plus the IBKR Mobile push approval, and then proxies
authenticated HTTPS traffic from `localhost:5000` to IBKR's servers.
This is the only first-party IBKR process you need to run. No TWS,
no IB Gateway desktop app.

Three scripts under `scripts/` cover the lifecycle:

| Script | What it does |
|---|---|
| `download_gateway.sh` | Fetches the gateway from IBKR, regenerates its TLS cert (the default ships with a hostname mismatch and expired in 2019). One-time setup. |
| `spinup.sh` | Starts the gateway, opens the login page in Chrome, waits for authentication, prints a confirmation. Idempotent. |
| `teardown.sh` | Logs out cleanly and stops the gateway. Run when you're done so the next login is a clean push approval. |

## First-time setup

```bash
./scripts/download_gateway.sh
```

This puts the gateway under `third_party/clientportal.gw/`
(gitignored), regenerates its TLS cert as `CN=localhost`, and
prints a one-line `security add-trusted-cert` command for you to
run after your first spinup. The trust step makes Chrome show a
clean padlock instead of a "not secure" warning, which also lets
your password manager autofill on the IBKR login page.

To skip the cert regen (not recommended), pass `--skip-cert`. If
something goes wrong with the cert, the manual recipe is in
[cert-regen.md](cert-regen.md).

## Daily use

```bash
./scripts/spinup.sh
```

What happens, step by step:

### 1. Login page opens in Chrome

The gateway starts on `https://localhost:5000`. The script waits
for it to listen, then opens the login page in Chrome.

![IBKR Client Portal login page](../../assets/screenshots/gateway-login.png)

Type your IBKR username and password and submit.

### 2. Approve the push on your phone

IBKR Mobile shows a push notification. Tap **Approve**.

![IBKR Mobile push prompt](../../assets/screenshots/gateway-2fa-prompt.png)

### 3. The gateway is authenticated

`spinup.sh` polls `/iserver/auth/status` until it returns
`authenticated: true`, then prints a confirmation with the
connected account ID.

![Authenticated status check](../../assets/screenshots/gateway-authenticated.png)

The API is now reachable at `https://localhost:5000/v1/api/...`.

## Shutting down

```bash
./scripts/teardown.sh
```

This sends `POST /v1/api/logout` first (so IBKR releases the
upstream SSO session), then stops the gateway daemon. Skipping the
`/logout` step works but causes IBKR's session state to think the
session is still alive — your next login will be a secure-challenge
dialog instead of a clean push approval. Just use the script.

## When something goes wrong

- **"Address already in use" / port 5000 busy.** Another gateway
  process is still running. `./scripts/teardown.sh` will clean it
  up, then re-run `spinup.sh`.
- **Chrome shows "Your connection is not private" with no padlock.**
  The TLS cert isn't trusted yet. Run the
  `security add-trusted-cert` command that `download_gateway.sh`
  printed.
- **Auth times out, browser sits there.** You probably didn't
  approve the push within the window, or IBKR Mobile didn't ring.
  The gateway is still up — log in again and re-run `spinup.sh` to
  re-poll, or run `teardown.sh` and start fresh.
- **`/iserver/auth/status` returns an empty body** even though port
  5000 is listening. An IBKR session somewhere else (the web
  portal in another tab, mobile app) silently kicked the gateway.
  Run `teardown.sh` then `spinup.sh` to recover.

## Why this works the way it does

- The gateway uses a self-signed cert on localhost, which is why
  the cert-regen dance is needed for Chrome to be happy.
- Retail accounts cannot use OAuth 2.0 direct Web API access (as
  of 2026-04). The Client Portal Gateway is the minimum first-party
  footprint available to retail.
- The 24-hour push-approval window is structural — there's no way
  around it without moving to a different IBKR product (IB Gateway
  desktop + IBC controller) or a different broker. This means
  speedboat is good for interactive sessions but not unattended
  overnight automation. The trade-off is discussed in
  [../../ibkr_for_cross_border_equity_comp.md](../../ibkr_for_cross_border_equity_comp.md).
