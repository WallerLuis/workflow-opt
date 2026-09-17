# spec: agent-stack

The coding agents, their instruction layer, and the gates that bind them.

## Current

Verified 2026-09-17.

- **omp** is the primary harness. `~/.omp/agent/config.yml` (545 B): `tools.approvalMode: write`
  (read auto-approved, write auto-approved, **exec prompts**), `modelRoles.default:
  anthropic/claude-opus-5`, `steeringMode: one-at-a-time`, `vault.enabled: true`, `theme.dark: titanium`,
  `symbolPreset: nerd`, a 24-entry `providers.webSearchOrder`. No `~/.omp/agent/keybindings.yml` → TUI
  defaults; `Ctrl+G` (`app.editor.external`) hands the prompt draft to `$VISUAL`.
- **Claude Code CLI 2.1.236** is the secondary harness. `~/.claude/settings.json`: model `opus[1m]`,
  `effortLevel: medium`, `editorMode: vim`, `tui: fullscreen`, custom statusline,
  `autoMemoryEnabled: false`, plugin `pyright-lsp`, 14 `permissions.allow` entries.
- Model providers: Claude (`anthropic`) and Codex (`openai`).
- Repo assets: `AGENTS.md` (canonical), `CLAUDE.md` (`@AGENTS.md`), three rules, three skills, one
  `PreToolUse` hook (`.claude/hooks/block-vault-writes.sh`, 52 B lines, mode `-rwxr-xr-x`), one
  verification script.
- Machine-wide custom assets outside this repo: one slash command,
  `~/.claude/commands/write-ticket.md` (9.7 KB). No user-level `~/.claude/CLAUDE.md`, no
  `~/.omp/agent/AGENTS.md`.
- Account switching: `~/.local/bin/claude-swap` / `cswap`, aliased `cs`.

### What each harness actually loads — verified, not assumed

| Asset | omp | Claude Code CLI |
|---|---|---|
| root `AGENTS.md` | ✅ native (`agents-md` provider, priority 10). This session injected it as the **sole** `<file>` in `<repo-rules>` | ✗ — "Claude Code reads `CLAUDE.md`, not `AGENTS.md`" (code.claude.com/docs/en/memory#agentsmd) |
| `CLAUDE.md` | shadowed at depth 0 by `AGENTS.md`; Claude-only lines invisible | ✅ with `@AGENTS.md` expanded at launch (≤4 import hops) |
| `.claude/rules/*.md` | ✗ — rule providers are `native .omp/rules/`, `agents`, `cursor`, `windsurf`, `cline`, `github` (`omp://rulebook-matching-pipeline.md` §2). Proven: `read rule://vault` → `Unknown rule` | ✅ recursively, `paths:` globs, fires when a matching file is read |
| `.omp/rules/*.md` (symlinks to the same files) | ✅ `globs:` + `description:`; body on demand via `rule://<name>` | ✗ |
| `.claude/skills/*/SKILL.md` | ✅ `claude` provider, priority 80 — metadata at startup, body on invoke | ✅ |
| `.claude/settings.json` deny rules + `PreToolUse` hook | ✗ | ✅ (`Edit(path)` rules only; `Write(...)` entries are inert) |
| `.omp/RULES.md` | ✅ forced always-apply, re-attached near the current turn | ✗ |
| `.omp/config.yml` (`bash.patterns`, `tools.approval.*`) | ✅ `deny` absolute in every mode | ✗ |

→ One canonical `AGENTS.md`; `CLAUDE.md` imports it; rules carry **both** `paths:` (Claude) and
`globs:` + `description:` (omp) in one physical file, mounted into `.omp/rules/` by symlink; skills need
no duplication. Import-depth invariant: ≤4 hops (Claude Code's cap; omp allows 5).

### Context budget, measured 2026-09-17

| Surface | Cost |
|---|---|
| omp always-on (`AGENTS.md` + skill metadata) | ~1.3k tok |
| rules | name + description only until `rule://` is read |
| `specs/` + `changes/` | 16k tok, never auto-loaded |

## Invariants

- Exactly one canonical instruction file: `AGENTS.md`. Other agent files import, symlink, or add keys
  to the same physical file. Never a copy.
- `AGENTS.md` stays under 150 lines, and every line answers yes to *would removing this cause a
  mistake?* (Claude Code memory docs: "target under 200 lines… Longer files consume more context and
  reduce adherence"; Anthropic, *Effective context engineering*, 2025-09-29: smallest set of high-signal
  tokens.) The number is a heuristic, not a measurement — no public benchmark ties instruction-file
  length to task success.
- Three tiers: always-loaded facts → `AGENTS.md`; path-scoped rules → rule files with both frontmatter
  dialects; procedures and long reference → skills, body on demand.
- No rule text may contradict another rule. Contradictions are resolved by deletion, not by emphasis
  (OpenAI GPT-5 prompting guide, 2025-08: contradictory instructions burn reasoning tokens).
- A requirement that must hold deterministically is a **gate**, not prose: `bash.patterns` /
  `tools.approval` for omp, `permissions.deny` + `PreToolUse` for Claude Code. Context files are advisory.
- Agent-authored writes never land in the Obsidian vault unless the task names a vault path.
- Instructions that only one harness loads are labelled with that harness here.

## Gaps

1. No user-level context file for either harness (`~/.claude/CLAUDE.md`, `~/.omp/agent/AGENTS.md`) →
   personal preferences are re-stated per project or lost.
2. The vault write guard binds Claude Code only; omp, and any other tool, read neither the deny rules
   nor the hook. Verified 2026-09-10: an omp session wrote to the vault unblocked.
3. `check.sh` never asserts that the hook exists or is executable. A hook that cannot start is a
   **non-blocking** error in Claude Code (only exit 2 blocks) → the only deterministic guard can fail
   silently.
4. MCP set differs per agent and per project; the context7 key is plaintext (`SYSTEM.md` → Hygiene 1).
5. `~/.claude/commands/write-ticket.md` is 9.7 KB — a command that large should be a skill with a short
   body plus reference files (progressive disclosure).
6. No evals. Zero golden tasks, no regression suite for the rules, skills or contract.
7. Neither harness's own config is version-controlled (`~/.omp`, `~/.claude` both unmanaged).
8. `scripts/check.sh` checks structure, links, secrets and symlinks, but not terminology consistency,
   `[UNVERIFIED]` discipline, spec↔SYSTEM drift, or the freshness of a verified date.
