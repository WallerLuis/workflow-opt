---
name: vault-note
description: Write a teaching or reference note in Obsidian vault format into notes/. Use when an explanation is long enough to belong in the vault, when the user asks to document a concept, or when a change produced knowledge worth keeping.
---

# vault-note

Notes go to `notes/` in this repo — **never** directly into the vault. Obsidian sees them through the
reverse symlink at `300 Resources - future/340 Workflow Documentation - Home lab/workflow-opt`. That
keeps every agent-authored note in git history, reviewable as a diff, and out of Syncthing's conflict path.

## Before writing

Read `901 Template/920 template permanent note.md` through the `vault/` symlink and copy the
frontmatter shape verbatim. Do not retype it from memory — the `Created` value has a non-obvious form.

## Convention (verified; full rules in `GLOSSARY.md`)

- Filename: full descriptive Title Case title, ` - ` between topic and facets, comma-separated keyword
  tail. Spaces and commas allowed. No dates, no numeric prefix, no kebab-case.
  Example: `Spec-Driven Development - Levels, Tools, Spec-Kit, OpenSpec, Kiro - DOC.md`
- H1 must equal the filename exactly (`filename-heading-sync` is installed).
- Frontmatter: 7 keys in order — `Created`, `Title`, `tags`, `Parent`, `Children`, `MOC`, `date`.
  `tags` is the single literal `"#note/"`. `MOC` points at the owning hub note.
- Body: `# <filename>` → `# Summary` → `# Notes` → optional `# TODO` → `# Links` → `# Sources`.
- Internal links: wikilink with **full vault-relative path plus alias** —
  `[[600 Knowledge/Software-IT - General/Agentic Development - Prompting/Context Engineering - Science, Fundamental|Context Engineering - Science, Fundamental]]`
- External links: markdown, or a `> [!info]` callout with the URL.
- German/English mixing is fine: German for personal/legal/lecture material, English for technical.
- Never emit `<% tp… %>` Templater syntax, and never copy the pre-2026 `Erstellt:`/`#para/` style.

## Content bar

Luis is learning the field top-to-bottom. A note earns its place only if it has:

1. the fundamental (why this exists, what problem class it solves),
2. the mechanism (how it actually works),
3. alternatives with pros/cons and the deciding tradeoff,
4. primary sources — papers, specs, official docs, named practitioners, with links,
5. wikilinks to the vault notes he already has on the topic (grep `vault/` first).

Register the note in the owning MOC by adding a wikilink line to the relevant `<Topic> MOC.md`
**as a suggestion in chat** — MOCs live in the vault and are write-denied.
