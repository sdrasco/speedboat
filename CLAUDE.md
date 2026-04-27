# Repo guide

speedboat explores where to store financial assets distributed as part
of a compensation package. Today it's a docs-only repo: a seed thesis,
an imported corpus on agent design, and an imported corpus of IBKR
institutional knowledge. Two contributors plus a coding agent: the
Manager (lead), the Contributor (collaborator, whose situation the
seed doc describes), and the Agent (AI assistant). No runtime, no
code that touches real money.

## Where to look

- [README.md](README.md) — what speedboat is, who it's for, status, repo layout
- [ibkr_for_cross_border_equity_comp.md](ibkr_for_cross_border_equity_comp.md) — the seed thesis: cross-border equity comp at IBKR Ireland, with project ideas and caveats
- [docs/conventions.md](docs/conventions.md) — repo conventions, doc voice, push workflow
- [docs/lingo.md](docs/lingo.md) — shorthand the contributors use
- [docs/future-projects.md](docs/future-projects.md) — deferred ideas with their full scoping context (brokerage tools, VM hosting, orchestrator + persistent memory)
- [docs/collaboration/inputs.md](docs/collaboration/inputs.md) — symmetric log of design exchanges between the contributors
- [docs/collaboration/open-questions.md](docs/collaboration/open-questions.md) — questions waiting on input
- [docs/agentic-design/README.md](docs/agentic-design/README.md) — local copies of essays on agent and harness design (Anthropic, OpenAI, plus an internal synthesis)
- [docs/ibkr/README.md](docs/ibkr/README.md) — IBKR Web API doc snapshots and distilled gotchas from sibling repo `nekomata`

Add new docs under `docs/` and link them above rather than growing this file.
