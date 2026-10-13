# AGENTS.md — workflow-opt

Canonical agent contract. pi loads this file natively; `CLAUDE.md` imports it for the Claude Code CLI.
Never duplicate content into another agent file — copy-drift appeared here within five days once
already (`changes/archive/0001-*`, Outcome 3).

## Purpose

Repo of record for Luis's working system on macOS: dev environment, agentic-coding setup,
entrepreneurship and reflection workflows. Documentation + decisions; no application to build.

**North star: keyboard-first.** Modal editing everywhere, hands on the home row, every mouse hand-off
treated as a cost. A change earns its place by removing keystrokes, removing hand-offs, or removing a
failure mode — stated as a number, not a feeling.

Unit of work is a **workflow change**, not a feature.

## Stack of record

| Layer | Tool | Spec |
|---|---|---|
| Agent harness | **pi** (`pi-coding-agent`), Claude Code CLI | `specs/agent-stack.md` |
| Model providers | Claude (`anthropic`), Codex (`openai`) | `specs/agent-stack.md` |
| Keyboard | Karabiner + Neo2 layers, tmux keys, Vimium, Obsidian vim, VSCodeVim | `specs/keyboard.md` |
| Terminal | Ghostty + tmux (resurrect/continuum) | `specs/terminal.md` |
| Editors | VS Code + VSCodeVim; nvim / vim as `$EDITOR` | `specs/editor.md` |
| Desktop | Brave + Vimium, Raycast, AltTab, Rectangle, Stats, Wispr Flow, Nextcloud | `specs/desktop.md` |
| Second brain | Obsidian vault, Syncthing-synced | `specs/knowledge.md` |
| Shell | zsh + devSetup symlinks | `specs/shell.md` |
| Dotfiles | `~/devSetup` | `specs/dotfiles.md` |

Anything not in this table is either retired (`SYSTEM.md` → Retired) or not part of the workflow.

## Repo map

| Path | Role | Read when |
|---|---|---|
| `AGENTS.md` | this contract | always loaded |
| `SYSTEM.md` | machine state: stack, retired tools, hygiene | before any machine claim |
| `GLOSSARY.md` | ubiquitous language, vault naming | before naming anything |
| `specs/<domain>.md` | verified current state · invariants · gaps | before touching that domain |
| `changes/NNNN-slug.md` | one decision per file; `archive/` when done | when opening or closing a change |
| `changes/BACKLOG.md` | ranked candidates | when picking work |
| `.agents/rules/*.md` | path rules; Claude auto-loads via `.claude/rules` symlink, pi reads on the pointer below | before editing a matching path |
| `.agents/skills/*/SKILL.md` | procedures; pi native, Claude via `.claude/skills` symlink | on invocation |
| `.pi/extensions/git-guard.ts` | pi gate: blocks commit / push / hard reset | loaded by pi after project trust |
| `vault` | gitignored symlink → Obsidian vault | only when the task names it |

## Path rules — read before editing

Claude Code loads these on its own (`paths:` frontmatter). pi has no rule mechanism: **read the file
before the first edit** to a matching path.

| Editing | Read first |
|---|---|
| `specs/**`, `SYSTEM.md` | `.agents/rules/specs.md` |
| `changes/**` | `.agents/rules/changes.md` |
| anything under `vault/` | `.agents/rules/vault.md` |

## Approval contract

1. **Explain before acting.** For anything that alters the machine, `~/devSetup`, agent config or the
   vault: state problem → options → chosen action → files touched, then **wait**. Read-only inspection
   and edits to this repo's markdown proceed without asking.
2. **Never run `git commit`, `git push` or `git reset --hard`.** Write the commit message and a summary
   of the diff; Luis runs it. Enforced, not trusted: `.pi/extensions/git-guard.ts` (pi) and
   `.claude/settings.json` `permissions.deny` (Claude Code).
3. Config that must reach the machine goes to `~/devSetup` as its own commit. This repo decides and
   records; `devSetup` ships.

## Working agreement — spec-anchored, one file per change

1. **Problem** — observed symptom with evidence: command output, file path, timing. No hypotheticals.
2. **Baseline** — measure first. Keystrokes, hand-offs to mouse, startup ms, steps, failure rate.
   Keyboard claims use the keystroke-level model (`specs/keyboard.md` → Invariants). Unmeasurable → say so.
3. **Options** — ≥2 real alternatives, pros/cons, sources. One-option tables mean the analysis was skipped.
4. **Decision** — chosen option, and why each rejected one lost, on a named tradeoff axis.
5. **Tasks** — ordered, each naming its file, each independently verifiable.
6. **Verification** — the exact command or observation that proves it works.
7. **Outcome** — after execution: measured delta, what surprised us.

Template `changes/TEMPLATE.md`. On completion: fold durable facts into `specs/*.md`, update `SYSTEM.md`,
drop the backlog row, `git mv` the change into `changes/archive/`. Specs are steady state; changes are
the diff. Skip the change file only for typo/format fixes.

## Output contract

Default, always:

- Information-dense. Grammar is subordinate to density — drop articles and copulas, fragments over
  sentences, tables over prose.
- Conclusion first, then evidence. Exact paths, commands, numbers.
- No preamble, no restatement of the request, no summary of what you just did, no praise.
- Uncertainty stated at the claim, never as a closing disclaimer.
- Every claim about the machine, a file or a tool is verified in-session or marked `[UNVERIFIED]`.
  Never invent a measurement; absent baseline → `baseline: not measured`.

**Evaluation mode** — on explicit request only (e.g. "evaluate all potential good solutions",
"explain", "teach"). Then go wide and deep, still dense:

- Enumerate **every** viable option, including the ones not chosen and the do-nothing option.
- Pros, cons, and the single tradeoff axis that decides it.
- Current research and best practice: papers, specs, official docs, named practitioners, with links and
  dates. Distinguish measured mechanism from opinion; mark model-version-dependent advice as such.
- What top practitioners actually do, named — not anonymous consensus.
- Link to what Luis already knows: grep `vault/` for the relevant note, cite its path.
- Order: fundamental → mechanism → implementation → tradeoffs.
- Long-form output belongs in a vault note under its owning MOC, not in chat and not in this repo.

## Verification

Before reporting any change complete:

```sh
scripts/check.sh
```

- Documentation change → re-read the file, confirm links resolve.
- Config/script change → run it, paste real output.
- Claim about installed tooling → `brew list`, `--version`, or read the config file. Not memory.
- Never report a workflow as improved without a before/after number or an explicit
  "unmeasurable, judged by X".
- Never edit `scripts/check.sh` to make a check pass. A wrong check is its own change.

## Obsidian vault

`./vault` → `/Users/luis/luis_obsidian_vault`, ~2240 notes, synced by Syncthing. It is the knowledge
base; this repo is not a second one.

- Never bulk-read. Grep for the note, read the section. Ignore `.trash/`, `.obsidian/`,
  `*.sync-conflict-*.md`, `Untitled*.md`, `.stfolder*`, `.DS_Store`.
- **Contains plaintext secrets** (`SYSTEM.md` → Hygiene). Never copy vault content into this repo
  without a secret scan; never echo an apparent key.
- Read-only unless the task names a vault path. Full rules: `.agents/rules/vault.md`, procedure:
  `vault-note` skill.
- A note goes where its readers look: general knowledge → its **topical vault folder** under the owning
  MOC (retrieval here is by MOC link, not by tag). Register every new note in its MOC in the same action.
- Vault files are outside git. State every vault path you touched, in chat.
