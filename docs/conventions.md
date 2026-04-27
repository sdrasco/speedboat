# Conventions

Non-obvious rules and stylistic norms for this repo. Keep this short;
prefer one sentence per item.

## Hard constraints

speedboat has no runtime today. This section is a placeholder for
constraints that take effect once code exists. The most important
one will be:

- **Read-only against any real brokerage account, in this repo.** If
  and when a runtime is added that touches IBKR, it must not place,
  modify, cancel, or stage orders. The full version of this rule
  (including the specific endpoints to refuse) is in
  [docs/ibkr/conventions.md](ibkr/conventions.md), inherited from
  sibling repo `nekomata`. Any execution-capable code belongs in a
  separate, narrowly-scoped repo, not here.

## Doc voice and roles

- The repo is a shared space. Write all canonical docs in neutral /
  "we" voice, not "I" voice. The collaboration log
  ([docs/collaboration/inputs.md](collaboration/inputs.md)) is the
  exception — it preserves first-person attributions per role.
- **Real names are kept out of the repo.** Canonical docs use three
  role names instead of personal identifiers:
  - **Manager** — the project lead.
  - **Contributor** — the collaborator (whose situation the seed doc
    describes).
  - **Agent** — the AI coding assistant.
- **`Contributor` (capitalized) is always the role.** Lowercase
  `contributor(s)` is generic English. `client`, `agent` lowercased
  in the IBKR / API material refer to software clients (HTTP
  clients, the IBKR Client Portal Gateway as a product name) and
  user-agents — unrelated to the role names. The capitalization is
  the disambiguation rule; respect it.
- If a participant wants to be named explicitly, they can edit;
  until then, role names win.

## Style

- **Define acronyms on first use** — full phrase followed by the
  acronym in parentheses, inline. The seed doc already follows this.
- **Em-dashes are fine.** They show up freely in the seed doc and
  in sibling repo `nekomata`, and the imported agent-design corpus
  uses them too. Staying consistent with that local norm rather
  than importing the JobSearch ban.
- Markdown reference style: GitHub-flavored. File and path links use
  relative paths so the repo browses correctly on disk and on
  github.

## Push workflow

Three remotes, M4 is primary:

| Remote | Role |
|--------|------|
| M4     | primary (local Mac) |
| M1a    | backup (second Mac) |
| github | cloud backup (private) |

**Always push M4 first.** Then M1a and github. **Always ask before
pushing.** Shortcut: `git pushall` (global alias — pushes all three
in order).

**Deferred decision.** This workflow assumes a single committer with
the M4 mac as ground truth. If the Contributor joins as a second
committer, github becomes the collaboration surface (PRs, branches,
review) and the M4-first ordering stops making sense. The full
reasoning and the likely shape of the change live in
[docs/future-projects.md](future-projects.md) — pick it up when the
Contributor makes a commit.
