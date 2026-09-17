# 0003 — keyboard-first-context-restack

- status: in-progress
- domain: specs/agent-stack.md, specs/terminal.md, specs/keyboard.md, specs/editor.md, specs/desktop.md, SYSTEM.md
- opened: 2026-09-17
- closed:

## Problem

Three defects, all verified this session.

**1. The instruction layer documents a machine that is not the one being used.** `AGENTS.md:3` claims
five agents read the file. Luis runs omp plus the Claude Code CLI. The always-on layer spends tokens on
opencode, Copilot, Codex-as-CLI and devin-desktop.

**2. `.claude/rules/*.md` reach exactly one of the two harnesses.** Proven in an omp session:

```
read rule://vault → Unknown rule: vault
Available: go-add-cleanup, go-bench-loop, … ts-set-map     (builtin-defaults only)
```

omp's rule providers are `native .omp/rules/`, `agents`, `cursor`, `windsurf`, `cline`, `github`
(`omp://rulebook-matching-pipeline.md` §2). `.claude/rules/` is not among them → 945 tokens of rules
are inert under omp. Skills are fine: omp loads `.claude/skills/` via the `claude` provider (priority
80) — this session listed all three.

**3. The keyboard layer — the organising principle of the whole workflow — has no spec, and the facts
recorded about it are false.** Verified 2026-09-17 against the live filesystem:

| Claim in repo | Reality |
|---|---|
| `SYSTEM.md`: "`~/.tmux.conf` is 3 lines. No tpm, no prefix remap, no session picker" | `~/.tmux.conf` **does not exist**. `~/.config/tmux/tmux.conf` → `/Users/luis/devSetup/config/tmux/tmux.conf`, **3553 B**, tpm at `/opt/homebrew/opt/tpm`, 5 plugins (resurrect, continuum with `@continuum-restore on` + 5-min interval, fingers, open, yank), vim-tmux-navigator root bindings `C-h/j/k/l/C-\`, `mode-keys vi`, extended-keys `csi-u`, `allow-passthrough on`, `focus-events on`, `set-clipboard on`, Ghostty `RGB:extkeys` |
| `SYSTEM.md`: "no session-persistence story" | resurrect + continuum, auto-restore on |
| `SYSTEM.md`: Karabiner "2 profiles … Tab-as-Ctrl-when-chorded" as active state | **3** profiles. Active is `Neo_QWERTZ_onlyMod3` (`selected: true`) with **3 of 9 rules enabled**: Neo2 mod3, mod4 `↖`/`↘`→Home/End in terminal apps, both-shifts→caps. **Tab-as-Ctrl and layer 6 live in `Neo_QWERTZ_full` and are not active.** |
| `specs/dotfiles.md`: `~/.tmux.conf` listed as unmanaged live state | tmux config is devSetup-managed at the XDG path |
| `specs/agent-stack.md`: omp `~/.omp` "—" | `~/.omp/agent/config.yml`: `tools.approvalMode: write`, `modelRoles.default: anthropic/claude-opus-5`, `steeringMode: one-at-a-time`, `vault.enabled: true` |

**4. No commit gate.** Nothing prevents an agent running `git commit`/`git push`. Prose in a context
file is advisory (`omp://approval-mode.md`: only tool/user `policy: deny` is absolute).

**5. A cross-tool key collision nobody wrote down.** `~/Library/Application Support/Code/User/keybindings.json`
binds `ctrl+h`/`ctrl+l` to `workbench.action.terminal.focusPreviousPane`/`focusNextPane` under
`when: terminalFocus`. tmux binds the same two keys as root bindings (`bind-key -n`) for
vim-tmux-navigator. Running tmux inside the VS Code integrated terminal, VS Code consumes them first →
pane navigation silently dies in that one context.

## Baseline

Measured 2026-09-17:

| Metric | Value |
|---|---|
| omp always-on context | `AGENTS.md` 1408 tok + 3 skill descriptions 180 tok = **1588 tok** |
| whole instruction layer (with rule + skill bodies) | 7648 tok |
| `specs/` + `changes/` (on demand) | 16144 tok |
| rules reaching omp | **0 of 3** |
| `SYSTEM.md` ↔ `specs/` token overlap | dotfiles 47 %, shell 40 %, knowledge 30 %, terminal 32 %, agent-stack 26 % |
| verified-false machine claims found | 5 (table above) |
| keyboard layer specs | 0 |
| deterministic commit gate | none |

Context size is **not** the problem: 1588 tok ≈ 0.8 % of a 200k window, and `AGENTS.md` at 107 lines
is inside Anthropic's "under 200 lines per CLAUDE.md" guidance. Breadth, duplication and staleness are.

## Options

### Axis 1 — how many harnesses the instruction layer serves

| Option | Pros | Cons | Verdict |
|---|---|---|---|
| omp only | smallest surface | throws away the Claude Code CLI Luis still uses | rejected (Luis, this session) |
| Five agents, as today | future-proof | pays always-on tokens for four unused tools; `AGENTS.md:3` is false | rejected |
| **omp + Claude Code, one canonical file, dual-key rules, skills shared as-is** | both harnesses fully served; zero duplicated prose | rules carry two frontmatter keys | **chosen** |
| Per-tool copies | native to each | 0001 Outcome measured copy-drift inside **five days** in this repo | rejected |

Mechanism that makes the chosen option work without duplication:

- `AGENTS.md` canonical. omp loads it natively (`agents-md` provider); `CLAUDE.md` keeps `@AGENTS.md`
  because Claude Code "reads `CLAUDE.md`, not `AGENTS.md`" (code.claude.com/docs/en/memory#agentsmd).
- Rules stay one physical file each, carrying **both** keys — `paths:` (Claude Code's key,
  memory#path-specific-rules) and `globs:` + `description:` (omp's keys,
  `omp://rulebook-matching-pipeline.md` §6) — reachable from `.omp/rules/` by symlink.
  `description:` is mandatory for omp: without it the rule is not even addressable via `rule://`.
- Skills need no change: omp already discovers `.claude/skills/`.

### Axis 2 — output contract

| Option | Pros | Cons | Verdict |
|---|---|---|---|
| Terse always | cheapest | kills the learning contract Luis wants | rejected |
| Terse + teaching always on (today) | both goals stated | the two sections contradict; OpenAI's GPT-5 guide: contradictory instructions burn reasoning tokens on reconciliation | rejected |
| **Terse default + explicit `Evaluation mode` on request** | one lane at a time; trigger is a phrase Luis already uses ("evaluate all potential good solutions") | needs the trigger written down | **chosen** |

Style, per Luis: information-dense, grammar subordinate to density — drop articles and copulas, fragments
over sentences, tables over prose, conclusion first, exact paths/commands/numbers, uncertainty inline.

### Axis 3 — commit gating

| Option | Pros | Cons | Verdict |
|---|---|---|---|
| Prose only | zero config | advisory; an agent may ignore it | rejected |
| **`bash.patterns` deny/prompt + sticky `RULES.md`** | `deny` is absolute in every approval mode | omp-specific; Claude Code needs its own `permissions.deny` entry | **chosen** |
| `approvalMode: always-ask` | blanket | already on `write` (exec prompts); blanket prompting on reads adds noise for no new safety | rejected |

`tools.approval.eval: prompt` ships with it: `omp://approval-mode.md` documents that `eval` can spawn a
shell that `bash.patterns` does not cover.

### Axis 4 — documenting tools that are installed but unused

| Option | Pros | Cons | Verdict |
|---|---|---|---|
| Delete all mention | smallest docs | re-discovery and re-installation; that is how three Node managers appeared | rejected |
| Keep full descriptions | complete | ~25 % of `SYSTEM.md` describes machine that is not the workflow | rejected |
| **One-line kill list: tool · why retired · date; drop the line once uninstalled** | keeps the decision, not the description | needs periodic pruning | **chosen** |

Sources: `omp://context-files.md` · `omp://rulebook-matching-pipeline.md` · `omp://approval-mode.md` ·
`omp://skills.md` · code.claude.com/docs/en/{memory,skills,hooks,best-practices} ·
anthropic.com/engineering/effective-context-engineering-for-ai-agents (2025-09-29) ·
Liu et al., *Lost in the Middle*, arXiv 2307.03172 (TACL 2024) ·
Chroma, *Context Rot*, research.trychroma.com/context-rot (2025-07-14) ·
Jaroslawicz et al., *How Many Instructions Can LLMs Follow at Once?*, arXiv 2507.11538 (2025-07-15) ·
OpenAI GPT-5 prompting guide (2025-08) · Nygard, *Documenting Architecture Decisions* (2011-11-15) ·
Diátaxis (diataxis.fr) · SWE at Google ch. 10.

## Decision

Keyboard-first becomes the stated purpose of the repo, not an implicit habit: every workflow decision
is judged by whether it keeps hands on the home row and removes a mouse hand-off.

Locked by Luis, this session:

1. Keep the Claude Code CLI → dual-harness layout as in Axis 1.
2. Keep the three skills, in place (`.claude/skills/`, already loaded by both harnesses).
3. Commit/push gate only (Axis 3, option 2); no blanket approval escalation.
4. Terse default; teaching/evaluation only on explicit request, and then it must cover **every** viable
   option, pros/cons, current research, best practice and top-practitioner solutions, evaluated against
   each other.
5. Keep Stats, Rectangle (snapping) and AltTab (switching) — all three are keyboard surfaces.
6. Syncthing owns the vault; Nextcloud owns files. The four redundant Obsidian sync plugins are retired.
7. Second-brain structure gets its own spec plus a vault explanation note — **deferred to a later
   session**, tracked in `BACKLOG.md`. No empty spec file is created now (`specs/README.md`: empty specs
   are noise).
8. `notes/` is removed. Explanation-mode content lives in the vault under its owning MOC.

## Tasks

- [x] `changes/0003-keyboard-first-context-restack.md` — this file
- [ ] `specs/keyboard.md` — new: Karabiner active profile, tmux keys, Vimium, Obsidian vim, VS Code vim, collisions
- [ ] `specs/terminal.md` — rewrite `Current` against the real tmux config; Ghostty gaps
- [ ] `specs/editor.md` — new: VS Code + Neovim + vim; the VSCodeVim vs vscode-neovim decision as a gap
- [ ] `specs/desktop.md` — new: Brave, Raycast, AltTab, Rectangle, Stats, Wispr Flow, Nextcloud
- [ ] `specs/agent-stack.md` — rewrite: omp primary + Claude Code CLI; verified `~/.omp/agent/config.yml`; dual-key rules; gate gaps
- [ ] `specs/knowledge.md` — Syncthing owns vault, Nextcloud owns files; retire the 4 sync plugins
- [ ] `specs/dotfiles.md` — correct the tmux management claim
- [ ] `SYSTEM.md` — restack into Stack of record · Retired · Hygiene, with per-section verified dates
- [ ] `AGENTS.md` — keyboard-first purpose, approval contract, output contract + Evaluation mode, gate named
- [ ] `.claude/rules/*.md` — add `globs:` + `description:` beside `paths:`; symlink into `.omp/rules/`
- [ ] `.omp/RULES.md` — sticky hard constraints (needs approval: touches live agent behaviour)
- [ ] `.omp/config.yml` — `bash.patterns` commit/push gate + `tools.approval.eval` (needs approval)
- [ ] `.claude/settings.json` — matching `permissions.deny` for git commit/push
- [ ] `GLOSSARY.md` — disambiguate **note**, fix the 3 malformed table rows, drop dead harness vocabulary
- [ ] `README.md`, `specs/README.md` — layout without `notes/`; new domains
- [ ] remove `notes/`
- [ ] `changes/BACKLOG.md` — close tmux row; add second-brain, keyboard and Ghostty rows
- [ ] `scripts/check.sh` — move out of the skill dir; add gates (link parser, trailing whitespace, sticky rule present, terminology)

## Verification

```sh
scripts/check.sh                                  # exits 0
read rule://vault                                 # resolves under omp (currently: Unknown rule)
readlink ~/.config/tmux/tmux.conf                 # -> devSetup path, recorded in specs/terminal.md
```

- `/extensions` in omp lists the three skills and the three rules.
- A `git commit` attempt is denied or prompts; agent writes the message, Luis runs it.
- omp always-on token count ≤ 1200.
- Every machine claim in `SYSTEM.md` carries a verified date not older than this change.

## Outcome

Pending.
