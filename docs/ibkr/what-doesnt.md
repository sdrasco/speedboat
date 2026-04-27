# What the IBKR Web API doesn't do well

Limits, gotchas, and the cases where you'd reach for a different
tool. The idea is to fail fast on these — recognise the shape early,
don't try to force IBKR to do something it isn't designed for.

For the things it *does* do well, see [what-works.md](what-works.md).
For exact field-level gotchas inside calls that mostly work, see
[conventions.md](conventions.md).

## Historical trade data older than ~5–7 days

The most surprising limit. Two endpoints look like they'd return
historical fills, and both have hidden caps:

- `/iserver/account/trades?days=N` ignores the `days` parameter
  and returns ~5–7 days regardless.
- `/pa/transactions` honours `days` up to ~365 but only for
  positions you currently hold. Closed round-trip trades — bought
  in March, sold in April — don't appear unless you pass the
  exact `conid`, which you can't know in advance.

**Workaround:** download the **Activity Statement CSV** manually
from the IBKR web portal. Same backend data, fully serialized.
Walkthrough in [activity-statements.md](activity-statements.md).
This is genuinely a manual step — there's no "just hit the API"
substitute for retail accounts on the Client Portal Web API.

## Universe scans, fundamentals across thousands of names

Doable, but pacing-limited. IBKR enforces historical-data request
limits that are easy to hit when looping across symbols. There's a
soft scanner endpoint for built-in scans (top movers, etc.), but
you can't bring your own multi-factor query against the universe.

**When you'd reach for Databento (or similar) instead:** any
project where the question is *"give me data on N companies"*
rather than *"give me data on the N companies in my account."*
Databento offers multi-asset coverage (US equities, CME futures,
OPRA options) under a single subscription rather than the
per-asset-class pricing common at retail vendors. Live access is
a flat fee; historical access is pay-as-you-go, which makes
one-shot universe queries cheap. Other dev-friendly options
exist (Polygon, Alpha Vantage) but Databento is the strongest
fit when you want both live and historical under one roof.

## Full options chains across many strikes

Same pacing-limit story, sharper because options chains have
hundreds of strikes per expiry. Doable for a single underlying at
a time; not viable as "give me the full chain for every position
in the portfolio" without rate-limiting carefully.

If chain analytics matter, again Databento or a dedicated
options-data provider is the right tool.

## Order placement

Out of scope for this repo by design. The hard constraint in
[conventions.md](conventions.md) keeps speedboat read-only: no
`POST /iserver/account/{id}/orders`, no `/iserver/reply`, no
`DELETE` on order endpoints. If a project ever needs to place
orders, it belongs in a separate, narrowly-scoped repo so the
read-only tools aren't carrying ordering authority by accident.

That separate execution repo is also where you'd choose the right
authentication path for unattended use (see next).

## Unattended overnight automation

The Client Portal Gateway requires a human to approve an IBKR
Mobile push roughly every 24 h. No VM, nginx, passkey, or
configuration trick changes that. Retail accounts cannot use
OAuth 2.0 direct Web API access (as of 2026-04).

Real paths for retail automated execution, in rough order of
practicality:

1. **IB Gateway desktop + IBC controller.** A different IBKR
   product (not the Client Portal Gateway). 2FA is configured as
   a read-only "second factor device" rather than push, which IBC
   can drive without a human. This is what most retail-but-
   automated IBKR users actually run. Lives in a future separate
   repo.
2. **A different broker.** Alpaca, Tradier, Tastytrade all offer
   key-based auth without the daily 2FA friction, at the cost of
   IBKR's product breadth and good fills.
3. **Stay on Client Portal Gateway and accept daily human re-auth.**
   Viable only if the strategy trades during waking hours and
   never needs to survive a weekend unattended.

## IBKR's sector taxonomy

IBKR's sector classification disagrees with GICS on some names
(AMZN labelled "Communications" rather than "Consumer Discretionary"
is a common surprise) and leaves ETF options blank. If you care
about thematic groupings — for example, treating AAPL/AMZN/GOOG/MSFT
as one "Big Tech" cluster rather than spreading them across three
GICS sectors — override IBKR's raw sector with a local taxonomy.

This isn't a bug. IBKR's classification is internally consistent;
it just isn't the same as the textbook reference. Decide which one
you're using and don't mix them.

## Field-level traps

A few things look like they should work and don't. The full list
is in [conventions.md](conventions.md) but the highlights:

- **Options P&L percentage.** The naive `mktPrice/avgCost - 1`
  formula gives ≈−99% for options because `avgCost` is
  per-contract while `mktPrice` is per-share. Use
  `unrealizedPnl / (avgCost × position)` instead.
- **Daily P/L.** `/portfolio/{id}/summary` doesn't have a daily-P/L
  field. Use `/pa/allperiods`.
- **Futures front-month.** Filtering `/trsrv/futures` to
  `expirationDate > today` isn't sufficient — gold and crude roll
  1–2 weeks before expiry, and the history endpoint will happily
  return flat-line bars for the rolled-out contract. Probe the
  recent intraday bars and skip any that are dead-flat.

## Bottom line

IBKR is built for traders managing their own account, not for
third-party data exploration. Use it for "what's in my account,
what's it worth, how is it moving?" Reach for a dedicated data
provider for "what's happening across the universe?"
