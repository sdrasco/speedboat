---
name: Borrowable harness patterns
description: Synthesis of harness-design patterns worth porting into a small, focused project.
type: reference
---

# Borrowable harness patterns

**Origin:** This document is a synthesis of patterns worth borrowing
from another small AI-agent project, distilling lessons from a
review of the OpenAI/Codex harness work and the broader
agent-engineering corpus stored alongside this file. The patterns
generalize cleanly to any small project with a focused runtime,
which is the shape this repo is likely to grow into. The original
worked examples have been kept where they make a pattern concrete,
generalized away from any specific file names.

---

## Why this exists

The main lesson from the review was not "copy that harness." Most of
the useful bits were around making an agent system easier to inspect,
explain, debug, and extend.

That matters for any project of this shape because **build a better
agent, not a costlier model** still applies. Better prompts and better
runtime discipline only get you so far if the surrounding system is
hard to understand or hard to evaluate.

## 1. Repo-native learning corpus

One genuinely useful idea is to maintain docs for both humans and
coding agents.

Not just:

- a README
- a long system prompt
- scattered inline comments

But a small corpus that explains:

- what the real runtime entry points are
- which files are authoritative
- how data moves through the system
- what the agent can and cannot do
- where extension work should happen

In the source project, the high-value surfaces were the entry point
and route wiring, the main chat/action loop, the ingestion and
scoring logic, the data acquisition layer, the data model, and the
test boundary. For this repo, the analogous surfaces will appear as
the project grows — likely a brokerage-API client, a small
dashboard, and whatever decision-support layer sits on top.

The goal is simple: when a human or coding agent opens the repo, they
should not need to reconstruct the architecture from scratch.

## 2. Action surface as data

If a project gains an action interface (a chat tool surface, a CLI
with subcommands, a set of API mutations), it's tempting to let the
description live in two places: prose/tool instructions in a system
prompt, and execution logic in the code. That works, but it is easy
for those two surfaces to drift.

A better long-term pattern is to treat actions as a canonical
registry:

- action name
- purpose
- required fields
- optional fields
- examples
- validation rules
- risk level
- whether confirmation is required
- whether the action changes persisted state

That registry can then drive:

- prompt/tool documentation
- runtime validation
- confirmation rules
- tests
- admin/debug tooling
- future UI affordances

This is less about abstraction for its own sake and more about
keeping the bot's contract in one place. For this repo it matters
specifically for any future broker-facing tool: "place a limit
order" is exactly the kind of action where a single canonical
definition is worth its weight.

## 3. Session and decision artifacts

Another useful pattern is to persist more of the agent's decision
trail.

For an agent that takes user input and produces a reply plus actions,
the valuable artifacts are:

- user message
- compact context summary
- raw model output
- parsed reply and actions
- actions actually taken
- recovery-pass output when actions were missing
- review-pass output when an honesty checker rewrote the reply
- provider/model used
- latency, token, and cost metadata
- whether a confirmation gate was triggered

This is not for user-facing transcripts. It is for debugging, evals,
and failure analysis.

When the system does something strange, you should be able to answer:

- Was the prompt bad?
- Was the context misleading?
- Did the model omit an action?
- Did validation change the outcome?
- Did the review pass save you or hide a deeper problem?

If you cannot answer those questions from saved artifacts, improving
the system becomes guesswork.

## 4. Interface-level tests, not just helper tests

It is common for early tests to cover pure helper logic — parsing,
validation, arithmetic. That is good, but it leaves the most agentic
surface under-tested.

The next tier of tests should focus on the interface contract:

- action parsing from model output
- action execution against a test database (or a paper account, in a
  brokerage context)
- confirmation behavior for risky bulk actions
- recovery when the model promises an action but omits it
- review-pass correction when the reply over-claims or misstates
  counts
- refusal behavior when the user asks for capabilities the system
  does not have

The key principle is that the highest-risk bugs live at the interface
between prompt, parsed JSON, execution, and review. That boundary
deserves direct tests.

For a brokerage-adjacent project this principle is sharper still: the
boundary between "agent suggests a trade" and "trade is sent" is the
single most important place to put tests, and ideally also a hard
human-in-the-loop confirmation step that no test can bypass.

## 5. Explicit limits as a design asset

Docs should say clearly what the system is *not*.

This sounds obvious, but it is easy to under-document limits and
then accidentally build around false assumptions. Examples from a
small AI-agent charter that illustrate the pattern:

- chat does not browse the web
- a single canonical data-acquisition path is the primary source
- arithmetic and counting should be deterministic, not delegated to
  the model
- high-impact bulk actions need confirmation
- background profile updates are opportunistic and quiet, not a
  second visible conversation

For this repo, the equivalents will look different (e.g. *"this repo
does not place orders,"* *"the agent does not give tax advice,"*
*"FX-rate watching is read-only and notifies, never auto-converts"*),
but the principle is the same.

Good limits reduce bluffing, reduce wasted prompt tokens, and make
future changes more intentional.

## 6. Docs as extension guidance

One of the more useful harness habits is treating docs as a map for
future contributors:

- where to add a new action
- where to add a new data source
- where to add a new validation rule
- where to add a new guardrail
- what tests should accompany each type of change

Small systems are easiest to maintain when extension seams are
obvious. This matters most when a second developer arrives — the docs
are the difference between the second person re-deriving the
architecture and the second person extending it.

## What not to cargo-cult

Not every harness-looking pattern is worth importing.

Things to avoid copying unless there is a concrete need:

- placeholder runtime layers
- mirror/parity machinery
- command catalogs that describe non-existent execution
- bootstrap/setup theatre that adds ceremony without safety
- abstraction layers that hide the real prompt and action flow

The standard should be: if a pattern makes the system easier to
understand, debug, or evaluate, it is interesting. If it mostly makes
the repo look more "agentic," it is probably noise.

## Practical direction

If you act on this document in a new project, the likely order is:

1. Add a small set of architecture notes for the real runtime
   surfaces (once they exist).
2. Document the action surface in a more canonical way (once there
   is one).
3. Add tests around the action/review loop.
4. Add structured logging for agent decisions if debugging pressure
   increases.

That sequence keeps a project aligned with the design philosophy
underlying this corpus: minimal code, clear interfaces, better agent.
