@AGENTS.md

## Claude Code specifics

Claude Code reads `CLAUDE.md`, not `AGENTS.md` (docs: code.claude.com/docs/en/memory#agentsmd).
This file exists only to import the canonical contract. Keep Claude-only content below, short.

- Use plan mode for anything touching `~/devSetup`, `~/.zshrc`, `~/.claude/`, or Karabiner.
  Those changes alter the live machine and are hard to unwind.
- `/context` after editing this file or `AGENTS.md`, to confirm what actually loaded.
- Path-scoped rules live in `.claude/rules/`; procedures in `.claude/skills/`. Put a fact in
  `AGENTS.md` only if it must be true in every session.
