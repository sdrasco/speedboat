---
name: IBKR documentation snapshots and institutional knowledge
description: Offline snapshots of IBKR's public API documentation plus hard-won gotchas accumulated in sibling repo `nekomata`.
type: reference
---

# IBKR documentation and institutional knowledge

Two layers of reference material for the IBKR Web API path:

1. **Verbatim snapshots** of IBKR's public docs (`pages/`, `spec/`),
   so the project can be developed without depending on the live IBKR
   site or on the native desktop apps.
2. **Distilled gotchas** that aren't in IBKR's docs but were learned
   the expensive way in sibling project `nekomata` — kept here so
   NinaPinta doesn't have to re-discover them.

**The IBKR Campus pages are authoritative. These snapshots are for
convenience and may go stale.** Re-fetch before trusting any detail
for non-trivial work.

## Fetch date

All HTML and YAML files in this directory were originally fetched
**2026-04-20** by `nekomata` and copied here on **2026-04-26**.

## Context: why the Web API path, not TWS API

As of 2026-04-20, retail IBKR accounts cannot use OAuth 2.0 direct Web
API access (institutional/enterprise only). Retail must authenticate
through the **Client Portal Gateway** — a small first-party Java
daemon that runs locally, takes the browser login + IBKR Mobile 2FA
tap, and then proxies authenticated HTTPS traffic from
`localhost:5000` to IBKR servers.

That is the minimum first-party footprint available. No TWS, no IB
Gateway desktop app. The trade-off — discussed in
[../../ibkr_for_cross_border_equity_comp.md](../../ibkr_for_cross_border_equity_comp.md)
and revisited whenever execution comes up — is that the gateway needs
a human to approve an IBKR Mobile push roughly every 24 h, which
constrains any future unattended automation.

## Index

### Distilled knowledge (read these first)

| File | Purpose |
|------|---------|
| [conventions.md](conventions.md) | Non-obvious rules and gotchas for the CP Web API — endpoint quirks, options vs stocks, RTH handling, futures front-month resolution, sector taxonomy. The single most valuable file in this directory. |
| [activity-statements.md](activity-statements.md) | Why the CP Web API is inadequate for historical trade data on retail accounts and how to pull the authoritative Activity Statement CSV from the IBKR web portal instead. |
| [cert-regen.md](cert-regen.md) | Recipe to regenerate the gateway's TLS cert (default ships with CN mismatch and expired in 2019) and trust it in the macOS login keychain. |

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

- https://interactivebrokers.github.io/cpwebapi/ — JS-rendered SPA, no
  useful static snapshot. Open in a browser when needed. The gh-pages
  source is not public.

## How to refresh

Re-run the same `curl` fetches and bump the fetch date at the top of
this file. A small refresh script under `scripts/` is reasonable to
add once the repo has structure.

## Staleness signals to watch

- IBKR is rolling the Client Portal Web API, Digital Account
  Management, and Flex Web Service together into a single unified
  **IBKR Web API** throughout 2026, unified under OAuth 2.0. Expect
  endpoint paths and auth flows on pages 02, 03, 05, 06 to churn more
  than usual.
- If OAuth 2.0 ever opens up for retail accounts, the Client Portal
  Gateway becomes optional and the auth design assumed across these
  docs should be revisited.

## See also

- The user-invocable skill `ibkr-cpapi` (visible to coding agents in
  this repo, dated 2026-04-20) is a third source of empirical IBKR
  knowledge, distilled separately from a `trades` repo. Treat it as
  canonical alongside `conventions.md` and cross-check both against
  the live IBKR docs before non-trivial work.
