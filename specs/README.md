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

`SYSTEM.md` is the machine-wide snapshot — stack of record, retired tools, hygiene. Specs are the
per-domain deep view. When they disagree, re-verify against the machine and fix both in one edit.

Closing a gap: strike it through with a date (`~~gap~~ — closed YYYY-MM-DD: evidence`). Never delete or
renumber — backlog rows reference `<spec>#<number>`.

## Domains

| Spec | Covers |
|---|---|
| `keyboard.md` | Karabiner/Neo2, tmux keys, Vimium, Obsidian vim, VS Code vim, cross-tool collisions |
| `terminal.md` | Ghostty, tmux, session persistence |
| `editor.md` | VS Code, Neovim, vim, the modal engine inside each |
| `desktop.md` | Brave, Raycast, AltTab, Rectangle, Stats, Wispr Flow, Nextcloud |
| `nextcloud.md` | Nextcloud file structure, naming, vault reference contract |
| `agent-stack.md` | pi + Claude Code CLI, instruction layer, gates, context budget |
| `knowledge.md` | Obsidian vault, sync, note conventions, repo↔vault linkage |
| `shell.md` | zsh, prompt, aliases, toolchain managers |
| `dotfiles.md` | `~/devSetup`, reproducibility, secrets |
| `homeserver.md` | Proxmox (HA VM, Docker VM), Unraid, containers, ingress; backlog `changes/HOMESERVER-BACKLOG.md` |

Add a domain only when a change needs one. Empty specs are noise.
