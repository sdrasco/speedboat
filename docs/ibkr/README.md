---
name: IBKR documentation snapshots and institutional knowledge
description: Offline snapshots of IBKR's public API documentation plus hard-won gotchas distilled from prior production work.
type: reference
---

# IBKR documentation and institutional knowledge

Two layers of reference material for the IBKR Web API path:

1. **Verbatim snapshots** of IBKR's public docs (`pages/`, `spec/`),
   so the project can be developed without depending on the live
   IBKR site or on the native desktop apps.
2. **Distilled gotchas** that aren't in IBKR's docs but were learned
   the expensive way in prior production work — kept here so this
   repo doesn't have to re-discover them.

**The IBKR Campus pages are authoritative. These snapshots are for
convenience and may go stale.** Re-fetch before trusting any detail
for non-trivial work.

## Fetch date

All HTML and YAML files in this directory were fetched **2026-04-20**.

## Context: why the Web API path, not TWS API

As of 2026-04-20, retail IBKR accounts cannot use OAuth 2.0 direct
Web API access (institutional/enterprise only). Retail must
authenticate through the **Client Portal Gateway** — a small
first-party Java daemon that runs locally, takes the browser login
+ IBKR Mobile 2FA tap, and then proxies authenticated HTTPS traffic
from `localhost:5000` to IBKR servers.

That is the minimum first-party footprint available. No TWS, no IB
Gateway desktop app. The trade-off — discussed in
[../../ibkr_for_cross_border_equity_comp.md](../../ibkr_for_cross_border_equity_comp.md)
and revisited whenever execution comes up — is that the gateway
needs a human to approve an IBKR Mobile push roughly every 24 h,
which constrains any future unattended automation.

## Index

### Distilled knowledge (read these first)

| File | Purpose |
|------|---------|
| [spinup.md](spinup.md) | Walkthrough of the operational scripts — how to bring the gateway up, what each step looks like, with screenshots. |
| [what-works.md](what-works.md) | Capabilities the IBKR Web API offers cleanly on the free retail tier. |
| [what-doesnt.md](what-doesnt.md) | Limits, gotchas, and where you'd want different data (e.g. Massive). |
| [conventions.md](conventions.md) | Non-obvious rules and gotchas — endpoint quirks, options vs stocks P&L, RTH handling, futures front-month resolution, sector taxonomy. The deepest reference in this directory. |
| [activity-statements.md](activity-statements.md) | Why the CP Web API is inadequate for historical trade data on retail accounts and how to pull the authoritative Activity Statement CSV from the IBKR web portal instead. |
| [cert-regen.md](cert-regen.md) | Manual recipe to regenerate the gateway's TLS cert (default ships with CN mismatch and expired in 2019) and trust it on macOS. The same procedure is automated in `scripts/download_gateway.sh`. |

### `pages/` — IBKR Campus HTML snapshots

Raw HTML (heavy with CSS/JS chrome; open in a browser, or grep for
text). The file number is just the fetch order, not a reading order.

| File | Source URL |
|------|------------|
| `01-getting-started.html`   | https://www.interactivebrokers.com/campus/ibkr-api-page/getting-started/ |
| `02-webapi-doc.html`        | https://www.interactivebrokers.com/campus/ibkr-api-page/webapi-doc/ |
| `03-cpapi-v1.html`          | https://www.interactivebrokers.com/campus/ibkr-api-page/cpapi-v1/ |
| `04-launching-gateway.html` | https://www.interactivebrokers.com/campus/trading-lessons/launching-and-authenticating-the-gateway/ |
| `05-trading-webapi.html`    | https://www.interactivebrokers.com/campus/ibkr-api-page/web-api-trading/ |
| `06-account-management.html`| https://www.interactivebrokers.com/campus/ibkr-api-page/web-api-account-management/ |

### `spec/` — machine-readable specs

| File | Source URL | Notes |
|------|------------|-------|
| `swagger.yaml` | https://www.interactivebrokers.com/webtradingapi/swagger.yaml | **Stale.** `Last-Modified` header on the source is 2019-05-13. Useful for endpoint shape sketching, but cross-check against the current Campus pages before writing code against it. |

### Not archived

- https://interactivebrokers.github.io/cpwebapi/ — JS-rendered SPA,
  no useful static snapshot. Open in a browser when needed.

## How to refresh

Re-run the same `curl` fetches and bump the fetch date at the top
of this file. A small refresh script under `scripts/` is reasonable
to add as soon as a refresh is needed.

## Staleness signals to watch

- IBKR is rolling the Client Portal Web API, Digital Account
  Management, and Flex Web Service together into a single unified
  **IBKR Web API** throughout 2026, unified under OAuth 2.0. Expect
  endpoint paths and auth flows on pages 02, 03, 05, 06 to churn
  more than usual.
- If OAuth 2.0 ever opens up for retail accounts, the Client Portal
  Gateway becomes optional and the auth design assumed across these
  docs should be revisited.
