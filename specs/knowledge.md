# spec: knowledge

Obsidian vault, its sync, and the linkage between vault and this repo.

## Current

- Vault: `~/luis_obsidian_vault`, ~2000 markdown notes, 8.9 MB (2026-10-13). PARA-shaped numeric
  folders: `000 Index`, `100 Projects - now`, `200 Areas - longterm`, `300 Resources - future`,
  `400 Archive - archive`, `600 Knowledge`, `800 Daily Notes`, `901 Template`, `950 Scripts`.
- Sync: **Syncthing** owns the vault (`.stfolder/syncthing-folder-709f91.txt`). Decided 2026-09-17:
  Syncthing owns the vault, Nextcloud owns files; the two never manage the same tree.
  Retired, still installed: `obsidian-git`, `obsidian-livesync`, `remotely-save`, `local-backup`.
- 60+ community plugins, incl. dataview, templater, tasks, periodic-notes, quickadd, excalidraw,
  latex-suite, vimrc-support, filename-heading-sync.
- Note conventions: single source `000 Index/Vault Conventions - Naming, Frontmatter, Links, MOC, Size,
  Sources - DOC.md` (0008), with MUST/SHOULD levels and a `# Changelog`. Vault-root `AGENTS.md` points
  to it (pi, cwd in vault); `CLAUDE.md` = `@AGENTS.md`. Repo files hold pointers only.
- Hierarchy: frontmatter `Parent` = one link to the nearest parent; chain ends at a MOC. Children via
  Dataview `## Children` block under `# Links` (templates `920`, `921`); `warnOnEmptyResult` off.
  Migrated 2026-10-14 by `scripts/vault-frontmatter-migrate.py`: 1082 notes, 7 → 5 keys (daily notes
  `date, type, tags, Parent`), 1093 notes now carry `Parent`. Backup of originals:
  `~/vault-backups/vault-md-20261014-161828.tar.gz`.
- Agentic-coding notes: `600 Knowledge/Software-IT - General/Agentic Development - Prompting/`
  (hub `Agentic Coding - AI Coding MOC.md`; personal prompt in `AI Personalisation - … DOC April 2026.md`).
- Workflow documentation: `300 Resources - future/340 Workflow Documentation - Home lab/`
  (Workflow MOC, Note Taking MOC, Obsidian MOC, macOS MOC, Raycast).

### Repo ↔ vault linkage

- `workflow-opt/vault` → vault root. Read-only for agents; gitignored.
- Vault `300 Resources - future/340 Workflow Documentation - Home lab/workflow-opt` → repo root.
  Makes repo markdown browsable and wikilinkable inside Obsidian. Obsidian skips dot-directories,
  so `.git/`, `.claude/`, `.agents/` and `.pi/` stay invisible.
- Notes are routed by **subject, not authorship**: general knowledge (a tool, a concept, a technique)
  goes into its topical vault folder next to its siblings, under the owning MOC. The repo keeps no
  second knowledge base — `notes/` was removed 2026-09-17; explanation-mode content lives in the vault.

## Invariants

- Agents never write inside `~/luis_obsidian_vault` **unless explicitly asked for that path**.
  Prose only, both harnesses (`AGENTS.md`, `.agents/rules/vault.md`). The Claude deny rule + hook were
  removed in 0007 so Claude can reformat notes; limits get gated only after an observed failure.
- A note written into the vault gets `Parent` in the same action; retrieval is by the `Parent` chain
  to a MOC, not by tag. A note without `Parent` is unfindable.
- Vault files are outside git. Any vault write is stated explicitly in chat, with the path.
- Vault is never bulk-read into context. Grep for the note, read the section — just-in-time retrieval.
- New vault-facing notes follow the conventions note in `000 Index`; no copy of its rules elsewhere.
- Nothing from the vault is copied into this repo without a secret scan first.
- Ignored patterns: `.trash/`, `.obsidian/`, `*.sync-conflict-*.md`, `Untitled*.md`, `.DS_Store`, `.stfolder*`.

## Gaps

1. Vault contains what appear to be **live API keys** in
   `100 Projects - now/150 Own Projects-wishlist/AI agents/AI agents - MOC.md`, and a Brave sync phrase
   in `Windows to linux switch.md`. Rotate + purge.
2. ~~Four sync mechanisms installed for one vault~~ — decided 2026-09-17: Syncthing wins. Still open:
   the four redundant plugins are installed and must be disabled (`SYSTEM.md` → Retired).
3. `[UNVERIFIED]` whether Syncthing propagates the repo→vault symlink to other devices. Until verified,
   add the link path to `.stignore` before the vault syncs elsewhere.
4. Topic gaps in the vault relative to this repo's purpose: no spec-driven-development note, no
   TDD/verification-loop note, no evals note, no git-worktree/parallel-agent note, no dotfiles-as-repo
   note, no PARA/GTD/Zettelkasten method note, no Dataview/Templater usage doc.
5. Several notes still contain unrendered `<% tp… %>` Templater syntax.
6. `Prompt - Prompt Engineering MOC.md` links only into `.trash/` → broken.
7. ~~The vault write guard binds Claude Code only~~ — resolved 0007: guard removed in Claude, both
   harnesses prose-only. A future hard guard would be filesystem permissions, not agent config.
8. The second brain's own structure — PARA folder semantics, capture paths, daily-note and template
   flow, MOC registration discipline, plugin roles — is not documented anywhere. Deferred to its own
   session: a dedicated spec plus a vault explanation note (`changes/BACKLOG.md`).
9. ~~Vault conventions have no single source~~ — resolved 0008: 6 places → 1 (`000 Index`).
10. Legacy leftovers after 0008 (2026-10-14): 12 notes with body-level inline fields (`MOC::`,
    `Children:`) from an old template; 27 old daily notes link `[[Daily Notes]]` in their nav bar
    (unresolved); 41 `<% tp`; 89 notes > 400 lines / 66 > 20k chars. No lint script yet.
11. Hierarchy coverage (2026-10-14, 1502 non-daily notes): `Parent` filled in 106; of 1396 without,
    283 are linked from exactly 1 MOC, 44 from > 1, **1069 from none** — unreachable by MOC/`Parent`.
12. Agents retrieve by grep only; Obsidian's own index (search, backlinks, properties) is unused.
    `obsidian` CLI is on PATH (`obsidian --help` → "Obsidian CLI"); capabilities `[UNVERIFIED]`.
13. Capture inbox `900 Quick Note`: 57 notes, no processing routine.
14. 280 notes have an empty `# Summary`; agents cannot read summary-first.
15. No retrieval-practice loop: `flashcards-obsidian` + template `945` installed, use `[UNVERIFIED]`.
16. No session → vault distill step (`<VAULT>` mode in the Workflow MOC is unbuilt).
