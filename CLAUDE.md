@AGENTS.md

## Claude Code specifics

Claude Code reads `CLAUDE.md`, not `AGENTS.md` (docs: code.claude.com/docs/en/memory#agentsmd). This
file exists to import the canonical contract. Keep Claude-only content below, short.

- Harnesses here: pi and Claude Code. Canonical files live in `.agents/`; Claude reaches them through
  directory symlinks — `.claude/rules -> ../.agents/rules`, `.claude/skills -> ../.agents/skills`.
  Edit the file in `.agents/`, never replace a symlink with a copy (`scripts/check.sh` fails on it).
- Claude-only assets: `.claude/settings.json` deny rules, `.claude/hooks/block-vault-writes.sh`, and
  the automatic `paths:` trigger on rules. pi gets the rules through the pointer table in `AGENTS.md`.
- Use plan mode for anything touching `~/devSetup`, `~/.zshrc`, `~/.claude/`, `~/.pi/`, or Karabiner.
  Those alter the live machine and are hard to unwind.
- `/context` after editing this file or `AGENTS.md`, to confirm what actually loaded.
- `@` imports expand at launch and are capped at 4 hops — keep chains ≤4.
