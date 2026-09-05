# spec: agent-stack

Coding agents, their context files, and the shared instruction layer.

## Current

- Claude Code 2.1.236. `~/.claude/settings.json`: model `opus[1m]`, `effortLevel: medium`,
  `editorMode: vim`, `tui: fullscreen`, custom statusline, `autoMemoryEnabled: false`,
  plugin `pyright-lsp@claude-plugins-official`, 14 `permissions.allow` entries, `defaultMode: default`.
- Also installed: Codex (`~/.codex/config.toml`, one trusted project), opencode
  (`~/.config/opencode`, package.json only), omp (`~/.omp`), copilot-cli, pi-coding-agent, devin-desktop.
- Custom assets across all agents: **one** slash command, `~/.claude/commands/write-ticket.md`.
  Zero skills, zero subagents, zero hooks, no `~/.claude/CLAUDE.md`.
- MCP servers, fragmented: Claude global `n8n` (http); one Claude project `dbhub` (stdio);
  VS Code `context7` + `appwrite-docs` (`~/Library/Application Support/Code/User/mcp.json`,
  context7 key in plaintext).
- Account switching via `~/.local/bin/claude-swap` / `cswap`, aliased `cs`.

### Context-file resolution, verified

| Agent | Reads | Source |
| --- | --- | --- |
| Claude Code | `CLAUDE.md`, `.claude/CLAUDE.md`, `.claude/rules/*.md`. **Not** `AGENTS.md`. | code.claude.com/docs/en/memory#agentsmd |
| Codex | project `AGENTS.md`; user `~/.codex/AGENTS.md` | agents.md |
| opencode | `AGENTS.md`; user `~/.config/opencode/AGENTS.md` | agents.md |
| omp | standalone `AGENTS.md` (provider `agents-md`, priority 10) and `CLAUDE.md` (`claude-md`); at equal depth the higher-priority provider shadows the other | `omp://context-files.md` |
| Copilot | `.github/copilot-instructions.md`, `.github/instructions/**/*.instructions.md` | omp://context-files.md |

→ `AGENTS.md` canonical + `CLAUDE.md` containing `@AGENTS.md` is the only layout with no duplication
and no agent left out. A `CLAUDE.md` → `AGENTS.md` symlink also works but forbids Claude-only content.

## Invariants

- Exactly one canonical instruction file per repo: `AGENTS.md`. Other agent files import or symlink it.
- `AGENTS.md` stays under ~150 lines. Every line must answer yes to: *would removing this cause a
  mistake?* Bloated context files get ignored — Anthropic states this explicitly in the Claude Code
  best-practices guide.
- Three-tier context budget, per Anthropic's *Effective context engineering for AI agents* (2025-09-29):
  always-loaded facts → `AGENTS.md`; path-scoped rules → `.claude/rules/*.md` with `paths:` frontmatter;
  procedures and long reference → `.claude/skills/*/SKILL.md`, body loaded only on use.
- A rule that must hold deterministically is a **hook** or a permission rule, not prose. Context files
  are advisory; the model may ignore them.
- Agent-authored writes never land in the Obsidian vault. Deny rules in `.claude/settings.json` enforce it.

## Gaps

1. No user-level `~/.claude/CLAUDE.md` → personal preferences (concision, learning contract, vim)
   are re-stated per project or lost.
2. No skills anywhere → repeated procedures live in chat history, not on disk.
3. No hooks → no deterministic gate on anything.
4. MCP set differs per agent and per project; context7 key is plaintext.
5. `write-ticket.md` is 9.7 KB in `~/.claude/commands/` — a command that large should be a skill with
   a short body and reference files (progressive disclosure).
6. No verification loop for agents: no test/lint/build gate this repo can hand an agent as "the check".
   Anthropic's first best practice is *give Claude a way to verify its work*; documentation repos have
   no natural check, so one must be constructed (link check, spec/SYSTEM drift check).
7. No evals. Zero golden tasks, no regression suite for prompts or skills.
