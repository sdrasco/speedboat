# Interactive Brokers (IBKR) for Cross-Border Equity Compensation: A Conversation Summary

## The original situation

A friend, Spanish citizen and German tax resident, works for a US tech company. Part of her compensation arrives as shares delivered to a US-based Morgan Stanley account. She is reluctant to move or trade the shares because of the friction involved: creating a Wise account, paying foreign exchange (FX) conversion costs, and moving either the shares or their US dollar (USD) value into her European Union (EU) bank accounts.

## Would an Interactive Brokers (IBKR) cash account make her life easier?

Short answer: yes, considerably.

### Why IBKR fits

She would open with IBKR Ireland, the EU entity that serves German residents post-Brexit. Three features matter:

1. **Multi-currency cash balances in one account.** She can hold USD and euros (EUR) side by side, converting only when she chooses rather than at the moment of withdrawal.
2. **Genuinely cheap FX.** IBKR's FX commission is roughly 0.002% with a USD 2.00 minimum per manual conversion, or about 0.03% on auto-conversion. Compare with Wise (~0.4% to 0.6%) and retail banks (1% to 3%). On a USD 10,000 conversion: about USD 2 to 3 at IBKR vs USD 40 to 60 at Wise.
3. **Cheap EUR withdrawals to a German bank** via Single Euro Payments Area (SEPA), with the first withdrawal each month typically free.

### How the share move actually works

She does not have to sell to move the shares, so no tax event is triggered just to change brokers:

1. Open the IBKR Ireland account.
2. Initiate an "incoming position transfer" inside IBKR, selecting the United States as the delivering broker's region. For US brokers this uses the Automated Customer Account Transfer Service (ACATS).
3. Morgan Stanley's Global Stock Plan Services typically requires a "Letter of Authorization for Stock Transfer" form, returned by mail or fax with the Depository Trust Company (DTC) number for the receiving broker.

### Caveats

- **StockPlan account restrictions.** Many employer plans require shares to be moved from the restricted StockPlan account into a regular Morgan Stanley individual brokerage account before they can leave Morgan Stanley.
- **Plan-specific holding rules.** Some plans require shares to remain at the designated broker for a period or only allow transfers in certain windows.
- **W-8BEN form at IBKR.** As a non-US person she fills this once to get the US-Germany tax treaty rate (15% dividend withholding rather than the default 30%).
- **Tax reporting does not change.** Germany taxes worldwide income for residents. She must report the foreign account, dividends (subject to Abgeltungsteuer plus solidarity surcharge), and capital gains on sale regardless of broker. IBKR's German-format reports are more usable for this than Morgan Stanley's.
- **Spanish citizenship is largely irrelevant** if she is genuinely tax-resident in Germany.

A German Steuerberater familiar with US tech equity comp is worth a one-time consultation; the cost typically pays for itself in FX savings within a year.

## Does IBKR open up solo software projects via its application programming interface (API)?

Yes, emphatically. The two brokers are not in the same league for solo software work.

### Morgan Stanley side: essentially closed

Morgan Stanley StockPlan Connect / Shareworks has no public API for individual employee users. Realistic programmatic access for an employee is "screen-scrape the web UI", which is fragile and against terms of service.

### IBKR side: unusually open for retail

IBKR exposes:

- **Trader Workstation (TWS) API.** Connects to a locally-running TWS or IB Gateway over a socket. Mature path with deep Python support (the official `ibapi`, plus `ib-async`, plus framework support in Backtrader, NautilusTrader, vectorbt, Zipline-Reloaded, QuantConnect).
- **Web API (Client Portal API).** Representational State Transfer (REST) plus WebSocket. For individual accounts, developers authenticate via the Client Portal Gateway, a small Java program.

Both are free with the account. Real-time streaming for all US-listed stocks and exchange-traded funds (ETFs) is free via the Cboe One and Investors Exchange (IEX) feed. Forex data is free. Broader consolidated feeds run roughly USD 10 to USD 15 a month and are often waived above commission thresholds. Individual traders should change their classification from "professional" (the default) to "non-professional" in Client Portal settings, since professional rates are often around 10x higher.

### Project examples relevant to her shape

- A vest-handler that, on each grant, programmatically sells a configurable fraction at a limit price and logs everything for the German tax return.
- A USD-to-EUR conversion bot that watches the rate and triggers cheap manual FX trades when it hits her target.
- A concentration-risk monitor that tracks employer-stock exposure as a percentage of net worth.
- An auto-rebalancer that sweeps EUR cash into Undertakings for Collective Investment in Transferable Securities (UCITS) ETFs (EU-domiciled equivalents of US ETFs, since US-domiciled ETFs are restricted for EU retail investors under the Packaged Retail and Insurance-based Investment Products / PRIIPs regulation).
- A tax-lot inspector computing German first-in-first-out (FIFO) gains.
- Dividend forecasting and cash-flow modelling.
- Backtesting strategies on a paper-trading account that mirrors the live one.

### Honest friction points

- **TWS or IB Gateway must be running.** Headless without a graphical user interface (GUI) is not supported. People run IB Gateway on a small virtual private server (VPS) with a virtual display, or on a home machine.
- **Two-factor authentication (2FA) is mandatory** and refreshes periodically, adding friction for unattended automation.
- **One brokerage session per username.** The standard fix is to create a second linked username for API use.
- **Real money risk.** Always start on paper. Use limit orders, not market orders, while building trust in the code.

## Agentic tooling makes this dramatically more accessible

Giving agents like Claude Code or Codex awareness of and skills for the IBKR API is a powerful way to scope ideas, evaluate trades, and look at data with low data subscription fees.

### Why IBKR works well as an agent target

- The contract object model (representing any tradeable instrument as a `Contract` with conId, exchange, secType, currency) is a coherent primitive that composes well.
- The TWS API has been stable long enough to have a deep corpus of working examples in training data.
- Free Cboe One + IEX plus free forex covers a lot of exploratory work at zero data cost.

### Patterns that work well

- **Pin a known-good wrapper** like `ib-async` (the maintained successor to `ib_insync`) in a SKILL.md. It hides the request-id bookkeeping that makes raw `ibapi` painful.
- **A scratch contract resolver** that takes a human-friendly string and returns a fully-qualified `Contract`.
- **Read-only credentials by default.** Run two IB Gateway instances under linked usernames, one with trading disabled. Point the agent at the read-only one for analysis.
- **Flex Queries for historical account state.** Deterministic Extensible Markup Language (XML) / Comma-Separated Values (CSV) reports of trades, positions, cash, dividends, and tax lots. The right primitive for "evaluate my trades" workflows.
- **Paper account as default.** Mirrors the live API exactly. Flip the connection port only when sending real orders.

### Where it gets brittle

- **Pacing violations.** IBKR enforces historical-data request limits. Agents writing loops will blow through them. A rate limiter in the skill is worth its weight.
- **Time zone and contract-month landmines.** Always pass `formatDate=2` for epoch seconds; resolve continuous futures via the front-month lookup helper.

## Complementing IBKR with a third-party data provider like Massive

For deep-data projects that exceed IBKR's pacing limits, a low-cost provider like Massive complements IBKR well. Massive is positioned as a developer-first US equities and options provider with strong software development kit (SDK) support and low-latency WebSocket delivery, and ships an official Model Context Protocol (MCP) server (`mcp_massive`) that registers with Claude Code via `claude mcp add massive`. This exposes their endpoints to the agent without writing API client code.

### The natural architecture split

- **IBKR for "self" data.** Positions, executions, cash balances, FX conversions, tax lots, transfer history, order placement. Free with the account.
- **Third-party provider for "world" data.** Universe scans, fundamentals across thousands of names, news with sentiment, full options chains. IBKR can technically serve this but pacing limits and per-exchange data subscriptions make it the wrong tool.

### Things to watch

- **Professional vs non-professional classification** matters separately for each data vendor. Personal use stays in the cheap lane on both sides.
- **Redistribution licensing.** If a side project becomes something shown to other people (a public dashboard, a Substack with live charts), licensing terms shift sharply on most retail data plans. Personal tools are unaffected.

## The bigger picture: a qualitatively different relationship with her assets

For someone who codes and is comfortable with current AI tooling, the shift is qualitative, not just quantitative.

### What becomes possible

- **Continuous awareness rather than periodic check-ins.** Concentration drift, FX rate bands, vest events, dividend ex-dates, options expiry. The default state becomes "informed when something matters".
- **Decision support that is actually personalized.** Generic financial software assumes the median user. Her own tooling can encode her actual tax residency, cost basis history at specific EUR/USD rates, and target allocations.
- **Hypothesis testing as a low-cost activity.** "What if I had sold half of every vest immediately for the last three years and dollar-cost-averaged into a global ETF" used to be an afternoon of spreadsheet work. Now it is a paragraph of natural language. Cheap hypothesis testing changes what hypotheses you bother to form.
- **Operational automation for the boring parts.** The monthly cadence of converting USD, moving to a German account, rebalancing, filing paperwork reduces to a small number of approvals.
- **A genuine learning loop.** Building your own tooling produces understanding that nobody relying on a wealth manager or default brokerage user interface (UI) develops.

### Caveats

- **Operator responsibility.** Things break. APIs change. Systems that work long-term fail loudly and conservatively rather than trying to be clever.
- **Automation as procrastination.** Easy to spend weekends building tooling to avoid the decision the tooling is supposed to inform. The discipline is minimum-viable, decide, iterate.
- **Tooling does not change underlying decisions, only the information feeding into them.** Whether to sell employer stock on vest, how concentrated to be, what hedges make sense, when to convert currency. Agents are extraordinarily good research assistants and unreliable financial advisors. Keep that distinction crisp.

### The bottom line

The practical capability gap between her and a private banking client circa 2015 is shockingly small. The gap between her and a colleague with shares stuck at Morgan Stanley is large and growing. Viewed this way, consolidating at IBKR is less about FX savings and more about choosing to live on the side of that capability gap where the interesting things happen.

---

*This summary is for informational purposes only and does not constitute financial, legal, or tax advice. Specific decisions about cross-border equity compensation, share transfers, and tax reporting should be reviewed with a qualified professional familiar with the relevant jurisdictions.*
