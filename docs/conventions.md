# Conventions

Non-obvious rules and stylistic norms for this repo. Keep this
short; prefer one sentence per item.

## Hard constraints

speedboat has no runtime today. This section is a placeholder for
constraints that take effect once code exists. The most important
one will be:

- **Read-only against any real brokerage account, in this repo.** If
  and when a runtime is added that touches IBKR, it must not place,
  modify, cancel, or stage orders. The full version of this rule
  (including the specific endpoints to refuse) is in
  [docs/ibkr/conventions.md](ibkr/conventions.md). Any
  execution-capable code belongs in a separate, narrowly-scoped
  repo, not here.

## Doc voice and roles

- The repo is for both human and Agent eyes. Write all canonical
  docs in neutral / "we" voice, not "I" voice. The collaboration log
  ([docs/collaboration/inputs.md](collaboration/inputs.md)) is the
  exception — it preserves first-person attributions per role.
- **Real names are kept out of the repo.** Canonical docs use three
  role names instead of personal identifiers:
  - **Manager** — the giver of this repo.
  - **Contributor** — the owner of this repo (whose situation the
    seed doc describes).
  - **Agent** — the AI coding assistant.
- **`Contributor` (capitalized) is always the role.** Lowercase
  `contributor(s)` is generic English. `client`, `agent` lowercased
  in the IBKR material refer to software clients (HTTP clients, the
  IBKR Client Portal Gateway as a product name) and user-agents —
  unrelated to the role names. The capitalization is the
  disambiguation rule; respect it.
- If a participant wants to be named explicitly, they can edit;
  until then, role names win.

## Style

- **Define acronyms on first use** — full phrase followed by the
  acronym in parentheses, inline. The seed doc already follows this.
- **Em-dashes are fine.** They show up freely in the seed doc and
  the imported agent-design corpus uses them too. Stay consistent
  with that local norm.
- Markdown reference style: GitHub-flavored. File and path links use
  relative paths so the repo browses correctly on disk and on
  GitHub.

## Notes-as-docs

This repo is meant to grow as a working knowledge garden. When you
have a quick thought or pointer that doesn't fit neatly into an
existing doc, prefer **a new short focused file under `docs/`**
over appending to an already-busy file. A one-screen file with a
clear title is much easier to find and read later than a paragraph
buried in a long doc. Link new files from
[CLAUDE.md](../CLAUDE.md) so the index stays usable.

## Git

This repo uses a single remote, set up by whoever owns it. Normal
`git push` and `git pull` against that one remote. Always commit
before pushing.
