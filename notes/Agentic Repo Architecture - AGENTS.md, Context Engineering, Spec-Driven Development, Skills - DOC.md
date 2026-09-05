---
Created: "[[2026-09-05]]"
Title: "Agentic Repo Architecture - AGENTS.md, Context Engineering, Spec-Driven Development, Skills - DOC"
tags:
  - "#note/"
Parent: []
Children:
MOC: "[[600 Knowledge/Software-IT - General/Agentic Development - Prompting/Agentic Coding - AI Coding MOC|Agentic Coding - AI Coding MOC]]"
date: "2026-09-05"
---
# Agentic Repo Architecture - AGENTS.md, Context Engineering, Spec-Driven Development, Skills - DOC

# Summary

How to shape a repository so coding agents produce good output. Three independent decisions, each with
a settled answer as of 2026-09:

1. **Which instruction file** → `AGENTS.md` canonical, `CLAUDE.md` a one-line `@AGENTS.md` import.
   Claude Code does not read `AGENTS.md`; Codex, opencode, omp and Copilot do not read `CLAUDE.md`.
2. **How much context is always loaded** → as little as possible. Three tiers: context file (always),
   path-scoped rules (on match), skills (on use). Driven by *context rot*, not by taste.
3. **How much spec machinery** → spec-anchored, not spec-as-source. Persist a per-domain spec and a
   per-change decision record. Skip the heavyweight SDD toolkits until a change genuinely spans many files.

Applied in `workflow-opt` (this repo). Fills the 3-line spec-driven-development stub in
[[600 Knowledge/Software-IT - General/Agentic Development - Prompting/Agentic Coding - AI Coding MOC|Agentic Coding - AI Coding MOC]].

# Notes

## 1. The instruction-file landscape

| File | Read by | Status |
| --- | --- | --- |
| `AGENTS.md` | Codex, opencode, Jules, Cursor, Zed, Amp, Copilot coding agent, omp (`agents-md`), 20+ others | open format, ~60k public repos, stewarded by the Agentic AI Foundation (Linux Foundation) |
| `CLAUDE.md` | Claude Code, omp (`claude-md`) | vendor-specific; **the only file Claude Code reads** |
| `.cursorrules`, `.windsurfrules`, `.clinerules` | one tool each | legacy, superseded by rules directories |
| `.github/copilot-instructions.md`, `.github/instructions/**.instructions.md` | Copilot / VS Code | `applyTo:` frontmatter = path scoping |
| `GEMINI.md` | Gemini CLI | configurable to read `AGENTS.md` via `.gemini/settings.json` |
| `.omp/AGENTS.md`, `.omp/RULES.md` | omp native | `RULES.md` = always-apply sticky rule |
| `llms.txt` | web crawlers/agents fetching a site | different problem: documentation discovery, not repo instructions |

**Resolution rules that matter.** The nearest file to the edited file wins; explicit chat prompts override
everything (agents.md FAQ). Claude Code concatenates every `CLAUDE.md` from filesystem root down to cwd,
so files closer to cwd are read last and are more prominent. omp keeps one project context file *per
directory depth* and lets the higher-priority provider shadow the rest at equal depth — so a root
`AGENTS.md` shadows a root `CLAUDE.md` there, while Claude Code sees only the latter.

**Conclusion.** `AGENTS.md` + `CLAUDE.md` containing `@AGENTS.md` is the only layout with no duplication
and no agent excluded. A `ln -s AGENTS.md CLAUDE.md` symlink also works but then no Claude-only line
can be added. Per-tool copies are exactly the drift problem `AGENTS.md` was created to end.

## 2. Context engineering, not prompt engineering

Anthropic's framing: context is a finite resource with an *attention budget*; the goal is the smallest
set of high-signal tokens that produces the desired behaviour. Empirical backing is **context rot** —
recall degrades as the context window fills (Chroma research), because transformer attention spreads
over n² pairwise relations and models saw mostly short sequences in training.

Practical consequences, all stated in Anthropic's own Claude Code guidance:

- Target **≤ 200 lines** per context file. "Bloated CLAUDE.md files cause Claude to ignore your actual
  instructions." Per line, ask: *would removing this cause a mistake?* If not, cut it.
- Include: commands the agent cannot guess, conventions that differ from defaults, environment quirks,
  repository etiquette, non-obvious gotchas. Exclude: anything derivable from reading the code,
  standard language conventions, API docs (link them), frequently-changing facts.
- If one instruction keeps being skipped, emphasise **that line alone**. Emphasise many → none stands out.
- `@path` imports are expanded **at launch** — they organise, they do not save tokens. False economy.

The three tiers:

| Tier | Mechanism | Loaded |
| --- | --- | --- |
| always | `AGENTS.md` / `CLAUDE.md`, `.claude/rules/*.md` without `paths:` | every session |
| on match | `.claude/rules/*.md` with `paths:` glob frontmatter | when the agent touches a matching file |
| on use | `.claude/skills/<name>/SKILL.md` (+ reference files in the same dir) | frontmatter always visible, body only when invoked |

Skills follow the **Agent Skills** open standard (agentskills.io) and are the right home for anything
procedural: "a section of CLAUDE.md that has grown into a procedure rather than a fact." This is
*progressive disclosure* — the same just-in-time retrieval principle behind grep/glob beating a
pre-built vector index for a filesystem corpus.

Beyond files, for long-horizon work: **compaction** (summarise and reinitialise), **structured
note-taking** (agent writes to disk, reads back after a reset), **sub-agent architectures** (isolated
context, returns 1–2k tokens of distilled result). See
[[600 Knowledge/Software-IT - General/Agentic Development - Prompting/Context Engineering - Science, Fundamental|Context Engineering - Science, Fundamental]].

**Advisory vs. enforced.** Context files are context, not configuration — the model may ignore them.
Anything that must hold deterministically is a **hook** (script on a lifecycle event) or a
**permission rule**. Writing "never touch X" in prose is a hope; a `deny` rule is a guarantee.

## 3. Spec-driven development — three levels, five tools

Böckeler's taxonomy (martinfowler.com, 2025-10-15) is the useful cut:

1. **Spec-first** — a spec is written before the code, then discarded. Every SDD tool does this.
2. **Spec-anchored** — the spec is kept and evolved with the feature.
3. **Spec-as-source** — humans only edit the spec; code is generated and marked do-not-edit.

Separate concept: the **memory bank** (Cline's term) = the always-relevant project context, i.e. the
rules file and architecture description. spec-kit calls it a **constitution**, Kiro calls it **steering**.
Specs are per-change; the memory bank is per-repo. Do not merge them.

| Tool | Workflow | Level | Verdict for a personal-workflow repo |
| --- | --- | --- | --- |
| **Kiro** (AWS) | Requirements → Design → Tasks, `steering/{product,tech,structure}.md` | spec-first | simplest mental model, but IDE-bound and wildly oversized for a small change — 4 user stories and 16 acceptance criteria for one bug fix |
| **GitHub spec-kit** | Constitution → Specify → Plan → Tasks → Implement → Converge; `.specify/{memory,templates,scripts}` | spec-first (branch per spec) | most complete, extensions for bug-fix and idea-assessment; but generates many repetitive markdown files to review. Böckeler: "I'd rather review code than all these markdown files" |
| **OpenSpec** | `/opsx:explore → propose → apply → archive`; `openspec/{specs,changes,changes/archive}` | spec-anchored | the right *shape*: living specs plus transient changes plus an archive, brownfield-first |
| **BMAD** | multi-agent roles (PM, architect, dev, QA) | spec-first | team ceremony; solo overhead |
| **Tessl** | `tessl build` from `*.spec.md`, `// GENERATED FROM SPEC - DO NOT EDIT` | spec-as-source | private beta; 1:1 spec↔file |

**The MDD warning.** Spec-as-source is model-driven development with natural language instead of UML.
MDD never took off for business applications: awkward abstraction level, too much overhead. LLMs remove
the code-generator burden but add non-determinism, and lose the tool support a parseable spec language
gave you. Risk: the downsides of both — inflexibility *and* non-determinism.

**Where SDD actually fits.** Unclear on both axes of Böckeler's matrix (problem size × problem clarity).
Observed failure mode is *review overload* and a *false sense of control*: agents ignore instructions
even with elaborate templates and checklists. Small iterative steps remain the best control mechanism,
which is in tension with heavy up-front specs.

## 4. Verification is the load-bearing part

Anthropic's first best practice: **give the agent a check it can run.** "Claude stops when the work
looks done. Without a check it can run, 'looks done' is the only signal available, and you become the
verification loop." Escalating strength: ask for the check in the prompt → set it as a session goal →
a `Stop` hook that blocks the turn until the check passes → a second model that tries to refute the result.

Documentation and config repos have no natural check, so one must be constructed: link resolution,
schema/section conformance, secret scanning, drift between the documented state and the machine.
This is the mechanism no SDD framework supplies and the one that actually prevents plausible-looking
wrong output.

## 5. Documentation shape

Diátaxis (Procida) splits documentation by user need: **tutorial** (learning by doing), **how-to**
(goal), **reference** (information), **explanation** (understanding). Mapping onto an agentic repo:

| Diátaxis | Artifact |
| --- | --- |
| reference | `specs/*.md`, `SYSTEM.md`, `GLOSSARY.md` |
| how-to | `.claude/skills/*/SKILL.md` |
| explanation | vault notes like this one |
| decision record | `changes/NNNN-*.md` — Nygard's ADR (2011) with a measured baseline added |

`GLOSSARY.md` is not decoration: a shared, enforced vocabulary is Evans's *ubiquitous language*
(*Domain-Driven Design*, 2003). Agents that lack a fixed term for a concept invent one, and then
instructions silently stop matching the repo.

# TODO

- [ ] Own note on evals / golden tasks for agent setups — nothing in the vault yet.
- [ ] Own note on git-worktree parallel agent sessions.
- [ ] Own note on the PKM method itself (PARA / Zettelkasten) — currently only folder shape, no method note.

# Links

- [[600 Knowledge/Software-IT - General/Agentic Development - Prompting/Agentic Coding - AI Coding MOC|Agentic Coding - AI Coding MOC]]
- [[600 Knowledge/Software-IT - General/Agentic Development - Prompting/Context Engineering - Science, Fundamental|Context Engineering - Science, Fundamental]]
- [[600 Knowledge/Software-IT - General/Agentic Development - Prompting/AI Vibe Agentic Coding - Best practices, Tools, Templates, Claude Code, Open Code|AI Vibe Agentic Coding - Best practices, Tools, Templates, Claude Code, Open Code]]
- [[600 Knowledge/Software-IT - General/Agentic Development - Prompting/AI Personalisation - ChatGPT, Claude - Profiling, Template - DOC April 2026|AI Personalisation - ChatGPT, Claude - Profiling, Template - DOC April 2026]]
- [[300 Resources - future/340 Workflow Documentation - Home lab/Workflow MOC - Environment Development DOC|Workflow MOC - Environment Development DOC]]

# Sources

- AGENTS.md — https://agents.md/ · spec repo https://github.com/agentsmd/agents.md
- Claude Code memory (incl. the `AGENTS.md` section) — https://code.claude.com/docs/en/memory
- Claude Code best practices — https://code.claude.com/docs/en/best-practices
- Claude Code skills / Agent Skills standard — https://code.claude.com/docs/en/skills · https://agentskills.io
- Anthropic, *Effective context engineering for AI agents*, 2025-09-29 — https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- Chroma, *Context Rot* — https://research.trychroma.com/context-rot
- Böckeler, *Understanding Spec-Driven-Development: Kiro, spec-kit, and Tessl*, 2025-10-15 — https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html
- GitHub spec-kit — https://github.com/github/spec-kit · `spec-driven.md`
- OpenSpec — https://github.com/Fission-AI/OpenSpec
- Cline memory bank — https://docs.cline.bot/prompting/cline-memory-bank
- Nygard, *Documenting Architecture Decisions*, 2011
- Evans, *Domain-Driven Design*, 2003, ch. 2 (ubiquitous language)
- Procida, *Diátaxis* — https://diataxis.fr
