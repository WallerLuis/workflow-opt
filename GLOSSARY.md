# GLOSSARY.md

Ubiquitous language for this repo (Evans, *Domain-Driven Design*, 2003, ch. 2). One term, one meaning.
Agents use these words exactly; deviation means the model is guessing.

## Repo concepts

| Term | Meaning |
|---|---|
| **change** | One workflow modification, one file `changes/NNNN-slug.md`: problem → baseline → options → decision → tasks → verification → outcome. Archived to `changes/archive/` when done. Numbers are monotonic and never reused. |
| **spec** | Steady-state description of one workflow domain, `specs/<domain>.md`: verified current state + invariants + gaps. Mutated by a completed change, never by guesswork. |
| **invariant** | A property that must stay true after any change. Violating one is a regression regardless of intent. |
| **gap** | A known defect or missing capability, recorded in a spec without a solution. Closed by striking it through with a date, never by deletion or renumbering — backlog rows reference `<spec>#<number>`. |
| **baseline** | Measurement taken *before* a change: keystrokes, mouse hand-offs, startup ms, step count, failure rate. |
| **note** | A note in the **Obsidian vault**, in vault format, under its owning MOC. This repo keeps no notes directory; explanation-mode writing goes to the vault. |
| **workflow-opt** | This repo. Decides and documents. |
| **devSetup** | `~/devSetup`, the dotfiles repo. Ships config to the machine. Separate repo on purpose. |
| **gate** | A deterministic check or denial: `scripts/check.sh`, `bash.patterns`, `permissions.deny`, a hook. Distinct from a rule, which is advisory. |

## Keyboard-first vocabulary

| Term | Meaning |
|---|---|
| **keyboard-first** | The north star: modal editing everywhere, hands on the home row, every mouse hand-off treated as a cost to be removed. |
| **layer** | One binding engine in the stack: L0 HID remap (Karabiner) · L1 global hotkeys · L2 window/workspace · L3 app chrome · L4 in-app modal engine · L5 dictation. Lower layers consume events first. |
| **modal surface** | A place where normal/insert modes exist: nvim, VSCodeVim, Vimium, Obsidian vim, tmux copy-mode. |
| **collision** | Two layers claiming the same physical key in the same context. The lower layer wins; the upper binding silently dies. Collisions are listed in `specs/keyboard.md`. |
| **hand-off** | Moving a hand from the keyboard to the mouse or trackpad. The `H` operator of the keystroke-level model, ≈ 0.40 s, and the quantity keyboard-first work exists to reduce. |
| **KLM** | Keystroke-level model (Card, Moran & Newell, CACM 1980): operators `K` keystroke 0.12–0.20 s, `P` point, `H` homing, `M` mental 1.35 s, `R` response. ~21 % RMS error; assumes expert, error-free execution. The legitimate way to estimate a keystroke saving — report *per occurrence × frequency*, never "X % faster". |

## Agent-harness concepts

| Term | Meaning | Cost |
|---|---|---|
| **context file** | `AGENTS.md` (pi, native) / `CLAUDE.md` (Claude Code, imports it). Loaded at session start, every session. | always in context |
| **rule** | A markdown file in `.agents/rules/` with `description:` + `paths:`. Claude Code auto-loads it on a path match through the `.claude/rules` symlink; pi has no rule mechanism and reaches it through the *Path rules* table in `AGENTS.md`. | Claude: on match · pi: on read |
| **extension** | pi's TypeScript plugin unit (`.pi/extensions/*.ts`). A `tool_call` handler returning `{ block: true }` stops a call before it runs — pi's only deterministic gate. | zero context |
| **skill** | `.agents/skills/<name>/SKILL.md`, Agent Skills standard (agentskills.io). Frontmatter always visible, body loads on invocation. pi native; Claude via the `.claude/skills` symlink. | on use |
| **subagent** | Isolated context window, own tool allowlist, returns a condensed result. | isolated |
| **hook** | Program on a lifecycle event. Deterministic — unlike a context file, which is advisory. In Claude Code only exit code **2** blocks. | zero context |
| **MCP** | Model Context Protocol server; exposes external tools/resources to an agent. | tool defs in context |
| **progressive disclosure** | Metadata always visible, body on demand, resources fetched only when needed. The mechanism behind rules and skills. | — |

Field vocabulary, for reading other people's setups: **memory bank** (Cline's always-relevant project
context, six files) · **constitution** (spec-kit's immutable project principles) · **steering** (Kiro's
`product.md`/`tech.md`/`structure.md`) · **rulebook / TTSR** (omp's glob- and trigger-fired rules; omp is
retired here) · **Project Rules** (Cursor `.mdc`) · **path-specific custom instructions** (Copilot `applyTo:`).

**SDD levels** (Böckeler, martinfowler.com, 2025-10-15): a spec written then discarded; *spec-anchored* —
spec kept and evolved with the change; *spec-as-source* — humans edit only the spec. This repo is
**spec-anchored**: `specs/` persist, `changes/` are transient.

## Vault vocabulary (observed conventions — do not invent new ones)

| Term | Meaning |
|---|---|
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
- German and English mix inside one note is normal: German for lectures/legal/personal, English for
  technical.
- Legacy notes (pre-2026) have no frontmatter and use `Erstellt:` + inline `#note #para/…`.
  Some still contain unrendered `<% tp… %>` Templater syntax. Do not propagate either style.

Repo file naming: `kebab-case.md` inside `specs/` and `changes/`; the root contract files
(`AGENTS.md`, `CLAUDE.md`, `README.md`, `SYSTEM.md`, `GLOSSARY.md`) and the fixed-name files
(`SKILL.md`, `TEMPLATE.md`, `BACKLOG.md`) keep their upper-case conventional names.
