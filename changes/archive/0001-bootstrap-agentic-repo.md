# 0001 — bootstrap-agentic-repo

- status: done
- domain: specs/agent-stack.md, specs/knowledge.md
- opened: 2026-09-05
- closed: 2026-09-13

## Problem

`workflow-opt` contained a single 20-line `CLAUDE.md` and nothing else — no git, no structure, no
record of the machine it is supposed to optimise. Verified at open:

```
$ find . -maxdepth 2 -not -path '*/.git/*'
.
./CLAUDE.md
$ git status --short
fatal: not a git repository
```

Consequences: agents start blank every session; the same machine facts get re-discovered
(three Node managers, dead p10k config, broken `~/devSetup`) and then lost; workflow decisions leave
no trace, so they get re-litigated.

## Baseline

- Agent-readable project context: 20 lines, 1 file, 0 verified machine facts.
- Reusable agent assets across the whole machine: **1** (`~/.claude/commands/write-ticket.md`).
  0 skills, 0 rules, 0 hooks, 0 user-level `CLAUDE.md`.
- Vault coverage of the target topic: 5 notes on agentic coding; spec-driven development is a
  **3-line stub** in `Agentic Coding - AI Coding MOC.md`.
- Machine reproducibility: `~/devSetup` links 1 of ~12 config surfaces → ~90 % unmanaged.

## Options

### Axis 1 — which instruction-file standard

| Option | Pros | Cons | Verdict |
| --- | --- | --- | --- |
| `CLAUDE.md` only | zero indirection; what Claude Code actually reads | Codex, opencode, omp's `agents-md` provider and Copilot don't read it; locks the repo to one vendor | rejected |
| `AGENTS.md` only | open format, Linux-Foundation-stewarded (Agentic AI Foundation), 60k+ repos, read by Codex/opencode/Jules/Cursor/Zed/omp | **Claude Code does not read it** (docs: memory#agentsmd) — the primary agent here would get nothing | rejected |
| `AGENTS.md` + `CLAUDE.md` symlink | one file, no duplication | forbids Claude-only content; Windows needs admin | rejected |
| **`AGENTS.md` canonical + `CLAUDE.md` = `@AGENTS.md` import** | one source of truth, every agent covered, Claude-only lines still possible | one extra 10-line file | **chosen** |
| Per-tool files (`.cursorrules`, `.github/copilot-instructions.md`, `GEMINI.md`, …) | native to each tool | N copies drift; the failure mode the AGENTS.md project exists to fix | rejected |

### Axis 2 — spec-driven development: how much machinery

| Option | Pros | Cons | Verdict |
| --- | --- | --- | --- |
| **GitHub spec-kit** (`/speckit-constitution → specify → plan → tasks → implement → converge`) | most complete; constitution + templates + checklists; extensions for bug-fix and idea-assessment; 130k★ | built for feature-sized code changes; Böckeler: "created a LOT of markdown files… repetitive… I'd rather review code"; branch-per-spec ⇒ spec-first, not spec-anchored | rejected for now; revisit if a change ever spans many files |
| **Kiro** (requirements → design → tasks, `steering/`) | simplest mental model; only 3 files | IDE-bound (VS Code fork); Böckeler: "sledgehammer to crack a nut" on a small bug — 4 user stories, 16 acceptance criteria | rejected |
| **OpenSpec** (`openspec/{specs,changes,changes/archive}`, `/opsx:explore→propose→apply→archive`) | explicitly spec-**anchored** and brownfield-first; the specs+changes+archive shape is exactly right | still a CLI + slash-command dependency for a docs repo | **shape adopted, tool not installed** |
| **BMAD** | multi-agent roles (PM/architect/dev/QA) | enterprise team ceremony; solo-user overhead | rejected |
| **Tessl** | only tool aiming at spec-as-source | private beta; 1:1 spec↔file mapping; Böckeler's MDD warning — risks inflexibility *and* non-determinism | rejected |
| **Hand-rolled: `specs/` + `changes/NNNN.md` + `archive/`** | zero dependency; one reviewable file per change; ADR-shaped (Nygard 2011) so the decision survives; migrates cleanly to OpenSpec later | discipline is manual; no tooling enforcement | **chosen** |

Decisive tradeoff: this repo's unit of work is a *workflow change to a machine*, not a user story.
SDD tools optimise requirements→code. What is actually needed is a decision record with a measured
baseline and a verification step. Böckeler's taxonomy: adopt **spec-anchored** (level 2), skip
spec-as-source (level 3).

### Axis 3 — context budget

| Option | Pros | Cons | Verdict |
| --- | --- | --- | --- |
| One large `AGENTS.md` with everything | one file to read | Anthropic: "Bloated CLAUDE.md files cause Claude to ignore your actual instructions"; context rot (Chroma) degrades recall as tokens grow | rejected |
| `AGENTS.md` + `@`-imports of SYSTEM/GLOSSARY | modular | imports are expanded **at launch** — same token cost, false economy | rejected |
| **Three tiers: `AGENTS.md` (always) + `.claude/rules/*.md` with `paths:` (on match) + `.claude/skills/*/SKILL.md` (on use)** | matches Anthropic's just-in-time retrieval: lightweight identifiers, load on demand | three places to look | **chosen** |
| Memory-bank file set (Cline: `project.md`/`architecture.md`/`progress.md`) | popular, well documented | overlaps `SYSTEM.md`/`specs/`; "progress" duplicates git history | shape folded into `SYSTEM.md` + `specs/` |
| Auto memory (Claude writes its own notes) | zero effort | currently `autoMemoryEnabled: false`; unreviewed model-authored context in every session | left off |

### Axis 4 — Obsidian linkage

| Option | Pros | Cons | Verdict |
| --- | --- | --- | --- |
| Move the workflow notes out of the vault into this repo | one home, git history | breaks Obsidian graph/backlinks; abandons 2240 notes and the MOC retrieval mechanism | rejected |
| Commit the vault (or a subfolder) into this repo | full-text agent access, versioned | Syncthing + git double-management; vault holds plaintext API keys → would be pushed | rejected |
| Symlink the vault **into** the repo, tracked | agent reads notes as normal files | git follows the link target on add → same secret-leak path | rejected |
| **Gitignored symlink `vault/` → vault root, agent-read-only (deny rules)** | just-in-time retrieval; zero context cost until grepped; zero git risk | link must be recreated per machine (documented in `README.md`) | **chosen** |
| **Reverse symlink: repo → vault workflow folder** | repo markdown is browsable and wikilinkable in Obsidian; dot-dirs stay hidden | Syncthing symlink behaviour unverified → `.stignore` note filed as knowledge#3 | **chosen** |
| Vector-index the vault for RAG | semantic search | Anthropic: agentic grep/glob beats stale indexes for filesystem corpora; adds infra | rejected |

### Axis 5 — documentation shape

Diátaxis (Procida) splits docs into tutorial / how-to / reference / explanation. Mapping used:
reference → `specs/` + `SYSTEM.md`; how-to → `.claude/skills/`; explanation → `notes/` (vault-visible);
decision → `changes/`. No tutorials: single user, no onboarding.

Sources: agents.md · code.claude.com/docs/en/{memory,skills,best-practices} ·
anthropic.com/engineering/effective-context-engineering-for-ai-agents ·
martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html (Böckeler, 2025-10-15) ·
github/spec-kit · Fission-AI/OpenSpec · research.trychroma.com/context-rot · Nygard, ADRs (2011) ·
Evans, *DDD* (2003) · Procida, Diátaxis · Forte, *Building a Second Brain* (2022).

Prior knowledge in the vault:
`600 Knowledge/Software-IT - General/Agentic Development - Prompting/AI Vibe Agentic Coding - Best practices, Tools, Templates, Claude Code, Open Code.md`,
`…/Context Engineering - Science, Fundamental.md`,
`…/AI Personalisation - ChatGPT, Claude - Profiling, Template - DOC April 2026.md`,
`…/Agentic Coding - AI Coding MOC.md` (SDD stub — this change is its missing content).

## Decision

`AGENTS.md` canonical, `CLAUDE.md` imports it. Spec-anchored SDD, hand-rolled, OpenSpec-shaped
(`specs/` + `changes/` + `changes/archive/`). Three-tier context budget. Vault reachable through a
gitignored symlink; repo visible in Obsidian through a reverse symlink.

**Revised 2026-09-13** (Axis 4, superseded by Luis): notes route by **subject, not authorship**.
General knowledge goes into its topical vault folder under the owning MOC; `notes/` holds only notes
about this repo's own system. The original "all agent-authored notes land in `notes/`" rule optimised
for git history and lost retrieval: the vault finds notes by MOC link, and no MOC points at
`workflow-opt/notes/`. Topic placement wins over authorship placement.

## Tasks

- [x] `AGENTS.md` — contract, repo map, working agreement, verification rules, vault policy, learning contract
- [x] `CLAUDE.md` — `@AGENTS.md` + Claude-only notes
- [x] `SYSTEM.md` — verified machine state, incl. hygiene flags
- [x] `GLOSSARY.md` — repo terms, harness terms, vault conventions
- [x] `README.md` — human entry + new-machine setup
- [x] `specs/{README,agent-stack,shell,terminal,knowledge,dotfiles}.md`
- [x] `changes/TEMPLATE.md`, `changes/BACKLOG.md` (20 ranked candidates), `changes/archive/`
- [x] `.claude/settings.json` — vault write denied
- [x] `.claude/rules/{specs,changes,vault}.md` — path-scoped
- [x] `.claude/skills/{new-change,vault-note,verify-repo}/SKILL.md`
- [x] `notes/` — kept for repo-system notes only; the architecture note moved to the vault (see Outcome)
- [x] `.gitignore`, `git init`, both symlinks

## Verification

```sh
./.claude/skills/verify-repo/check.sh    # links resolve, no secrets, symlinks live, specs↔SYSTEM present
git -C . log --oneline | head -1
readlink vault
readlink "$HOME/luis_obsidian_vault/300 Resources - future/340 Workflow Documentation - Home lab/workflow-opt"
```

In a fresh Claude Code session, `/context` must list `CLAUDE.md` **and** the imported `AGENTS.md`
under Memory files.

## Outcome

Executed 2026-09-05 → 2026-09-13. `./.claude/skills/verify-repo/check.sh` exits 0 on 9 gates.

### Measured delta

| Metric | Baseline | After |
| --- | --- | --- |
| Agent-readable project context | 20 lines, 1 file, 0 verified machine facts | `AGENTS.md` 107 lines + 5 specs + `SYSTEM.md`, every machine claim traced to a path or command |
| Reusable agent assets | 1 (`~/.claude/commands/write-ticket.md`) | 3 skills, 3 path-scoped rules, 1 hook, 1 verification script |
| Verification | none | 9-gate `check.sh`, negative-tested against 3 injected defects |
| Vault coverage of SDD | 3-line stub in `Agentic Coding - AI Coding MOC.md` | full note, linked from that stub |
| Repo reproducibility | untracked directory | git, 1 commit, 2 symlinks documented in `README.md` |

### Verified, not assumed

- Context-file resolution: `claude -p "list loaded memory files"` returned `CLAUDE.md` **and**
  `AGENTS.md` → the `@AGENTS.md` import works; Claude Code alone would not have read `AGENTS.md`.
- The gate catches real defects: injected a dangling link, a renamed spec heading, and a deleted
  symlink. Two were caught; the heading was **not**, because `grep -q '^## Invariants'` prefix-matched
  `## Invariants-broken`. Fixed to `^## $s$`, re-tested, 3/3 caught.
- Hook: 7 unit cases pass (blocks `Write`/`Edit` by path and mutating Bash; allows reads).

### Surprises

1. **`Write(...)` deny rules are inert.** Claude Code emitted: *"only `Edit(path)` rules are matched
   by file permission checks."* The original settings.json carried both; the `Write` entries did nothing.
2. **The guard is tool-specific, not repo-wide.** `.claude/settings.json` binds Claude Code only. An
   omp session wrote to the vault unblocked on 2026-09-10. The invariant in `specs/knowledge.md` was
   overstated and has been corrected; filed as `knowledge#7`.
3. **Copy-drift appeared within five days, in this repo.** A ChatGPT-app session mirrored
   `.claude/skills/` into `.agents/skills/` and `.codex/` by string-replacing `.claude` → `.Codex`,
   producing a documented command path that does not exist and a sentence stating the inverse of what
   the gate checks. Removed 2026-09-12. This is the strongest available argument for one canonical
   file plus symlinks, and against per-tool copies — the exact thesis of Axis 1.
4. **Authorship-based note routing was wrong.** See the revised Decision.

### Folded into

- `specs/agent-stack.md` — context-file resolution table, three-tier budget, gaps 1–7
- `specs/knowledge.md` — vault conventions, subject-routing, corrected enforcement invariant, gap 7
- `SYSTEM.md` — full machine state and 6 hygiene flags
- `changes/BACKLOG.md` — 20 ranked candidates derived from the gaps

### Open, carried to the backlog

A tool-agnostic vault guard (git pre-commit hook + filesystem permissions) — agent config cannot
provide it. A 10th gate asserting mirrored assets are symlinks, not copies.
