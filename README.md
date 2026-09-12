# workflow-opt

Repo of record for my working system on macOS: dev environment, agentic-coding setup, entrepreneurship
and reflection workflows. Documentation + decisions, not an application.

Agents read `AGENTS.md`. Humans start here.

## Layout

```
AGENTS.md            agent contract — the one source of truth for agent behaviour
CLAUDE.md            @AGENTS.md + Claude-specific notes
SYSTEM.md            verified current state of the machine
GLOSSARY.md          ubiquitous language + Obsidian vault conventions
specs/               per-domain invariants and verified state (steady state)
changes/             one file per workflow change (the diff), BACKLOG.md ranks candidates
notes/               notes about this repo's own system (general knowledge goes in the vault)
.claude/rules/       path-scoped agent rules
.claude/skills/      agent procedures
vault -> ~/luis_obsidian_vault   symlink, gitignored, read-by-default
```

## Loop

1. Pick a candidate from `changes/BACKLOG.md`.
2. `cp changes/TEMPLATE.md changes/NNNN-slug.md`, fill Problem + Baseline.
3. Work it with an agent. Options → Decision → Tasks → Verification.
4. Fold durable facts into `specs/<domain>.md` and `SYSTEM.md`; `git mv` the change to `changes/archive/`.

Specs are the steady state. Changes are the diff. Neither is a wishlist — `BACKLOG.md` is.

## Boundary with the Obsidian vault

The vault is the knowledge base. General knowledge — a tool, a concept, a technique — goes into its
**topical vault folder**, beside its siblings, under the owning MOC. Only notes about this repo's own
system live in `notes/`. Routing is by subject, not by who wrote the note.

## Boundary with `~/devSetup`

This repo **decides**. `~/devSetup` **ships** (Brewfile, symlinks, bootstrap). A change that alters
machine behaviour lands as a commit in `devSetup` and a filled-in Outcome section here.

## Setup on a new machine

```sh
ln -s ~/luis_obsidian_vault vault
ln -s "$PWD" "$HOME/luis_obsidian_vault/300 Resources - future/340 Workflow Documentation - Home lab/workflow-opt"
```

First link lets agents read and search the vault from inside the repo. Second makes this repo's
markdown browsable and wikilinkable inside Obsidian.
