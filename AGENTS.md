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
| `notes/` | teaching notes in Obsidian-vault format | on demand |
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

- `./vault` is a symlink to `/Users/luis/luis_obsidian_vault`. **Read-only.** Writes are denied by
  `.claude/settings.json`; do not attempt to bypass.
- Vault holds ~2240 notes. Never bulk-read. Grep for the specific note, read the section.
- Vault contains plaintext secrets (see `SYSTEM.md` → Hygiene). Never copy vault content into this
  repo without scanning for keys.
- Ignore `.trash/`, `.obsidian/`, `*.sync-conflict-*.md`, `Untitled*.md`.
- To write into the vault: put the note in `notes/`. Obsidian sees it through the reverse symlink at
  `300 Resources - future/340 Workflow Documentation - Home lab/workflow-opt`.

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

Long explanations belong in `notes/` (vault-visible), not in chat and not in this file.
