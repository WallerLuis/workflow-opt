---
paths:
  - "vault/**"
---

# Reading the Obsidian vault

`vault/` is a read-only symlink to `/Users/luis/luis_obsidian_vault` (~2240 notes). Writes are denied
in `.claude/settings.json`; do not attempt to work around it.

- Never bulk-read. Grep for the note, then read the section. Just-in-time retrieval, not preloading.
- Skip `.trash/`, `.obsidian/`, `*.sync-conflict-*.md`, `Untitled*.md`, `.stfolder*`, `.DS_Store`.
- Retrieval is by MOC link, not by tag: the only tag in use is the literal `"#note/"`. To find a topic,
  grep the relevant `<Topic> MOC.md` and follow its wikilinks.
- Filenames and wikilinks contain spaces and commas — always quote paths.
- **The vault contains plaintext secrets** (`100 Projects - now/150 Own Projects-wishlist/AI agents/AI agents - MOC.md`,
  `Windows to linux switch.md`). Never copy vault content into this repo without scanning for keys.
  Never echo an apparent key into chat or a file.
- To create a note: write it into `notes/` in this repo. Obsidian sees it through the reverse symlink.
