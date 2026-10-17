# 0010 — user-scope-agent-context

- status: done
- domain: specs/agent-stack.md, specs/dotfiles.md
- opened: 2026-10-17
- closed: 2026-10-17

## Problem

Preferences (output format, learning style, profile, modes, pitfalls) load only inside workflow-opt
(`AGENTS.md` → Output contract) or nowhere (Workflow MOC dump, vault `AI Personalisation … DOC April
2026.md`). Client repos, research sessions, ChatGPT get none. Observed 2026-10-13: `~/.claude/CLAUDE.md`
and `~/.pi/agent/AGENTS.md` absent (agent-stack#1). 2026-10-17: Luis created both by hand — identical
599 B files ("Explain as you go"), unmanaged, two copies.

## Baseline

- User-scope context files under version control: 0 of 2. Copies of the same text: 2.
- Places holding preference text: 4 (workflow-opt `AGENTS.md`, Workflow MOC, AI Personalisation note,
  the two hand-made files).
- Always-on size: 599 B.

## Options

| Option | Pros | Cons | Verdict |
| --- | --- | --- | --- |
| A. Two files, edited separately | none | drift (0001 Outcome 3) | ✗ |
| B. **One file in `~/devSetup/config/agents/AGENTS.md`, symlinked to both paths** | one source, git, reproducible via `install.sh` `link()` | Claude reads it as `CLAUDE.md` — no Claude-only section possible without a second file | ✓ |
| C. `~/.claude/CLAUDE.md` = `@~/.pi/agent/AGENTS.md` import | allows Claude-only additions | extra hop; import of a home path `[UNVERIFIED]` | later, if a Claude-only need appears |
| D. Source in the vault (editable on phone) | Obsidian editing | outside git; machine config belongs to devSetup (AGENTS.md → Approval 3) | ✗ |

## Decision

B (Luis, 2026-10-17: "add them first to ~/devSetup and symlink"). Axis: one versioned source vs.
per-harness flexibility; no Claude-only content exists today.

## Tasks

- [x] 1. `~/devSetup/config/agents/AGENTS.md` ← Luis's file; `install.sh`: two `link` lines; linked via
      `install.sh`'s own `link()`. Originals backed up to
      `~/.dotfiles-backup/20261017T122750/`.
- [x] 2. Content (3202 B): merge Workflow MOC (`learning/contextualisation`, `Format/Output`, `Personal
      Information`, `User Modes`, `Usage Gaps - Pitfalls`) + AI Personalisation note + "Explain as you
      go". Budget ≤ 4 KB (always-on in every session).
- [x] 3. De-duplicate: workflow-opt `AGENTS.md` Output contract → keep only repo-specific rules;
      Workflow MOC sections → one context link; AI Personalisation note marks ChatGPT text as a
      condensed derivative of the devSetup file.
- [ ] 4. Luis commits devSetup (own commit) — pending at close.
- [x] 5. Close: `specs/agent-stack.md` Current + gap 1, `specs/dotfiles.md`, BACKLOG 2 removed.

## Verification

```sh
readlink ~/.pi/agent/AGENTS.md ~/.claude/CLAUDE.md   # both → ~/devSetup/config/agents/AGENTS.md
cd /tmp && pi -p "yes/no: context has section 'Explain as you go'?"      # Yes  (2026-10-17)
cd /tmp && claude -p "yes/no: context has section 'Explain as you go'?"  # Yes. (2026-10-17)
# negative control 'Banana deployment protocol' → No / No (2026-10-17)
wc -c ~/devSetup/config/agents/AGENTS.md            # ≤ 4096 after task 2
```

## Outcome

| Metric | Before | After |
| --- | --- | --- |
| User-scope context files under git | 0 of 2 | 1 source, 2 symlinks |
| Places holding agent preference text | 4 | 1 (+ ChatGPT mirror, marked as such) |
| Always-on size | 599 B | 3202 B (budget 4096) |
| workflow-opt `AGENTS.md` | 7605 B | 7362 B (Output contract → pointer + repo addition) |
| Workflow MOC | 10995 B | 8532 B (5 sections → 1 context link) |

Verified 2026-10-17 from `/tmp`: pi and Claude Code both answer Yes to the "Learning spiral" section,
No to a fabricated section (negative control).

Vault touched: `340 …/devSetup-agents` symlink → `~/devSetup/config/agents` (Obsidian can read/edit
the file; Syncthing propagation of symlinks still `[UNVERIFIED]`, knowledge#3); Workflow MOC; AI
Personalisation note (`[!info]` mirror notice). The Workflow MOC's former *Usage Gaps - Pitfalls*
section was already gone when this ran (removed by Luis); content taken from his first message.

Not measured yet: whether sessions actually start with `GOAL · MODE · DONE · BOX` and whether the
spiral reminder fires — judge after ~2 weeks of use.
