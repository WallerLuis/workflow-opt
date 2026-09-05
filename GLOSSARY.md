# GLOSSARY.md

Ubiquitous language for this repo (Evans, *Domain-Driven Design*, 2003, ch. 2). One term, one meaning.
Agents must use these words exactly; deviation means the model is guessing.

## Repo concepts

| Term | Meaning |
| --- | --- |
| **change** | One workflow modification, one file `changes/NNNN-slug.md`. Problem → baseline → options → decision → tasks → verification → outcome. Archived to `changes/archive/` when done. |
| **spec** | Steady-state description of one workflow domain: `specs/<domain>.md`. Holds verified current state + invariants + known gaps. Mutated by changes, never by guesswork. |
| **invariant** | A property that must stay true after any change. Violating one is a regression regardless of intent. |
| **baseline** | Measurement taken *before* a change. Startup ms, keystroke count, step count, failure rate. |
| **note** | Teaching artifact in `notes/`, written in vault format so Obsidian renders and links it. |
| **workflow-opt** | This repo. Decides and documents. |
| **devSetup** | `~/devSetup`, the dotfiles repo. Ships config to the machine. Separate repo on purpose. |

## Agent-harness concepts

| Term | Meaning | Cost |
| --- | --- | --- |
| **context file** | `AGENTS.md` / `CLAUDE.md`. Loaded at session start, every session. | always in context |
| **rule** | `.claude/rules/*.md`. Optional `paths:` frontmatter scopes it to matching files. | on match |
| **skill** | `.claude/skills/<name>/SKILL.md`, Agent Skills standard (agentskills.io). Frontmatter always visible, body loads on invocation. | on use |
| **subagent** | Isolated context window, own tool allowlist. Returns a condensed result. | isolated |
| **hook** | Shell script on a lifecycle event. Deterministic — unlike a context file, which is advisory. | zero context |
| **MCP** | Model Context Protocol server; exposes external tools/resources to an agent. | tool defs in context |
| **memory bank** | Cline's term for the always-relevant project context (≈ `AGENTS.md` + `SYSTEM.md` here). |
| **constitution** | spec-kit's term for immutable project principles (≈ the Working agreement in `AGENTS.md`). |
| **steering** | Kiro's term for the same layer (`product.md`/`tech.md`/`structure.md`). |

**SDD levels** (Böckeler, martinfowler.com, 2025-10-15): *spec-first* — spec written before code, then
discarded. *spec-anchored* — spec kept and evolved with the feature. *spec-as-source* — humans edit only
the spec. This repo is **spec-anchored** (`specs/` persist; `changes/` are transient).

## Vault vocabulary (observed conventions — do not invent new ones)

| Term | Meaning |
| --- | --- |
| **MOC** | Map of Content. Hub note named `<Topic> MOC.md` or `<Topic> - … MOC.md`. **The retrieval mechanism** in this vault — tags are not. |
| **DOC** | Personal documentation note, e.g. `Workflow MOC - Environment Development DOC.md`. |
| **PARA** | Folder numbering: `000 Index`, `100 Projects - now`, `200 Areas - longterm`, `300 Resources - future`, `400 Archive`. Forte, *Building a Second Brain*, 2022. Vault uses the shape; no method note exists. |
| **permanent note** | Zettelkasten-style atomic note. Template: `901 Template/920 template permanent note.md`. |

Vault note rules, verified:

- Filename = full descriptive title, Title Case, ` - ` separating topic from facets, comma-separated
  keyword tail. Example: `Docker - Best Practices, Fundamentals, Commands, CLI, Configuration.md`.
  Spaces and commas allowed. No dates, no numeric prefixes, no kebab-case.
- Numeric prefixes are for **folders and templates only**.
- H1 must equal the filename (`filename-heading-sync` plugin is installed).
- Body skeleton: `# <filename>` → `# Summary` → `# Notes` → optional `# TODO` → `# Links` → `# Sources`.
- Frontmatter: 7 keys, in order — `Created`, `Title`, `tags`, `Parent`, `Children`, `MOC`, `date`.
  `tags` is almost always the single literal `"#note/"`. **Copy the exact shape from
  `901 Template/920 template permanent note.md`; never retype it from memory.**
- Links: wikilinks with **full vault-relative path plus alias** —
  `[[600 Knowledge/…/Context Engineering - Science, Fundamental|Context Engineering - Science, Fundamental]]`.
  External links: standard markdown, often in a ```cardlink block or `> [!info]` callout.
- Attachments: sibling `attachments/` folder per topic, embedded with full path + size `|300`.
- German and English mix inside one note is normal: German for lectures/legal/personal, English for technical.
- Legacy notes (pre-2026) have no frontmatter and use `Erstellt:` + inline `#note #para/…`.
  Some still contain unrendered `<% tp… %>` Templater syntax. Do not propagate either style.
