# spec: agent-stack

The coding agents, their instruction layer, and the gates that bind them. Harnesses: **pi** and the
**Claude Code CLI** — nothing else is supported (`changes/archive/0006-*`).

## Current

Verified 2026-10-13.

- **pi** — `pi-coding-agent` 1.0.0, `/opt/homebrew/bin/pi` → `/opt/homebrew/Cellar/pi-coding-agent/1.0.0`
  (earendil-works; the project omp was forked from). `~/.pi/agent/settings.json` (584 B):
  `defaultProvider: openai-codex`, `defaultModel: gpt-5.6-terra`, `tuiMode: fullscreen`, one package
  `npm:@gotgenes/pi-anthropic-auth`. `~/.pi/agent/trust.json` trusts `/Users/luis/home/luis`, an
  ancestor of this repo → project resources (`.pi/extensions/`) load without a `--approve` flag
  (observed, see table). `Ctrl+G` (`app.editor.external`) hands the draft to `externalEditor`, then
  `$VISUAL`, then `$EDITOR`.
- **Claude Code CLI** 2.1.285 (`/opt/homebrew/Caskroom/claude-code/2.1.285`). `~/.claude/settings.json`:
  model `opus[1m]`, `effortLevel: medium`, `editorMode: vim`, `tui: fullscreen`, custom statusline,
  `autoMemoryEnabled: false`, plugin `pyright-lsp`, 14 `permissions.allow` entries.
- Model providers: Claude (`anthropic`) and Codex (`openai`), used from both harnesses.
- omp 18.5.0 is still installed but **retired as a harness** (`SYSTEM.md` → Retired). If launched here it
  would still read `AGENTS.md` and `.agents/skills/`, but no repo asset targets it.
- Repo assets: `AGENTS.md` (canonical), `CLAUDE.md` (`@AGENTS.md`), three rules in `.agents/rules/`,
  three skills in `.agents/skills/`, one pi extension (`.pi/extensions/git-guard.ts`), one gate
  script. No Claude hooks: the vault-write `PreToolUse` hook was removed in 0007.
- Machine-wide assets outside this repo: `~/.claude/commands/write-ticket.md` (9.7 KB). No user-level
  `~/.claude/CLAUDE.md`, no `~/.pi/agent/AGENTS.md`.
- Account switching: `~/.local/bin/claude-swap` / `cswap`, aliased `cs`.

### Layout — canonical in `.agents/`, Claude reaches it by symlink

```
AGENTS.md                          canonical contract
CLAUDE.md                          @AGENTS.md + Claude-only notes
.agents/rules/<name>.md            canonical rules — frontmatter: description: + paths:
.agents/skills/<name>/SKILL.md     canonical skills — Agent Skills standard location
.claude/rules  -> ../.agents/rules    directory symlink
.claude/skills -> ../.agents/skills   directory symlink
.pi/extensions/git-guard.ts        pi gate
.claude/settings.json              Claude gate (deny: git ops, vault .obsidian/.trash reads)
```

### What each harness actually loads — observed 2026-10-13

| Asset | pi | Claude Code CLI |
|---|---|---|
| `AGENTS.md` | ✅ native — cwd and every parent, plus `~/.pi/agent/`. Observed: `pi -p` → "does your context include AGENTS.md" → `yes` | ✗ natively — "Claude Code reads `CLAUDE.md`, not `AGENTS.md`" (code.claude.com/docs/en/memory#agentsmd) |
| `CLAUDE.md` | recognised as a context filename; precedence vs `AGENTS.md` in the same directory `[UNVERIFIED]` | ✅ with `@AGENTS.md` expanded at launch (≤4 hops) |
| skills, `.agents/skills/` | ✅ native Agent Skills location (pi docs/skills.md). Observed: `new-change, vault-note, verify-repo` listed | ✅ through the `.claude/skills` directory symlink. Observed: `new-change, vault-note, verify-repo` |
| rules, `.agents/rules/` | **no rule mechanism** — reached through the *Path rules* pointer table in `AGENTS.md`; advisory | ✅ through the `.claude/rules` directory symlink; `paths:` triggers on read. Observed: reading `specs/shell.md` → rule `# Editing specs and SYSTEM.md` present |
| `.pi/extensions/git-guard.ts` | ✅ `tool_call` handler, `{ block: true }`. Observed in this repo without `--approve`: `git push is blocked in workflow-opt (AGENTS.md → Approval contract 2)…` | ✗ |
| `.claude/settings.json` deny | ✗ | ✅ (`Edit(path)` rules only; `Write(...)` entries are inert) |

The two "observed" Claude rows rest on the model's own report in `claude -p`, not on a debug dump —
strong but not instrumented evidence.

### git-guard — what it blocks

`git commit`, `git push`, `git reset --hard`, including behind `cd x &&`, `;`, `|`, env assignments,
`sh -c "…"`, `/usr/bin/git`, and global options (`-C dir`, `-c k=v`, `--no-pager`, `--git-dir=…`).
Always blocks, no confirm — the contract is "never", not "ask".

- Matcher unit check: 16 must-block / 12 must-allow commands, 0 misses, 1 accepted false positive
  (`grep -r 'git push' docs` is blocked because a quote counts as a command boundary; pi's grep tool
  covers searching).
- Causation proven in throwaway repos: **with** the extension → block reason, no commit;
  **without** → `[main (root-commit) ca79a98] guardtest`.
- Not caught: git aliases, scripts that run git, tools other than bash. It is a pattern match, not
  containment (pi docs/security.md: only an OS/VM boundary is a security boundary).

### Context budget

Counted 2026-09-17 with `tiktoken` `o200k_base` (OpenAI encoding — Anthropic publishes no local
tokenizer; treat as ±10 % for Claude): `AGENTS.md` 1752 tok, 3 skill metadata lines 148 tok. Since then
`AGENTS.md` gained the 12-line *Path rules* table and lost the omp lines — re-count `[UNVERIFIED]`.
Rule bodies (vault 476, changes 315, specs 273 tok) load on demand: path trigger in Claude, pointer in
pi. Skill bodies (vault-note 856, new-change 559, verify-repo 372 tok) on invoke.

## Invariants

- Exactly one canonical instruction file: `AGENTS.md`. Other agent files import it. Never a copy.
- Canonical rules and skills live in `.agents/`. Claude reaches them through **directory** symlinks;
  `scripts/check.sh` gate 10 fails on a copy, a wrong target, or a dangling link.
- Every rule in `.agents/rules/` has `description:` + `paths:` **and** a row in the `AGENTS.md` *Path
  rules* table — the table is pi's only route to it (gate 10).
- Skill frontmatter stays in the portable Agent Skills subset; `name` equals the directory (gate 10).
- `AGENTS.md` stays under 150 lines; every line answers yes to *would removing this cause a mistake?*
  Heuristic, not measurement.
- No rule contradicts another. Contradictions are resolved by deletion, not emphasis.
- A requirement that must hold deterministically is a **gate**, not prose: `git-guard.ts` for pi,
  `permissions.deny` for Claude Code. Context files are advisory.
- Agent-authored writes never land in the Obsidian vault unless the task names a vault path. Prose
  only, in both harnesses, by decision (0007): vault limits get gated only after a real failure.
- No harness other than pi and Claude Code gets config in this repo; omp and Codex config directories
  must not reappear (gate 12).

## Gaps

1. No user-level context file for either harness (`~/.claude/CLAUDE.md`, `~/.pi/agent/AGENTS.md`) →
   personal preferences are re-stated per project or lost.
2. ~~The vault write guard binds Claude Code only~~ — resolved 0007: guard removed, both harnesses
   equal (prose only).
3. Gates are asserted by **shape** in `scripts/check.sh` gate 11; that they fire was proven once by hand
   (0004, 0006). `BACKLOG 27`.
4. MCP set differs per agent and per project; the context7 key is plaintext (`SYSTEM.md` → Hygiene 1).
5. `~/.claude/commands/write-ticket.md` is 9.7 KB — should be a skill with a short body plus references.
6. No evals. Zero golden tasks, no regression suite for the rules, skills or contract.
7. Neither harness's own config is version-controlled (`~/.pi`, `~/.claude` both unmanaged).
8. `scripts/check.sh` does not check `[UNVERIFIED]` discipline, spec↔SYSTEM drift, or the freshness of
   a verified date.
9. Always-on budget was 1969 tok under omp vs 0004's ≤1200 target; not re-measured after 0006
   (`BACKLOG 33`).
10. pi follows rules only when the model honours the pointer table — advisory, unlike Claude's path
    trigger. A rule-loader extension was declined in 0006 (no plugin).
11. pi project trust is inherited from a broad ancestor entry (`/Users/luis/home/luis`) — every repo
    under it auto-loads its `.pi/extensions/`, including untrusted clones.
12. No mobile access to the agent stack. Research on the phone runs in the ChatGPT app; no pi instance
    is reachable from the iPhone, so phone research cannot use repo context or write into a repo.
