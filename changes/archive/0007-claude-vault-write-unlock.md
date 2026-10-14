# 0007 — claude-vault-write-unlock

- status: done
- domain: specs/agent-stack.md, specs/knowledge.md
- opened: 2026-10-13
- closed: 2026-10-13

## Problem

Planned vault work (0008: reformat notes into the vault standard) needs Claude Code to edit vault
files. `.claude/settings.json` denied `Edit(vault/**)` and `Edit(//Users/luis/luis_obsidian_vault/**)`,
and `PreToolUse` hook `.claude/hooks/block-vault-writes.sh` blocked Write/Edit and mutating Bash on
any vault path — even when Luis named the path. pi had no such gate: two harnesses, two behaviours
for the same contract.

## Baseline

Claude Code vault writes possible: 0 (all blocked by hook, exit 2). pi: unblocked, prose-only.

## Options

| Option | Pros | Cons | Verdict |
| --- | --- | --- | --- |
| A. Keep the gate | hard guarantee against accidental vault writes | blocks the main use case (reformat); harness asymmetry | ✗ |
| B. Allow-list paths in the hook (e.g. per-session env var) | keeps a guard | complexity before any failure was observed | ✗ premature |
| C. Remove deny + hook; prose rule (approval contract, `.agents/rules/vault.md`) for both harnesses | symmetric, unblocks work; limits added after a real failure | no hard guard; vault has no git/undo | ✓ |

Prior decisions: 0004/0006 introduced the gate as a precaution, not after an incident.

## Decision

C — Luis, 2026-10-13: "Claude should be able to edit vault … specific limitations we set after
working with it if problems occur." Axis: unblocking the use case vs precautionary safety; no
incident ever justified the gate. `Read(vault/.obsidian/**)`, `Read(vault/.trash/**)` stay (noise
avoidance, not a write limit).

## Tasks

- [x] `.claude/settings.json`: drop the two `Edit(vault…)` denies and the `hooks` block.
- [x] `git rm .claude/hooks/block-vault-writes.sh`; empty `.claude/hooks/` removed.
- [x] `scripts/check.sh` gate 11: the presence check encoded the retired invariant → inverted to
      assert the hook stays absent (check changed by this decision, not to force a pass).
- [x] `CLAUDE.md`, `README.md`, `specs/agent-stack.md`, `specs/knowledge.md`: references updated;
      agent-stack#2 and knowledge#7 resolved.

## Verification

```sh
grep -c 'vault' .claude/settings.json   # 2 (only the Read denies)
test ! -e .claude/hooks/block-vault-writes.sh && echo gone
scripts/check.sh
```

## Outcome

Claude Code vault writes: blocked → allowed (prose-governed, same as pi). Not yet observed in a
live Claude session — first real test is 0008 task 1. Backup of the removed hook at
`/tmp/block-vault-writes.sh.bak` (volatile); git history has it.
