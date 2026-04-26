---
name: IBKR Activity Statements
description: Why the CP Web API is inadequate for historical trade data on retail accounts and how to pull the authoritative Activity Statement CSV from the IBKR web portal.
type: reference
---

# IBKR Activity Statements — the real source of historical trade data

IBKR's Client Portal Web API is inadequate for historical trade data
on a retail account. Both plausible endpoints have hidden limits that
only surface when you go looking for a specific old trade and it
isn't there. For anything beyond "last week or so," the authoritative
source is the **Activity Statement CSV** you download manually from
the IBKR web portal — the same backend, serialized completely.

## Why the API endpoints fall short

Empirically verified 2026-04-23 against a real retail account
(via sibling repo `nekomata`):

### `/iserver/account/trades?days=N`

Ignores the `days` parameter. Regardless of whether you pass 7, 365,
or 2000, it returns roughly the **most recent 5–7 days of activity
only**. You can observe this by running the same query with `days=7`
and `days=365` and seeing identical earliest-trade timestamps.

Useful for: recent fills, near-real-time trade tape.
Useless for: reconciling anything older than a week.

### `/pa/transactions`

Honours the `days` parameter up to **~365 days** (hard cap — values
beyond clamp to one year). Appears complete at first, but has a
subtler failure mode: it only returns data for **conids you still
hold OR have traded recently**. Positions that were opened and fully
closed — e.g. a call you bought in March and sold in April — **do
not appear** unless you explicitly pass their conid, which you can't
know in advance.

There is also a bug where passing multiple conids in one request
returns only a subset of the transactions for those conids.
Workaround is to query conid-by-conid and merge the results.

Useful for: realised P/L on currently-held positions, recent activity
on known instruments.
Useless for: a complete ledger of closed trades.

## The Activity Statement CSV — ground truth

IBKR's web portal generates a full Activity Statement from the same
backend data, but serialises **every** trade (open or closed, active
or expired) into a structured CSV. Coverage goes back as far as your
account history (years, not weeks).

### How to download

1. Log into the IBKR web portal — **Client Portal** (the human UI,
   not the gateway daemon you run locally),
   https://www.interactivebrokers.co.uk (or the regional equivalent).
2. Navigate: **Performance & Reports** → **Statements**.
3. Click **Activity Statement**.
4. Choose format = **CSV**, pick your period, and download.

When this repo gains code that consumes these files, drop them into
something like `data/activity/raw/` and **gitignore that directory** —
these files contain full trade history, strikes, and sizes; never
commit them.

Naming convention: IBKR's default is `U<accountid>_<from>_<to>.csv`.
Keep that pattern — it makes the period self-documenting and prevents
accidental overwrites when refreshing.

### Suggested layout

```
data/activity/
├── raw/                  ← original CSVs from the portal, one per period
│   ├── U<acct>_<p1>.csv
│   └── U<acct>_<p2>.csv
└── merged/
    ├── trades.csv        ← deduped Order rows from every raw Trades section
    └── transfers.csv     ← deduped Deposits & Withdrawals section
```

Both merged artifacts should be idempotent deduped unions of the raw
statements. Dedup keys are chosen so a single real-world event maps
to one output row even when it appears in overlapping raw periods:

- **trades.csv**: `(Asset Category, Currency, Symbol, Date/Time, Quantity, T. Price)`
- **transfers.csv**: `(Currency, Settle Date, Description, Amount)`

`transfers.csv` is the authoritative source for deposits/withdrawals
because the CP Web API has no transfer endpoint for retail accounts —
`/portfolio/{id}/transfers` and friends all return 404.

### Gap detection on import

The pattern `nekomata` settled on, worth carrying forward: when a new
statement is imported, run a strict gap check against the current
merged artifacts. If the new statement's start date is more than one
day after the latest date already on record (across both `trades.csv`
and `transfers.csv`), hold the import with a warning naming the
existing max date and the gap length. Provide an "import anyway"
override for genuinely expected gaps (an account with no activity for
a stretch).

The strict policy is deliberately paranoid — silent gaps are exactly
the failure mode this flow exists to catch.

If a file of the same name already exists with *different* bytes,
save the incoming one as `<stem>.<sha8>.csv` so nothing is silently
overwritten.

### CSV shape

Flat CSV, every row starts with a section name. The relevant sections
for trade reconciliation:

| Section | Contents |
|---|---|
| `Trades` | Every fill. DataDiscriminator = `Order` for individual executions, `ClosedLot`/`SubTotal`/`Total` for aggregated rows. |
| `Open Positions` | Point-in-time snapshot at the period end. |
| `Realized & Unrealized Performance Summary` | Per-instrument P/L breakdown. |
| `Mark-to-Market Performance Summary` | MTM P/L by instrument. |
| `Cash Report`, `Net Asset Value`, `Deposits & Withdrawals`, `Fees`, `Interest Accruals` | Balance-sheet + cash-flow details. |
| `Financial Instrument Information` | Conid, multiplier, underlying for every instrument traded. |

The `Trades` section's `DataDiscriminator == "Order"` rows are the
authoritative fill list. Fields include `Date/Time`, `Symbol` (full
contract descriptor for options, e.g. `USO 17JUN27 138 C`),
`Quantity`, `T. Price`, `Proceeds`, `Comm/Fee`, `Realized P/L`,
`Code`.

### Quick parse pattern

```python
import csv

trades = []
with open(path, newline='') as f:
    reader = csv.reader(f)
    header = None
    for row in reader:
        if not row or row[0] != "Trades":
            continue
        if row[1] == "Header":
            header = row[2:]
        elif row[1] == "Data" and row[2] == "Order" and header:
            trades.append(dict(zip(header, row[2:])))
```

Asset-category filtering: `t['Asset Category']` is one of `Stocks`,
`Equity and Index Options`, `Forex`. Splitting by category is usually
the first move.

## When to refresh

- Before any historical P/L analysis or position-timeline
  reconciliation.
- When the API-derived view of history and your memory disagree —
  the CSV is ground truth; both the API endpoints and your
  recollection can drift from it.
- As a regular quarterly snapshot for record-keeping (tax, audit,
  general hygiene).

## Flex Queries (the programmatic alternative)

IBKR also exposes **Flex Queries** — configurable reports you can
generate via a separate XML API. They can deliver the same data as
Activity Statements without manual download. Setup: define a query
in the web portal (**Performance & Reports** → **Flex Queries**),
get a token, then POST to
`https://ndcdyn.interactivebrokers.com/.../FlexStatementService.svc`.

Out of scope while NinaPinta is read-only and pre-runtime, but the
correct next step if historical-trade analysis becomes a recurring
workflow.
