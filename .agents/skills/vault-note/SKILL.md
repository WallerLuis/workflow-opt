---
name: vault-note
description: Write, reformat or split a note in the Obsidian vault. Use when an explanation is long enough to belong in the vault, when the user asks to document a concept, to reformat/split a note or a pasted section, or when a change produced knowledge worth keeping.
---

# vault-note

## Step 0 — read the standard

Read `vault/000 Index/Vault Conventions - Naming, Frontmatter, Links, MOC, Size, Sources - DOC.md`.
It is the single source for naming, frontmatter, linking, size, splitting and what agents may change.
Never rely on a remembered copy; the note evolves (see its `# Changelog`).

## Action: write a new note

1. Place by subject: grep `vault/` for siblings, put the note in their topical folder. Examples:
   tmux → `600 Knowledge/Software-IT - General/linux - Unix/`; prompting, agents →
   `600 Knowledge/Software-IT - General/Agentic Development - Prompting/`; macOS, Raycast, keyboard
   workflow → `300 Resources - future/340 Workflow Documentation - Home lab/`.
2. Copy frontmatter and skeleton from `901 Template/920 template permanent note.md` (MOC: `921`).
   Never retype from memory.
3. Set `Parent` to the nearest parent note. Add context links (link + 1–3 sentences) under `# Links`
   for sideways relations.
4. Content bar: fundamental → mechanism → alternatives with the deciding tradeoff → primary sources
   → links to notes Luis already has (grep first).

## Action: reformat `<note>#<section>` (only when asked)

Structure only, unless Luis's request adds content guidance:
- headings into the note's hierarchy (no H1 inside the body), markdown, code fences;
- full-path aliased links, `Parent` set, tracking params stripped;
- over the size limit → propose a split per the standard's *Splitting* table; split only after Luis
  confirms which shape.
Never delete or rewrite Luis's own text without being asked. Report every change.

## Afterwards

Vault files are outside git. State every vault path created or edited, in chat.
