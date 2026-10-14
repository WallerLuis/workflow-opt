---
description: Reading from and writing into the Obsidian vault — retrieval by MOC, secret hazard, write conventions.
paths:
  - "vault/**"
---

# Working with the Obsidian vault

`vault/` is a symlink to `/Users/luis/luis_obsidian_vault` (~2240 notes). It is the knowledge base;
this repo is not a second one.

## Reading

- Never bulk-read. Grep for the note, then read the section. Just-in-time retrieval, not preloading.
- Skip `.trash/`, `.obsidian/`, `*.sync-conflict-*.md`, `Untitled*.md`, `.stfolder*`, `.DS_Store`.
- Retrieval is by MOC link, not by tag: the only tag in use is the literal `"#note/"`. To find a topic,
  grep the relevant `<Topic> MOC.md` and follow its wikilinks.
- Filenames and wikilinks contain spaces and commas — always quote paths.
- **The vault contains plaintext secrets** (`100 Projects - now/150 Own Projects-wishlist/AI agents/AI agents - MOC.md`,
  `Windows to linux switch.md`). Never copy vault content into this repo without scanning for keys.
  Never echo an apparent key into chat or a file.

## Writing

Default is read-only: do not write here unless the task calls for a vault note or the user names a
vault path. This repo keeps no notes directory — documentation about the repo itself belongs in
`AGENTS.md`, a spec, or a change file.

When you do write: read `vault/000 Index/Vault Conventions - Naming, Frontmatter, Links, MOC, Size,
Sources - DOC.md` first — it is the single source for note rules, including what agents may change.
Procedure: `vault-note` skill. Vault files are outside git — no diff, no undo; state every touched path.
