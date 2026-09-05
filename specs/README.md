# specs/

Steady state, one file per workflow domain. Read on demand, never auto-loaded.

Each spec has exactly three sections:

- **Current** — verified facts. Every line traceable to a file, command output, or session observation.
  Unverified claims carry `[UNVERIFIED]`.
- **Invariants** — properties that must stay true after any change. A change that breaks one is a
  regression, whatever its intent.
- **Gaps** — known defects and missing capability. Each gap is a candidate for `changes/BACKLOG.md`.
  Gaps are *not* decisions: no chosen solution lives here until a change lands.

Specs are mutated only by a completed change. Never edit a spec to describe a plan.

`SYSTEM.md` is the machine-wide snapshot; specs are the per-domain deep view. When they disagree,
re-verify against the machine and fix both.

## Domains

| Spec | Covers |
| --- | --- |
| `agent-stack.md` | Claude Code, Codex, opencode, omp; context files, rules, skills, MCP |
| `shell.md` | zsh, prompt, aliases, toolchain managers |
| `terminal.md` | terminal emulators, tmux, session persistence |
| `knowledge.md` | Obsidian vault, sync, note conventions, repo↔vault linkage |
| `dotfiles.md` | `~/devSetup`, reproducibility, secrets |

Add a domain only when a change needs one. Empty specs are noise.
