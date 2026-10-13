# 0006 — pi-claude-harness-cutover

- status: done
- domain: specs/agent-stack.md, SYSTEM.md, specs/editor.md, specs/shell.md, specs/keyboard.md, specs/knowledge.md
- opened: 2026-10-13
- closed: 2026-10-13

Numbered 0006: `changes/archive/0005-nextcloud-information-architecture.md` was created by another
session before this one opened.

## Problem

Luis decided the repo serves exactly two harnesses: **pi** (`pi-coding-agent` 1.0.0) and the **Claude
Code CLI**. The layout from 0004 served omp + Claude:

- `.omp/RULES.md`, `.omp/config.yml`, `.omp/rules/*` — config for a harness no longer used.
- Skills lived in `.claude/skills/`. pi does **not** read that path — its skill locations are
  `.pi/skills/`, `.agents/skills/`, `~/.agents/skills/`, `~/.pi/agent/skills/` (pi `docs/skills.md`).
- Rules lived in `.claude/rules/`. pi has **no rule mechanism** at all.
- The commit gate was omp `bash.patterns`. pi "does not ask for approval before every tool call"
  (pi `docs/security.md`) — no built-in gate.
- Untracked `.agents/skills/` and `.codex/` held string-replaced copies from another session
  (`~/.Codex/`, "`AGENTS.md` starts with `@AGENTS.md`") — the copy-drift failure 0001 documented.

## Baseline

| Metric | Before |
|---|---|
| Skills reaching pi | 0 of 3 (and 3 broken copies in `.agents/skills/`, shadowed) |
| Rules reaching pi | 0 of 3 |
| Deterministic commit gate in pi | none |
| Harness config dirs in repo | 3 (`.claude/`, `.omp/`, `.codex/`) |

## Options

### Axis 1 — where skills live

| Option | Pros | Cons | Verdict |
|---|---|---|---|
| **Canonical `.agents/skills/`, `.claude/skills` → directory symlink** | Agent Skills standard location; pi native; one link shares every future skill | relies on Claude following a symlinked skills dir (was `[UNVERIFIED]`) | **chosen** (Luis) |
| Canonical `.claude/skills/`, pi pointed at it via `.pi/settings.json` `"skills"` | no symlink | loads only after project trust; config drift | rejected |
| Canonical `.claude/skills/`, `.agents/skills` → symlink | Claude path untouched | vendor dir canonical, neutral one the alias | rejected |
| Copies | none | failure mode observed twice | rejected |

### Axis 2 — rules for a harness without rules

| Option | Pros | Cons | Verdict |
|---|---|---|---|
| **Canonical `.agents/rules/`, `.claude/rules` → symlink, pointer table in `AGENTS.md`** | Claude keeps the `paths:` trigger; pi gets an always-visible pointer; no plugin | pi path is advisory | **chosen** (Luis: "no plugin") |
| Rule-loader extension (`@vaayne/pi-rules`, `@jordyvanvorselen/pi-claude-rules`, …) | path triggering in pi | third-party code with user rights | rejected |
| Convert rules to skills | one mechanism | model-chosen loading can miss | rejected |
| Inline into `AGENTS.md` | always seen | ~1k tok always-on | rejected |

### Axis 3 — commit gate in pi

| Option | Pros | Cons | Verdict |
|---|---|---|---|
| **Own `.pi/extensions/git-guard.ts`** (fork of pi's shipped `permission-gate.ts`) | no third-party code; deterministic; versioned here | regex on shell strings, not containment | **chosen** (Luis) |
| Git hooks (`.githooks/`) | binds every tool | needs agent detection | rejected (Luis) |
| Permission-system packages (`@gotgenes/pi-permission-system`, …) | Claude-like model | heavy, churny, third-party | rejected |
| OS sandbox | real boundary | heaviest | out of scope |

Sources: pi 1.0.0 bundled docs — `docs/skills.md`, `docs/configuration.md` (context files),
`docs/security.md` (trust), `docs/extensions.md` (`tool_call` block), `examples/extensions/` ·
code.claude.com/docs/en/memory (`AGENTS.md` not read; rules support symlinks) · agentskills.io
specification · npm registry metadata for the rejected packages (names, versions, dates; sources not read).

## Decision

One canonical home, `.agents/`, for everything both harnesses share; Claude reaches it through two
directory symlinks; pi reaches skills natively and rules through a pointer table; each harness gets
its own deterministic git gate. omp and Codex config removed from the repo.

## Tasks

- [x] `rm -rf .agents/skills` (foreign copies); `git mv .claude/skills .agents/skills`; `ln -s ../.agents/skills .claude/skills`
- [x] `git mv .claude/rules/*.md .agents/rules/`; `ln -s ../.agents/rules .claude/rules`; `globs:` removed (omp-only)
- [x] `.pi/extensions/git-guard.ts` — blocks `git commit`, `git push`, `git reset --hard`
- [x] removed `.omp/` (RULES.md, config.yml, rules symlinks) and `.codex/` (hook copy + hooks.json)
- [x] `AGENTS.md` — harness row, repo map, new *Path rules — read before editing* table, gate references
- [x] `CLAUDE.md`, `README.md`, `GLOSSARY.md`, `SYSTEM.md`, `specs/README.md`, `specs/agent-stack.md` (rewrite),
      `specs/{editor,shell,keyboard,knowledge}.md`, `changes/BACKLOG.md`, `verify-repo` skill
- [x] `scripts/check.sh` — gate 1 file list; gate 10 symlinks + rule pointer + skill name; gate 11 pi guard + Claude deny per op; gate 12 no omp/Codex dirs or references

## Verification

```sh
scripts/check.sh                                    # clean, exit 0
readlink .claude/skills .claude/rules               # ../.agents/skills  ../.agents/rules
pi -p '…list available skills…'                     # new-change, vault-note, verify-repo present
pi -p '…invoke bash: git push --dry-run…'           # blocked by git-guard
claude -p '…list skills; read specs/shell.md; rule present?…'
```

## Outcome

Executed 2026-10-13. `scripts/check.sh` → **clean, exit 0**.

| Metric | Before | After |
|---|---|---|
| Skills reaching pi | 0 of 3 | 3 of 3 — `pi -p` listed `new-change, vault-note, verify-repo` |
| Skills reaching Claude | 3 (real dir) | 3 through the directory symlink — `claude -p` listed all three |
| Rules reaching Claude | 3 | 3 through the directory symlink — after reading `specs/shell.md`, Claude reported `# Editing specs and SYSTEM.md` loaded |
| Rules reaching pi | 0 | 3 by pointer table (advisory) |
| Commit gate in pi | none | `git-guard.ts`, live in this repo without `--approve` |
| Harness config dirs | 3 | 2 (`.claude/`, `.pi/`) + shared `.agents/` |
| Gate checks proven by injection | — | 9 new defects, 9 caught |

### Verified, not assumed

- **git-guard causation, throwaway repos.** With the extension:
  `git commit is blocked in workflow-opt (AGENTS.md → Approval contract 2)…`, `git log` → no commits.
  Without it: `[main (root-commit) ca79a98] guardtest`. Then in this repo, no `--approve`:
  `git push is blocked in workflow-opt…`.
- **Matcher unit check:** 16 must-block (incl. `cd x && git commit`, `git -C ../x push`,
  `git --no-pager commit`, `sh -c "git push"`, `/usr/bin/git push`, `git --git-dir=… commit`) and 12
  must-allow (`git status`, `git commit-tree`, `git reset --soft`, `git stash push`, …): 0 misses,
  1 false positive — `grep -r 'git push' docs`. Accepted and documented: a quote is treated as a
  command boundary so `sh -c "git push"` is caught.
- **Gate negative test, 9/9:** skills symlink replaced by a copy · rules symlink retargeted · pi pointer
  row deleted · rule lost `paths:` · skill `name` ≠ directory · git-guard lost its push rule · Claude
  deny lost `reset --hard` · `.omp/` recreated · `rule://` written into live docs.

### Surprises

1. **The gate failed on its own prohibition text.** Docs stating "`.omp/` must not reappear" tripped
   the dead-reference scan. Reworded the docs ("omp config directories") rather than loosening the
   gate: the forbidden literal should appear only in the gate itself.
2. **pi project trust is inherited from an ancestor.** `~/.pi/agent/trust.json` trusts
   `/Users/luis/home/luis`; `.pi/extensions/git-guard.ts` loaded here without `--approve`. Convenient
   for this repo, and a hazard for any untrusted clone under the same tree (agent-stack gap 11).
3. **pi already lists 34 skills** from user-level sources besides this repo's three — the repo's
   skills compete for routing with a large ambient set.
4. Claude following a symlinked `.claude/skills/` directory, `[UNVERIFIED]` before this change, works.
   Evidence is the model's own report under `claude -p`, not an instrumented dump.

### Folded into

`specs/agent-stack.md` (rewritten), `SYSTEM.md` (pi in Stack of record, omp retired, Claude 2.1.285),
`specs/{editor,shell,keyboard,knowledge}.md`, `GLOSSARY.md`, `README.md`, `AGENTS.md`, `CLAUDE.md`,
`changes/BACKLOG.md`.
