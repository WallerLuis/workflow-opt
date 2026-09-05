# spec: knowledge

Obsidian vault, its sync, and the linkage between vault and this repo.

## Current

- Vault: `~/luis_obsidian_vault`, ~2240 markdown notes. PARA-shaped numeric folders: `000 Index`,
  `100 Projects - now`, `200 Areas - longterm`, `300 Resources - future`, `400 Archive - archive`,
  `600 Knowledge`, `800 Daily Notes`, `901 Template` (16 templates), `950 Scripts`.
- Sync: **Syncthing** (`.stfolder/syncthing-folder-709f91.txt`). Redundant mechanisms also installed:
  `obsidian-git`, `obsidian-livesync`, `remotely-save`, `local-backup`.
- 60+ community plugins, incl. dataview, templater, tasks, periodic-notes, quickadd, excalidraw,
  latex-suite, vimrc-support, filename-heading-sync.
- Retrieval is by **MOC link**, not tag: the only tag in practice is the literal `"#note/"`.
- Note conventions: see `GLOSSARY.md` → Vault vocabulary. Template of record:
  `901 Template/920 template permanent note.md`.
- Existing agentic-coding cluster, `600 Knowledge/Software-IT - General/Agentic Development - Prompting/`:
  - `AI Vibe Agentic Coding - Best practices, Tools, Templates, Claude Code, Open Code.md` — 302 lines;
    Claude Code sessions, hardened deny-list, a CLAUDE.md collaboration block, MEMORY.md loading,
    Lucas Meijer's session-postmortem question, Matt Pocock failure modes, MCP list, opencode workflow.
  - `Context Engineering - Science, Fundamental.md` — 7 context pieces, cognitive memory taxonomy,
    Mem0/Cognee/Zep/Letta/Supermemory comparison, cites arXiv 2512.13564.
  - `Agentic Coding - AI Coding MOC.md` — hub; its SDD section is a 3-line stub naming
    OpenSpec/GSD/BMAD/Spec-Kit with no content.
  - `AI Personalisation - ChatGPT, Claude - Profiling, Template - DOC April 2026.md` — the current
    personal system prompt: evidence hierarchy (specs > peer-review > books > eng blogs), explanation
    order (foundations → mental model → implementation → example → workflow → tradeoffs), Socratic mode.
  - `Prompts/Prompt Templates - Often used Prompts.md` — 301 lines of reusable prompts.
- Workflow documentation folder `300 Resources - future/340 Workflow Documentation - Home lab/`:
  Raycast deep-dive (868 lines), macOS MOC (999 lines), Obsidian MOC (contains a "vault↔repo symlink"
  backlog item), Workflow MOC, Zettelkasten DOC (link-only), `DOCUMENTATION Home Lab.md` (empty).

### Repo ↔ vault linkage

- `workflow-opt/vault` → vault root. Read-only for agents; gitignored.
- Vault `300 Resources - future/340 Workflow Documentation - Home lab/workflow-opt` → repo root.
  Makes repo markdown browsable and wikilinkable inside Obsidian. Obsidian skips dot-directories,
  so `.git/` and `.claude/` stay invisible.
- Agent-authored notes go to `notes/` in the repo, never directly into the vault: version-controlled,
  reviewable in a diff, and immune to Syncthing conflict files.

## Invariants

- Agents never write inside `~/luis_obsidian_vault`. Enforced by deny rules, not by prose.
- Vault is never bulk-read into context. Grep for the note, read the section — just-in-time retrieval.
- New vault-facing notes match the observed convention exactly (filename, H1, 7-key frontmatter,
  full-path wikilinks). Copy the shape from `901 Template/920 template permanent note.md`.
- Nothing from the vault is copied into this repo without a secret scan first.
- Ignored patterns: `.trash/`, `.obsidian/`, `*.sync-conflict-*.md`, `Untitled*.md`, `.DS_Store`, `.stfolder*`.

## Gaps

1. Vault contains what appear to be **live API keys** in
   `100 Projects - now/150 Own Projects-wishlist/AI agents/AI agents - MOC.md`, and a Brave sync phrase
   in `Windows to linux switch.md`. Rotate + purge.
2. Four sync mechanisms installed for one vault → conflict surface. One must win.
3. `[UNVERIFIED]` whether Syncthing propagates the repo→vault symlink to other devices. Until verified,
   add the link path to `.stignore` before the vault syncs elsewhere.
4. Topic gaps in the vault relative to this repo's purpose: no spec-driven-development note, no
   TDD/verification-loop note, no evals note, no git-worktree/parallel-agent note, no dotfiles-as-repo
   note, no PARA/GTD/Zettelkasten method note, no Dataview/Templater usage doc.
5. Several notes still contain unrendered `<% tp… %>` Templater syntax.
6. `Prompt - Prompt Engineering MOC.md` links only into `.trash/` → broken.
