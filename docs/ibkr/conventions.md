---
name: IBKR Web API conventions and gotchas
description: Non-obvious rules and gotchas for the IBKR Client Portal Web API, distilled from prior production experience.
type: reference
---

# IBKR Web API conventions and gotchas

Non-obvious rules and gotchas that aren't derivable from IBKR's
docs. Distilled from prior production experience against this API.
Each item is something that cost real debugging time to discover.
Keep this short; prefer one sentence per item.

This repo doesn't yet have a runtime that touches IBKR. When it
does, file references like *"normalize at the boundary"* below
should be read as design guidance — not as pointers to existing
functions in this repo.

## Hard constraints (when this repo gains code that touches IBKR)

1. **Default to read-only.** A retail brokerage session held by an
   authenticated CP Gateway has full ordering authority. Any first
   pass at code in this repo should refuse to call mutating endpoints
   (`/iserver/account/{id}/orders` POST/DELETE, `/iserver/reply`,
   anything that changes account state). When write access is
   genuinely needed, isolate it in a separate, narrowly-scoped repo
   so the read tools aren't carrying ordering authority by accident.
2. **No third-party trading/brokerage libraries** unless there is a
   specific reason. Real money is involved; minimize the trust
   surface. IBKR-provided software plus stdlib + a narrow HTTP client
   (e.g. `httpx`) goes a long way.
3. **No IBKR desktop apps** (TWS, IB Gateway desktop) for the read
   path. The only first-party IBKR processes worth running are the
   **Client Portal Gateway** and IBKR Mobile (for 2FA). The desktop
   apps belong in a future execution-system repo, not here.

## API gotchas

### Endpoint shape and normalisation

- **Position field names differ between `/portfolio2/{id}/positions`
  and `/portfolio/{id}/positions/0`.** Normalize both shapes at the
  HTTP-client boundary; don't push endpoint-aware logic into callers.
- **`conid` types differ by endpoint** — `portfolio2` returns
  strings, the legacy endpoint returns ints. Cast to int at
  normalisation.
- **TLS on localhost:** the gateway serves a self-signed cert. Either
  trust it system-wide (see [cert-regen.md](cert-regen.md)) or
  configure your HTTP client with `verify=False` for `localhost:5000`
  only. Traffic is local-only; the gateway handles TLS to IBKR
  upstream.

### Options vs stocks

- **Options `avgCost` is reported per-contract** (already × multiplier),
  but `mktPrice` is per-share. The naive `mktPrice / avgCost - 1`
  formula gives ~−99 % for options. Use
  `unrealizedPnl / (avgCost × position)` for % P&L — correct for
  stocks and options alike.
- **Options return 500 "Chart data unavailable" at `bar=1d`.** Fall
  back to `period=2d bar=1h` and pick the last bar with an NY date
  earlier than today.

### Market hours and historical data

- **`/iserver/marketdata/history` defaults to RTH-only.** Pass
  `outsideRth=true` for futures (ES trades ~23 h/day) and US ETFs.
  No-op for pure indices. Keep it **off** for prior-close lookups so
  yesterday's close isn't polluted by thin after-hours ticks.

### NAV and P&L

- **`/portfolio/{id}/summary` has no daily P&L field** — use
  `/pa/allperiods` instead. For the honest $ P&L (net of same-day
  deposits/withdrawals), compute `startNAV × cps[-1]`, not
  `nav[-1] − startNAV`.

### Historical trade data is broken on retail

This is significant enough that it has its own document:
[activity-statements.md](activity-statements.md). Summary:

- **`/iserver/account/trades?days=N` ignores the `days` parameter** and
  returns only ~5–7 days regardless.
- **`/pa/transactions` honours `days` up to ~365** but only for
  conids you still hold (closed round-trip trades don't appear unless
  you explicitly pass the conid, which you can't know in advance).
- **Ground truth** for any historical-trade work is the **Activity
  Statement CSV** downloaded manually from the IBKR web portal —
  same backend data, fully serialized.

### Futures front-month resolution

**Picking the active futures front-month takes two filters, not one.**
`/trsrv/futures` returns every listed contract including expired ones.
Filtering to `expirationDate > today` is necessary but not sufficient:
gold especially (and CL in the final days) rolls 1–2 weeks before
expiry, and IBKR's history endpoint keeps returning bars for the
rolled-out contract fill-forwarded at a flat settlement price.

That produces zero close-to-close variation → `(F_now / F_ref) − 1 = 0`
→ any synthetic price computation collapses to a constant → daily P/L
prints exactly 0. Always probe each candidate's recent intraday bars
(e.g. last 1d at 5-min) and skip any that are dead-flat. This recurs
monthly at every roll.

### Sector taxonomy

**IBKR's sector taxonomy disagrees with GICS on some names** (e.g.
AMZN → "Communications" not "Consumer Discretionary") and leaves ETF
options blank. If you care about thematic groupings, override IBKR's
raw sector with your own taxonomy rather than trying to reconcile.
Co-moving mega-caps (AAPL/AMZN/GOOG/MSFT → e.g. "Big Tech") are
spread across three GICS sectors, which obscures concentration risk.

## Gateway lifecycle gotchas

- **Always `POST /logout` before killing the gateway process.** A
  raw `pkill` leaves IBKR's upstream SSO state convinced the session
  is still active, which forces a secure-challenge / code dialog on
  the next login instead of a clean mobile-push approval. Wrap any
  shutdown in a script that calls `/logout` first.
- **External IBKR sessions silently kick the gateway bridge.** Port
  5000 keeps listening but `/iserver/auth/status` returns an empty
  body and any data endpoint errors. The recovery is a graceful
  logout (releases IBKR's stuck session) followed by a re-auth.

## Multi-currency cash conventions

If the dashboard shows non-USD cash:

- **Cash rows show native-currency `Mkt Value`, USD-equivalent
  `% Port`.** A £20 k row displays `Mkt Value = 20,204` with
  `Ccy = GBP` while `% Port` is computed on the USD-equivalent. The
  two don't algebraically reconcile via just the visible columns —
  this is institutional-report convention. Don't "fix" it by
  USD-converting `Mkt Value`.
- Carry a parallel base-currency column (`mktValue_usd`) alongside
  native `mktValue`. Aggregations (`% Port`, treemap/sunburst sizing,
  risk-decomp totals, ranking sorts) all use `mktValue_usd`; only the
  visible `Mkt Value` in the positions table is native. All US-listed
  securities have `mktValue == mktValue_usd` — the divergence only
  shows on cash rows.

## Pacing and rate limits

- IBKR enforces historical-data request limits. Code that loops
  through symbols will blow through them. A rate limiter at the
  HTTP-client level is worth its weight.
- Always pass `formatDate=2` for epoch-second timestamps — string
  date formats have time-zone landmines.

## See also

- [activity-statements.md](activity-statements.md) — full treatment
  of why historical trade data has to come from the manual CSV
  download.
- [cert-regen.md](cert-regen.md) — TLS cert regeneration recipe.
- [what-works.md](what-works.md) and [what-doesnt.md](what-doesnt.md)
  — capabilities vs limits, summarized at a higher level.
