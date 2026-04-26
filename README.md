# speedboat

A shared working repo for thinking through where to store financial
assets distributed as part of a compensation package. Specifically:
when shares arrive in a US brokerage account, but the recipient lives
and pays tax in another jurisdiction, what's the right place to hold
them, and what tooling is worth building around that decision.

## What this is

Today, docs only. The repo collects:

- A seed thesis on cross-border equity compensation at IBKR Ireland
  (the motivating case is the friend's situation: Spanish citizen,
  German tax resident, US tech employee with shares at Morgan
  Stanley).
- A reference corpus on agent and harness design (Anthropic, OpenAI,
  plus an internal synthesis), kept locally so the thinking is
  reachable offline.
- A reference corpus on the IBKR Client Portal Web API, including
  snapshots of IBKR's public docs and the hard-won gotchas from
  sibling repo `nekomata` (a working read-only IBKR dashboard).

No runtime, no code that touches real money, no brokerage client.
Those are deferred — see [docs/future-projects.md](docs/future-projects.md)
for the shape they're likely to take.

## Status

- **Today (2026-04-26):** initial scaffolding. Seed doc plus imported
  corpora plus the conventions to keep things shareable as the
  project grows.
- **Soon:** a documentation channel that's directly shareable —
  probably a small VM-hosted site so updates land in one place
  rather than fragmenting across email or text.
- **Plausibly:** a small read-only IBKR client + dashboard adapted
  from `nekomata`, once there's an account to point it at. Possibly
  later, an orchestrator layer for the chat sessions used to develop
  and reason about the project — see
  [docs/collaboration/inputs.md](docs/collaboration/inputs.md).

## Repo layout

| Path | Purpose |
|------|---------|
| [CLAUDE.md](CLAUDE.md) | Thin table-of-contents for coding agents working in this repo |
| [ibkr_for_cross_border_equity_comp.md](ibkr_for_cross_border_equity_comp.md) | The seed thesis (cross-border equity comp, IBKR Ireland, project catalog) |
| [docs/conventions.md](docs/conventions.md) | Repo conventions, doc voice, push workflow |
| [docs/lingo.md](docs/lingo.md) | Shorthand used in chat with coding agents |
| [docs/future-projects.md](docs/future-projects.md) | Deferred ideas with scoping context |
| [docs/collaboration/](docs/collaboration/) | Symmetric design-exchange log + open questions |
| [docs/agentic-design/](docs/agentic-design/) | Local essays on agent and harness design |
| [docs/ibkr/](docs/ibkr/) | IBKR Web API doc snapshots + institutional knowledge |
| [.claude/skills/](.claude/skills/) | Skill files for coding agents (currently: exe.dev usage) |

## Conventions

The doc set is written in neutral / "we" voice on the assumption that
both contributors will read everything. Real names are kept out of
the repo: the seed doc and all canonical docs use `the friend` as
the pseudonym. See [docs/conventions.md](docs/conventions.md) for
the full set.

## Push workflow

Three remotes — M4 (primary, local Mac), M1a (backup, second Mac),
github (private cloud backup). Always push M4 first. Always ask
before pushing. If a second committer joins, github takes over as
the collaboration surface and this workflow needs revisiting; the
deferred decision is captured in [docs/future-projects.md](docs/future-projects.md).
