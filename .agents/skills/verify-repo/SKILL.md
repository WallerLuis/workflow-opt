---
name: verify-repo
description: Verification gate for this repo. Runs structure, link, secret, symlink, rule-loading, gate and terminology checks. Use before finishing any change, after editing AGENTS.md/specs/changes, or when asked to verify the repo.
---

# verify-repo

A documentation repo has no build and no test suite, so the check has to be constructed. This is it.
Anthropic's first practice for agentic coding is to give the agent something that returns pass/fail;
without it, "looks done" is the only signal.

Run:

```sh
scripts/check.sh
```

Thirteen gates: required files present · `CLAUDE.md` starts with `@AGENTS.md` · `AGENTS.md` ≤ 150
lines · every spec has `Current`/`Invariants`/`Gaps` · every change has all template sections plus
`status` · every relative markdown link resolves (all links per line, not just the last) · no
key-shaped strings in tracked files · both repo↔vault symlinks live · `vault/` untracked ·
`.claude/rules` and `.claude/skills` are **directory symlinks** into `.agents/`, never copies · every
rule has `description:` + `paths:` and a row in the `AGENTS.md` *Path rules* table · every skill's
`name` equals its directory · vault hook executable, pi `git-guard.ts` and Claude deny rules cover
commit/push/reset · terminology (`spec-anchored`, no dead paths, no omp or Codex config directories) ·
no trailing whitespace.

On failure: fix the cause, re-run, paste the real output. Never report a change complete on a red run.
Never edit `scripts/check.sh` to make a check pass — if a check is wrong, that is its own change.
