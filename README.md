# workflow-opt

Repo of record for my working system on macOS: dev environment, agentic-coding setup, entrepreneurship
and reflection workflows. Documentation + decisions, not an application.

**Keyboard-first.** Modal editing everywhere — Karabiner/Neo2, tmux, Vimium in Brave, vim in Obsidian,
vim in VS Code, nvim as `$EDITOR`. Every mouse hand-off is a cost; changes are judged on keystrokes
removed, hand-offs removed, or failure modes removed.

Agents read `AGENTS.md`. Humans start here.

## Layout

```
AGENTS.md            agent contract — the one source of truth for agent behaviour
CLAUDE.md            @AGENTS.md + Claude-Code-only notes
SYSTEM.md            machine state: stack of record, retired tools, hygiene
GLOSSARY.md          ubiquitous language, keyboard vocabulary, Obsidian conventions
specs/               per-domain invariants and verified state (steady state)
changes/             one file per workflow change (the diff), BACKLOG.md ranks candidates
scripts/check.sh     the verification gate — 13 checks, exit 0 or fix it
.agents/rules/       path rules (Claude: auto via .claude/rules symlink · pi: pointer table in AGENTS.md)
.agents/skills/      agent procedures (pi native · Claude via .claude/skills symlink)
.claude/            Claude-only: settings.json deny rules (git), rules/skills symlinks
.pi/extensions/     pi-only: git-guard.ts — no commit, no push, no hard reset
vault -> ~/luis_obsidian_vault   symlink, gitignored, read-by-default
```

## Loop

1. Pick a candidate from `changes/BACKLOG.md`.
2. `cp changes/TEMPLATE.md changes/NNNN-slug.md`, fill Problem + Baseline.
3. Work it with an agent. Options → Decision → Tasks → Verification.
4. Fold durable facts into `specs/<domain>.md` and `SYSTEM.md`; run `scripts/check.sh`;
   `git mv` the change to `changes/archive/`.

Specs are the steady state. Changes are the diff. Neither is a wishlist — `BACKLOG.md` is.

## Stack

| Layer | Tool |
|---|---|
| Agent | pi, Claude Code CLI; Claude + Codex as providers |
| Keyboard | Karabiner-Elements + Neo2 layers |
| Terminal | Ghostty + tmux (resurrect/continuum, fingers, yank, open) |
| Editors | VS Code + VSCodeVim; nvim / vim as `$EDITOR` |
| Desktop | Brave + Vimium, Raycast, AltTab, Rectangle, Stats, Wispr Flow |
| Storage | Syncthing owns the Obsidian vault; Nextcloud (self-hosted) owns files |

Anything else on the machine is in `SYSTEM.md` → Retired, waiting to be uninstalled.

## Boundary with the Obsidian vault

The vault is the knowledge base. General knowledge — a tool, a concept, a technique — goes into its
**topical vault folder**, beside its siblings, under the owning MOC, because retrieval here is by MOC
link, not by tag. This repo holds decisions and machine state, not a second knowledge base.

## Boundary with `~/devSetup`

This repo **decides**. `~/devSetup` **ships** (Brewfile, symlinks, bootstrap). A change that alters
machine behaviour lands as a commit in `devSetup` and a filled-in Outcome section here.

## Setup on a new machine

```sh
ln -s ~/luis_obsidian_vault vault
ln -s "$PWD" "$HOME/luis_obsidian_vault/300 Resources - future/340 Workflow Documentation - Home lab/workflow-opt"
scripts/check.sh
```

First link lets agents read and search the vault from inside the repo. Second makes this repo's
markdown browsable and wikilinkable inside Obsidian. Third proves the repo is intact.
