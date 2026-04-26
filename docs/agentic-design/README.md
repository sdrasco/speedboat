---
name: agentic-design corpus
description: Local copies of external essays on agent and harness design, plus a synthesis written for sibling repos.
type: reference
---

# Agentic-design corpus

Reference material on how to build effective agents and the harnesses
they run inside. Kept locally so the thinking is reachable offline and
survives source-side rot, and so the corpus can be opened directly by
coding agents working in this repo.

The four pieces below complement each other. Read top-to-bottom on a
first pass; the synthesis at the end is the most directly applicable.

## Index

| File | Source | What it gives you |
|------|--------|-------------------|
| [anthropic-building-effective-agents.md](anthropic-building-effective-agents.md) | https://www.anthropic.com/engineering/building-effective-agents (Schluntz & Zhang, 2024-12-19) | Workflows vs. agents, augmented-LLM building blocks, when to add complexity vs. when to stop. |
| [openai-practical-guide-to-building-agents.md](openai-practical-guide-to-building-agents.md) | https://openai.com/business/guides-and-resources/a-practical-guide-to-building-ai-agents/ (OpenAI, 2025) | Agent shape, when an agent is the right tool at all, model/tool/instruction selection. |
| [openai-harness-engineering.md](openai-harness-engineering.md) | https://openai.com/index/harness-engineering/ (Lopopolo, 2026-02-11) | The harness layer around the model: tool design, observability, eval discipline. PDF original lives alongside as `Harness engineering...pdf`. |
| [borrowable-harness-patterns.md](borrowable-harness-patterns.md) | Internal synthesis (originally written for sibling repo `unmpld`). | Six concrete patterns worth porting from harness work into a small, single-author project, plus a "what not to cargo-cult" section. |

## How to use this

When the project gains a runtime — a brokerage-API client, an
execution daemon, a small agent loop — revisit these four pieces
before writing the second iteration of any of those surfaces. The
first iteration is allowed to be naive. The second should reflect at
least the patterns flagged in the synthesis: action-surface-as-data,
decision artifacts, interface-level tests, explicit limits.

## Refresh policy

These are static snapshots. The originals will drift. Re-fetch and
diff before relying on any specific claim for non-trivial work — bump
the date below when you do.

**Last fetched:** 2026-04-26 (copied from sibling repo `unmpld`, which
fetched the originals over the period 2026-04-01 to 2026-04-09 and
2026-02-11 for the harness PDF).
