# 0008 — vault-standard-single-source

- status: done
- domain: specs/knowledge.md, specs/agent-stack.md
- opened: 2026-10-13
- closed: 2026-10-14

## Problem

Vault conventions live in 6 places that disagree (`specs/knowledge.md` gap 9):
`Workflow MOC - Environment Development DOC.md` → `# Second brain` (dump), `GLOSSARY.md` → Vault
vocabulary, `.agents/rules/vault.md`, `vault-note` skill, `901 Template/920`, `921`. 400-line limit
and source bar exist only in the dump; 7-key frontmatter only in the repo. The dump is never loaded by
any agent. Repo copies load only when cwd = this repo; pi runs mostly in other repos (Luis, 2026-10-13).

Pasted AI output shows the cost: `Docker - Best Practices…md` `# Netowrk` (terminal paste, shell
comments rendered as H1), `Naming in code…md` (2125 lines, H1 nested under `## Chatgpt prompt`).
Clipboard cleanup itself is out of scope (separate problem, requirements in the Workflow MOC).

## Baseline

- Convention locations: 6. Agents that see the full set: 0.
- Notes (1999 total, 2026-10-13): 734 with `Created:` frontmatter, 41 `<% tp`, 89 > 400 lines.
- Minutes to reformat one pasted section by hand: not measured → measure on Docker `# Netowrk` before task 5.

## Options

Content split by scope (who it binds) and editor (who changes it):

| Type | Binds | Home |
| --- | --- | --- |
| A. Vault standard (naming, frontmatter, links, MOC, length, sources, templates) | any writer into the vault | **this change** |
| B. Output format · C. learning style, profile, modes, pitfalls | every session, every repo | user-scope context, BACKLOG 2 |
| D. Procedures (write, reformat, extract, link) | on invoke | `vault-note` skill |

Home for A:

| Option | Agent finds it | Luis edits while writing | History | Verdict |
| --- | --- | --- | --- | --- |
| A1. repo rule + GLOSSARY (today) | only in this repo | no | git | ✗ wrong scope, already drifted |
| A2. vault note, no pointer | only if told | yes | none | ✗ unfindable for agents |
| A3. **`000 Index/` note + vault-root `AGENTS.md` (1-line pointer) + `CLAUDE.md` (`@AGENTS.md`)** | auto when cwd = vault; fixed path for skill from any repo | yes, in Obsidian | dated `## Changelog` section | ✓ |
| A4. user-scope skill in `~/devSetup` | from anywhere | no | git | ✗ editor is Luis-in-Obsidian, not a repo |
| A5. Obsidian Linter/Dataview rules | no | yes | none | ✗ mechanical subset only |

Old notes:

| Option | Verdict |
| --- | --- |
| big-bang AI migration | ✗ no undo, Syncthing propagates errors |
| migrate on touch via `vault-note reformat` | ✓ |
| read-only lint script → violation counts as queue | ✓ |
| scripted batch for mechanical MUSTs (e.g. 41 `<% tp`) | later, per case, with backup |

Sources: pi loads `AGENTS.md` from cwd and every parent (`specs/agent-stack.md`, observed); Claude Code
reads `CLAUDE.md` only, `@` imports ≤4 hops (code.claude.com/docs/en/memory). Ahrens, *How to Take
Smart Notes* (2017) — placement by future retrieval context.

## Decision

A3 (Luis, 2026-10-13: "add into 000 Index and a 1 line AGENTS importing"). Axis: the standard
changes while Luis writes in Obsidian → it lives in the vault; agents need a fixed path → `000 Index`
+ root pointer. Rules carry a level: **MUST** (lint-checkable; old notes violating it = finding) vs
**SHOULD** (agent judgment; old notes merely stale). New rules enter as SHOULD. Phone editing out of
scope (BACKLOG 36 covers phone agents). Lint + migrate-on-touch; no big-bang.

## Tasks

Decisions added 2026-10-13 (Luis): 20k-char MUST for all notes incl. MOCs and archive; splitting
section with context links; frontmatter 7 → 5 keys, keeping the name `Parent` (= nearest parent,
chain ends at a MOC; children via Dataview under `# Links`); one MOC per chain, no `000 Index`
registration; agents assist, never author — reformat is an on-request skill action.

- [x] 1. `vault/000 Index/Vault Conventions - Naming, Frontmatter, Links, MOC, Size, Sources - DOC.md`
      (6.5 KB), `Parent` → Note Taking MOC. **Vault write.**
- [x] 2. `vault/AGENTS.md` (1 line, 185 B), `vault/CLAUDE.md` (`@AGENTS.md`). **Vault write.**
- [x] 3. Workflow MOC: `Requirements/Conventions`, `MOC`, `Properties`, `Naming conventions`,
      `Linking` → one context link (12270 → 11011 B). Plugins, learning, format, modes untouched
      (they go to BACKLOG 2). Note Taking MOC: `## Children` Dataview block. **Vault write.**
- [x] 4. Repo pointers: `GLOSSARY.md`, `.agents/rules/vault.md`, `vault-note` skill, `AGENTS.md`.
- [x] 4b. Templates `920`, `921`: 5-key frontmatter + `## Children` Dataview under `# Links`.
- [x] 4c. Cleanup: `_testinfo/` (534 KB sync file list, June 2025) and a stray EIST L03 draft whose
      filename contained a line break (superseded by the real note) → `~/.Trash`. OhMyPi exports
      (314 KB) kept as `Length exception`.
- [x] 5. Luis ran `scripts/vault-frontmatter-migrate.py --apply`. Dry run 2026-10-13 (daily notes
      included per Luis): 1082 notes — Parent from Parent 39 / from MOC 537 / empty 506; 23 extra
      links moved into `# Links`; unresolved `[[Daily Notes]]` (261 daily notes) → Daily Notes MOC.
      Verified on all 1082: only parent/children/moc lines removed, second run = no-op.
- [x] 6. Dataview check: open the conventions note's Parent (Note Taking MOC) → `## Children` lists it.
      Dataview `warnOnEmptyResult: true` → empty Children blocks show a warning; Luis toggles it off.
- [ ] 7. → moved to change 0009. `vault-note` reformat action (skill text done) — test on Docker `# Netowrk`, Naming
      `## Chatgpt prompt`; measure minutes vs manual.
- [ ] 8. → moved to BACKLOG 37. `scripts/vault-lint.sh` (read-only) per MUST rule; record baseline.
- [x] 9. Close: fold into `specs/knowledge.md` (Current conventions → pointer; invariant 7-key → link;
      gaps 9–10), trim BACKLOG 25.

## Verification

```sh
test -f "vault/000 Index/Vault Conventions - Naming, Frontmatter, Links, MOC, Notes, Sources - DOC.md"
grep -c . vault/AGENTS.md                       # 1
grep -rn "7 keys\|Created.*Title.*tags" GLOSSARY.md .agents/  # 0 hits: no second copy
(cd vault && pi -p "which file defines vault conventions?")   # names the 000 Index note
scripts/vault-lint.sh
```

## Outcome

| Metric | Before | After |
| --- | --- | --- |
| Places defining vault conventions | 6 | 1 (`000 Index/Vault Conventions …`) |
| Agents seeing the full rule set | 0 | any agent via `vault-note` skill / vault-root `AGENTS.md` |
| Frontmatter keys (permanent notes) | 7 (`Parent` 9 %, `MOC` 12 %, `Children` ~0 % filled) | 5 |
| Notes carrying `Parent` | ~100 filled | 1093 keys, 576 filled |
| Unresolved `[[Daily Notes]]` in frontmatter | 261 | 0 |
| Convention text in repo (GLOSSARY, rule, skill, spec) | — | ~5 KB removed, pointers instead |

Verified 2026-10-14 (Luis): `--apply` wrote 1082 notes, re-run → `notes to change: 0`; Note Taking MOC
`## Children` renders 1 child; Dataview empty-result warning off.

Surprises: daily notes ran a third schema (lowercase `parent`/`moc`, 474 notes); 261 pointed at a
non-existent `[[Daily Notes]]`. 12 old notes carry `MOC::`/`Children:` as **body** inline fields and
27 daily nav bars still link `[[Daily Notes]]` — out of frontmatter scope, left for lint (BACKLOG 37);
the Daily templater nav bar was fixed so new notes resolve. `grep` is aliased to `rg` in Luis's shell —
verification commands must use `command grep`.
