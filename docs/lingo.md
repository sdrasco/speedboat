# Lingo

Recurring shorthand the contributors use in conversation with a
coding agent. Written for any LLM working in this repo — look here
before asking what a short directive means. Living document; add
entries as new shorthand shows up.

## do a push / push this

**Meaning:** follow the three-remote workflow documented in
[conventions.md](conventions.md#push-workflow). Cross-repo convention
— the same three remotes (M4, M1a, github) apply in `nekomata`,
`unmpld`, and `flatbot` too.

Key rule: **push M4 first**, then M1a and github as reachable.
Always confirm with the user before pushing — show which remotes
you intend to hit. `git pushall` is the global alias that does all
three in order.

## spinup

**Meaning:** placeholder. In sibling repo `nekomata`, `spinup` runs
`scripts/spinup.sh` to bring the IBKR Client Portal Gateway and
Streamlit dashboard up. speedboat has no equivalent yet — when a
local runtime is added, give it a `scripts/spinup.sh` and update
this entry.

## Future additions

Add new entries above this section. Format:

```
## term / alternate phrasing

**Meaning:** what action to take, and any caveats.
```
