# Lingo

Recurring shorthand used in conversation with a coding agent. Look
here before asking what a short directive means. Living document;
add entries as new shorthand shows up.

## do a push / push this

**Meaning:** commit any pending changes and `git push` to the repo's
single remote. Always confirm before pushing if any change touches
sensitive areas (memory files, credentials, anything outside the
working tree). See the **Git** section in
[conventions.md](conventions.md#git).

## spinup

**Meaning:** run `scripts/spinup.sh`. Brings the IBKR Client Portal
Gateway up: starts the daemon if it's down, opens the login page in
Chrome, waits for IBKR Mobile push approval, then prints a
confirmation. Idempotent. Walkthrough with screenshots in
[docs/ibkr/spinup.md](ibkr/spinup.md).

## spindown / teardown

**Meaning:** run `scripts/teardown.sh`. Sends a graceful logout to
IBKR (so the next login is a clean push approval rather than a
challenge dialog) and stops the gateway daemon.

## Future additions

Add new entries above this section. Format:

```
## term / alternate phrasing

**Meaning:** what action to take, and any caveats.
```
