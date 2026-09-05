---
name: verify-repo
description: Verification gate for this repo. Runs structure, link, secret and symlink checks. Use before finishing any change, after editing AGENTS.md/specs/changes, or when asked to verify the repo.
---

# verify-repo

A documentation repo has no build and no test suite, so the check has to be constructed. This is it.
Anthropic's first best practice for agentic coding is to give the agent something that returns
pass/fail; without it, "looks done" is the only signal.

Run:

```sh
./.claude/skills/verify-repo/check.sh
```

Nine checks: required files present · `CLAUDE.md` starts with `@AGENTS.md` · `AGENTS.md` ≤ 150 lines ·
every spec has `Current`/`Invariants`/`Gaps` · every change has all template sections plus `status` ·
relative markdown links resolve · no key-shaped strings in tracked files · both symlinks live ·
`vault/` untracked.

On failure: fix the cause, re-run, paste the real output. Never report a change complete on a red run.
Never edit `check.sh` to make a check pass — if a check is wrong, that is its own change.
