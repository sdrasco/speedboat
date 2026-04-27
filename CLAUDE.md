# Repo guide

speedboat is a small, gifted starter repo: a thesis on consolidating
cross-border equity compensation at IBKR (specifically the EU
entity, IBKR Ireland, where IBKR routes a German-resident applicant
automatically), plus the operational scripts and reference material
to drive IBKR's Client Portal Gateway once an account exists. Two participants plus a
coding agent: the Manager (giver of this repo), the Contributor
(owner), and the Agent (AI assistant). No runtime that touches real
money.

## Where to look

- [README.md](README.md) — friendly intro: what speedboat is, what's easy/hard, getting started
- [ibkr_for_cross_border_equity_comp.md](ibkr_for_cross_border_equity_comp.md) — the seed thesis: cross-border equity comp at IBKR Ireland, with project ideas and caveats
- [docs/conventions.md](docs/conventions.md) — repo conventions, doc voice, git
- [docs/lingo.md](docs/lingo.md) — shorthand the participants use
- [docs/future-projects.md](docs/future-projects.md) — deferred ideas with their full scoping context (brokerage tools, VM hosting, orchestrator + persistent memory)
- [docs/collaboration/inputs.md](docs/collaboration/inputs.md) — symmetric log of design exchanges
- [docs/collaboration/open-questions.md](docs/collaboration/open-questions.md) — questions waiting on input
- [docs/ibkr/README.md](docs/ibkr/README.md) — IBKR Web API doc snapshots and distilled gotchas
- [docs/ibkr/spinup.md](docs/ibkr/spinup.md) — how to bring the gateway up, with screenshots
- [docs/ibkr/what-works.md](docs/ibkr/what-works.md) — capabilities the IBKR API offers cleanly
- [docs/ibkr/what-doesnt.md](docs/ibkr/what-doesnt.md) — limits and where you'd want different data
- [docs/agentic-design/README.md](docs/agentic-design/README.md) — local copies of essays on agent and harness design
- [scripts/](scripts/) — `download_gateway.sh`, `spinup.sh`, `teardown.sh`

Add new docs under `docs/` and link them above rather than growing this file.
