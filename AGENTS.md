# AGENTS.md — workflow-opt

Canonical agent contract. Every agent (Claude Code, Codex, opencode, omp, Copilot) reads this file.
`CLAUDE.md` imports it. Do not duplicate content into other agent files.

## Purpose

Repo of record for Luis's personal working system on macOS: dev environment, agentic-coding setup,
entrepreneurship and reflection workflows. Unit of work is a **workflow change**, not a feature.
Artifacts here are documentation + config + scripts. There is no application to build.

## Repo map

| Path | Role (Diátaxis) | Loaded when |
| --- | --- | --- |
| `AGENTS.md` | agent contract | every session |
| `CLAUDE.md` | `@AGENTS.md` + Claude-only notes | every Claude session |
| `SYSTEM.md` | reference: current machine state, verified | on demand |
| `GLOSSARY.md` | ubiquitous language, naming rules | on demand |
| `specs/` | reference: per-domain invariants + verified current state | on demand |
| `changes/` | decision log: one file per workflow change | on demand |
| `changes/BACKLOG.md` | ranked candidate changes | on demand |
| `notes/` | explanation: notes about **this repo's own system** only | on demand |
| `.claude/rules/` | path-scoped rules | when touching matching paths |
| `.claude/skills/` | procedures | when invoked / relevant |
| `vault` | read-only symlink → Obsidian vault (gitignored) | never auto |

## Working agreement — spec-first, one file per change

1. **Problem** — observed symptom, with evidence (command output, file path, timing). No hypotheticals.
2. **Baseline** — measure before changing. Startup ms, keystrokes, steps, failure rate. Unmeasurable → say so.
3. **Options** — ≥2 real alternatives, pros/cons, one recommendation. Cite sources.
4. **Decision** — chosen option + why the others lost.
5. **Tasks** — ordered, each independently verifiable.
6. **Verification** — the exact command or observation that proves it works.
7. **Outcome** — filled in after execution: measured delta, what surprised us.

Live changes in `changes/NNNN-slug.md` (template: `changes/TEMPLATE.md`).
On completion: fold durable facts into the matching `specs/*.md`, then `git mv` the change file to
`changes/archive/`. Specs are the steady state; changes are the diff.

Skip the change file only for typo/format fixes. Anything that alters machine behaviour gets one.

## Conventions

- Markdown, ATX headers, no trailing whitespace. Filenames: `kebab-case.md` in the repo.
  Vault-facing files in `notes/` follow vault naming instead (see `GLOSSARY.md`).
- Changes numbered zero-padded 4 digits, monotonic, never reused.
- Config that touches the machine belongs in `~/devSetup` (the dotfiles repo), not here.
  This repo documents and decides; `devSetup` ships. Cross-reference by path.
- Every claim about the machine is either verified in-session or marked `[UNVERIFIED]`.
- Never invent a measurement. Absent baseline → write `baseline: not measured`.

## Verification rules

- Documentation change → re-read the file, confirm links resolve.
- Config/script change → run it, paste real output.
- Claim about installed tooling → `brew list`, `--version`, or read the config file. Not memory.
- Never report a workflow as improved without a before/after number or an explicit "unmeasurable, judged by X".

## Obsidian vault access

`./vault` is a symlink to `/Users/luis/luis_obsidian_vault`. The vault is the home of Luis's
knowledge; this repo is not a second knowledge base.

- Vault holds ~2240 notes. Never bulk-read. Grep for the specific note, read the section.
- Vault contains plaintext secrets (see `SYSTEM.md` → Hygiene). Never copy vault content into this
  repo without scanning for keys.
- Ignore `.trash/`, `.obsidian/`, `*.sync-conflict-*.md`, `Untitled*.md`.

### Where a note goes

| Subject | Location |
| --- | --- |
| General knowledge — a tool, a concept, a technique | the **topical vault folder**, next to its siblings, under the owning MOC. e.g. tmux → `600 Knowledge/Software-IT - General/linux - Unix/` |
| This repo's own system — its contract, its structure, its verification | `notes/` in this repo |

Rule: a note goes where its readers look for it. Topic first, not authorship. Writing a general
knowledge note into `notes/` buries it in a folder no MOC points at.

### Writing into the vault

- Match the observed convention exactly — filename, H1, 7-key frontmatter, full-path wikilinks.
  Copy the shape from `901 Template/920 template permanent note.md`; see `GLOSSARY.md`.
- Register the note in its owning MOC by adding a wikilink; an unlinked note is unfindable here,
  because retrieval is by MOC, not by tag.
- Never rewrite or restructure an existing note beyond the edit you were asked for.
- Vault files are outside git. State clearly in chat which vault paths you wrote.

## Output style

- Extremely concise. Fragments over sentences. No preamble, no summary of what you just did.
- Conclusion first, then evidence. Exact paths, commands, numbers.
- Uncertainty stated at the claim, not in a disclaimer paragraph.

## Learning contract

Luis is learning the field top-to-bottom. For any non-trivial recommendation:

- Name every viable approach, not just the chosen one.
- Give pros/cons and the tradeoff axis that decides it.
- Anchor to primary sources: papers, specs, official docs, named practitioners. Link them.
- Link to what he already knows: grep `./vault` for the relevant note and cite its path.
- Teach the fundamental, then the mechanism, then the implementation. Never only the command.

Long explanations belong in a note, not in chat and not in this file. General topic → topical vault
folder. About this repo → `notes/`.
