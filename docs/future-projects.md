# Future projects

Scoped-out thought experiments for things deferred but not forgotten.
Each entry captures enough context that a future reader (either
contributor) can pick up the problem cold without re-doing the
research.

## Brokerage tools — read-only IBKR client and dashboard

**Status:** deferred 2026-04-26. Revisit once an IBKR Ireland
account exists to point a client at.

### What this would be

A small read-only IBKR Web API client plus a Streamlit (or similar)
dashboard, modelled on sibling repo `nekomata`. Same shape: Client
Portal Gateway daemon on `localhost:5000`, browser login + IBKR
Mobile 2FA, then a thin HTTP wrapper that calls the gateway from
Python. Surface includes positions, balances, today's P/L,
allocation treemap, multi-currency cash, and an Activity Statement
import path for historical trades.

The corpus to lean on already lives in this repo:

- [docs/ibkr/README.md](ibkr/README.md) — IBKR doc snapshots and
  context.
- [docs/ibkr/conventions.md](ibkr/conventions.md) — the gotchas a
  fresh implementation would otherwise have to rediscover (options
  vs stocks P&L, RTH handling, futures front-month resolution,
  sector taxonomy, cash field divergences).
- [docs/ibkr/activity-statements.md](ibkr/activity-statements.md) —
  why the CP Web API is inadequate for historical trades and how to
  pull the Activity Statement CSV instead.
- [docs/ibkr/cert-regen.md](ibkr/cert-regen.md) — TLS cert
  regeneration recipe.

### Why deferred

No account to point it at yet. The decision to consolidate at IBKR
Ireland is the seed-doc thesis but has not been acted on. Building a
client without an account would be cargo-culting `nekomata` instead
of solving a concrete problem.

### Decision point

Build when:
1. The IBKR Ireland account is open and funded; and
2. There's a specific question the dashboard would answer that the
   IBKR web portal answers poorly (concentration drift over time,
   FX timing, vest-event tracking).

Until then, the corpus is reference material rather than a
specification.

## Remote VM hosting via exe.dev

**Status:** deferred 2026-04-26. Revisit when there's a doc set or
service worth hosting.

### Two distinct possible uses

These have very different feasibility profiles and shouldn't be
conflated:

**(a) A VM-hosted documentation site** for sharing the repo's docs
between the contributors. Cheap and low-stakes — exe.dev VM, nginx,
a static-site generator (MkDocs, Eleventy, similar) building from
the repo, deploy on push. The exe.dev `X-ExeDev-Email` proxy auth
gives a single-email passkey ring. No IBKR component. **This is the
near-term target** once the doc set stabilises enough to be worth
sharing as a site rather than a folder.

**(b) Hosting a brokerage daemon** for unattended automated
execution. Structurally blocked, not just deferred. The IBKR Client
Portal Gateway requires a human approving an IBKR Mobile push
roughly every 24 h; no VM, nginx, or passkey setup changes that.
Retail accounts cannot use OAuth 2.0 direct Web API access. Real
paths for retail automation (per `nekomata`'s scoping) are: IB
Gateway desktop + IBC controller, a different broker with
key-based auth, or accepting daily human re-auth. All of those
belong in a future separate execution-system repo, not here.

### Reference for both paths

- The `using-exe-dev` skill at
  [.claude/skills/using-exe-dev.md](../.claude/skills/using-exe-dev.md)
  is the cheat sheet for the platform.
- For path (b), the salient reasoning is in
  `../nekomata/docs/future-projects.md` (24h-2FA as the structural
  blocker; one-week probe with paper account as the right
  experiment). Not duplicated here because the constraint hasn't
  changed.

### Decision point for (a)

Build when:
1. The doc set has stabilised enough that a static site adds value
   over browsing the repo directly; and
2. There's a concrete event (the Contributor asking for a link, or
   a stretch where the docs would otherwise be shared via
   screenshots).

## Orchestrator + persistent memory across chat sessions

**Status:** deferred 2026-04-26. Origin: the Contributor's first
design pointer (see
[docs/collaboration/inputs.md](collaboration/inputs.md)). Revisit
once at least one runtime surface exists for the orchestrator to
coordinate.

### The pointer

The Contributor suggested *"an orchestrator for the chat sessions,
with persistent memory across them."* The Manager agreed in
principle but deferred to first build the nekomata-style
scaffolding, then reconcile the Contributor's input on top.

This points at a meta-layer: how the project itself gets developed
and reasoned about, rather than a brokerage-tool feature. It maps
onto the orchestrator-workers pattern catalogued in
[docs/agentic-design/anthropic-building-effective-agents.md](agentic-design/anthropic-building-effective-agents.md)
and the session/decision-artifact pattern in
[docs/agentic-design/borrowable-harness-patterns.md](agentic-design/borrowable-harness-patterns.md).

### Open clarifying questions (live)

Sit in [docs/collaboration/open-questions.md](collaboration/open-questions.md)
until answered:

1. What's the orchestrator orchestrating — coding sessions,
   decision-support conversations, or both?
2. Memory of what — decisions, conversation summaries, or account
   state?
3. Build a custom orchestrator or commit to the orchestrator-shaped
   architecture and pick an existing tool?

### Why deferred

Building an orchestrator before there's anything to orchestrate
risks becoming the "harness theatre" pattern explicitly flagged
against in
[docs/agentic-design/borrowable-harness-patterns.md](agentic-design/borrowable-harness-patterns.md).
The right time to commit is once at least one of {brokerage client,
shared decision log, deployed doc site} exists, so the orchestrator
has concrete sub-systems to coordinate and concrete state to
persist.

### Decision point

Pick this back up when one of:
- The first runtime surface (any of the three above) has been
  built and is being used in two or more parallel chat sessions.
- The Contributor's clarifying answers come back and reshape the
  scope.
- The conversation log in `inputs.md` gets thick enough that
  ad-hoc memory in `MEMORY.md` is visibly losing context across
  sessions.

## Push workflow with a second committer

**Status:** deferred until the Contributor's first commit lands.
Captured in [docs/conventions.md](conventions.md) under the push
workflow section as a flag.

### What changes when there's a second committer

The current three-remote workflow (M4 → M1a → github, M4 first)
treats github as cold backup. If the Contributor commits, github
has to become the collaboration surface (PRs, branches, review),
at which point the M4-first ordering stops being meaningful — those
commits arrive *from* github, not via a Mac the Contributor doesn't
have access to.

### Likely shape of the change

- github becomes the source of truth for the default branch.
- M4 and M1a shrink to local backups, pulling from github.
- `git pushall` either gets reordered (github first) or replaced
  with a normal github push, with a separate sync script for the
  Mac backups.
- "Always ask before pushing" still applies, but the meaning shifts
  — pushes can now overwrite the other contributor's work, so the
  rule becomes "always rebase or merge, then ask."

Don't pre-build any of this. Decide based on what's actually
inconvenient when the Contributor starts committing.
