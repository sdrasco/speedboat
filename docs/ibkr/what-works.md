# What the IBKR Web API does well

Capabilities that are clean, free, and well-supported on the retail
tier via the Client Portal Web API. Building on these is cheap and
predictable.

For the failure modes and "use a different tool" cases, see
[what-doesnt.md](what-doesnt.md). For exact field-level gotchas
(units, off-by-one traps), see [conventions.md](conventions.md).

## Account state — positions, balances, P/L

Endpoints: `/portfolio2/{id}/positions` (preferred),
`/portfolio/{id}/positions/0` (legacy fallback),
`/portfolio/{id}/summary`, `/pa/allperiods`.

What you get:

- Every position with quantity, average cost, market price, market
  value, unrealized P/L, and asset class.
- Cash balances for the account in base currency.
- Today's P/L, today's return %, and rolling NAV for several time
  windows (`1D`, `1W`, `MTD`, `1M`, `3M`, `YTD`, `1Y`, `All`).

Caveats: see `conventions.md` for the daily-P/L formula (don't use
`/summary`'s field; use `/pa/allperiods`) and the options-vs-stocks
P/L formula trap.

## Multi-currency cash

Endpoint: `/portfolio/{id}/ledger`.

Returns per-currency cash balances with USD-equivalent values. This
is the right source for surfacing "you have £X in your IBKR
account" alongside USD positions in a unified table.

## Real-time market data — US equities and ETFs

Endpoint: `/iserver/marketdata/snapshot` (request-then-poll
pattern), or the WebSocket equivalent for live streaming.

Free on the retail tier via the **Cboe One + IEX consolidated
feed**. Covers every US-listed equity and ETF with real-time bid,
ask, last, volume, and the usual Level 1 fields. This is normally
the expensive subscription on a retail platform; IBKR includes it.

To check this is on, look for "Cboe One + IEX" in your account's
market-data subscriptions in the IBKR portal. If it isn't, the
calls will return delayed-snapshot data instead of real-time.

## Free FX rates

Endpoint: `/iserver/marketdata/snapshot` for forex pairs.

USDEUR, GBPUSD, USDJPY, etc. — free, real-time, no subscription
required. Useful for displaying USD-equivalents of multi-currency
positions and for the FX-conversion helper sketched in the README.

## Live charts (history endpoint)

Endpoint: `/iserver/marketdata/history`.

Returns OHLCV bars at a wide range of period/bar combinations.
Works cleanly for stocks and ETFs at most timeframes; for futures,
pass `outsideRth=true` to capture the ~23-h trading day. Options
have a known issue at `bar=1d` — see `conventions.md` for the
fallback recipe.

## Contract resolution — ticker → conid

Endpoint: `/iserver/secdef/search`.

Resolves a human-friendly ticker like `AAPL` to IBKR's internal
contract ID (`conid`). Most other endpoints take `conid` rather
than ticker, so this is one of the first calls in any new
workflow.

For options chains and futures contracts, `/iserver/secdef/info`
extends this to specific strikes/expiries. (For mass options
queries across many strikes, see `what-doesnt.md` — pacing limits
make this a poor fit for IBKR.)

## Trade tape (recent)

Endpoint: `/iserver/account/trades` and `/pa/transactions`.

Returns the last 5–7 days of fills. Fine for "show me what
happened this week" use cases. Does **not** cover historical trade
data — for that, see [activity-statements.md](activity-statements.md).

## Computed views — allocation, concentration, sector breakdowns

Not API endpoints, but everything you need to compute these is in
the position data above. The agent has the IBKR conventions and
sector-taxonomy notes (`conventions.md`) — building a treemap or a
"top 5 holdings by % of net liquidation value" view is
straightforward.

## What "free" means here

Real-time US equity/ETF data and forex are free. Broader
consolidated feeds (NASDAQ, NYSE proper) and other regional feeds
cost ~$10–15/month each, often waived above commission thresholds.

One thing that catches retail users out: in your IBKR account
settings, change your classification from "professional" (the
default!) to "non-professional". Pro rates are roughly 10x the
retail data rates and you almost certainly aren't a professional
under the regulatory definition.
