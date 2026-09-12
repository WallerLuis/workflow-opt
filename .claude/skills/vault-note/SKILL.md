---
name: vault-note
description: Write a teaching or reference note in Obsidian vault format. Use when an explanation is long enough to belong in the vault, when the user asks to document a concept, or when a change produced knowledge worth keeping.
---

# vault-note

## Step 1 — decide where it goes

Route by **subject, not authorship**:

| Subject | Location |
| --- | --- |
| General knowledge — a tool, a concept, a technique | the **topical vault folder**, beside its siblings, under the owning MOC |
| This repo's own system — its contract, structure, verification loop | `notes/` in this repo |

Find the topical folder by grepping `vault/` for existing notes on the subject, then place the new
note in the same directory. Examples: tmux → `600 Knowledge/Software-IT - General/linux - Unix/`;
prompting and agents → `600 Knowledge/Software-IT - General/Agentic Development - Prompting/`;
macOS and Raycast → `300 Resources - future/340 Workflow Documentation - Home lab/`.

A general note dropped into `notes/` is buried: no MOC points at that folder, so it is unfindable.

## Step 2 — copy the template

Read `901 Template/920 template permanent note.md` through the `vault/` symlink and copy the
frontmatter verbatim. Do not retype it from memory.

## Convention (verified; full rules in `GLOSSARY.md`)

- Filename: full descriptive Title Case title, ` - ` between topic and facets, comma-separated keyword
  tail. Spaces and commas allowed. No dates, no numeric prefix, no kebab-case.
  Example: `tmux Session Persistence - Client-Server Model, Reboot, Resurrect, Continuum, tmuxp - DOC.md`
- H1 must equal the filename exactly (`filename-heading-sync` is installed).
- Frontmatter: 7 keys in order — `Created`, `Title`, `tags`, `Parent`, `Children`, `MOC`, `date`.
  `tags` is the single literal `"#note/"`. `MOC` points at the owning hub note.
- Body: `# <filename>` → `# Summary` → `# Notes` → optional `# TODO` → `# Links` → `# Sources`.
- Internal links: wikilink with **full vault-relative path plus alias** —
  `[[600 Knowledge/Software-IT - General/linux - Unix/tmux - terminal multiplexer|tmux - terminal multiplexer]]`
- External links: markdown, or a `> [!info]` callout with the URL.
- German/English mixing is fine: German for personal/legal/lecture material, English for technical.
- Never emit `<% tp… %>` Templater syntax, and never copy the pre-2026 `Erstellt:`/`#para/` style.

## Step 3 — link it both ways

Retrieval in this vault is by MOC link, not by tag. An unlinked note does not exist.

- Add a wikilink to the new note under `# Links` in the closest related existing note **and** in the
  MOC named in the frontmatter.
- Link outward from the new note to the notes it builds on.
- Append only. Never restructure an existing note beyond the line you were asked to add.

## Content bar

Luis is learning the field top-to-bottom. A note earns its place only if it has:

1. the fundamental (why this exists, what problem class it solves),
2. the mechanism (how it actually works),
3. alternatives with pros/cons and the deciding tradeoff,
4. primary sources — papers, specs, official docs, named practitioners, with links,
5. wikilinks to the vault notes he already has on the topic (grep `vault/` first).

## Afterwards

Vault files are outside git. State every vault path you created or edited, explicitly, in chat.
