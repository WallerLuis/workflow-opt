# 0004 — keyboard-first-context-restack

- status: done
- domain: specs/agent-stack.md, specs/keyboard.md, specs/editor.md, specs/desktop.md, specs/terminal.md, specs/knowledge.md, SYSTEM.md
- opened: 2026-09-17
- closed: 2026-09-17

Opened as 0003; renumbered to 0004 — `changes/archive/0003-ghostty-tmux-integration.md` landed from a
concurrent session while this file was being written. Numbers are never reused.

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

- [x] `changes/0004-keyboard-first-context-restack.md` — this file
- [x] `specs/keyboard.md` — new: six layers, active Karabiner profile, tmux keys, Vimium, Obsidian vim, VS Code vim, six documented collisions, KLM invariant
- [x] `specs/terminal.md` — Ghostty + tmux corrected against the live files
- [x] `specs/editor.md` — new: VS Code + Neovim + vim; the VSCodeVim vs vscode-neovim decision as a gap
- [x] `specs/desktop.md` — new: Brave, Raycast, AltTab, Rectangle, Stats, Wispr Flow, Nextcloud
- [x] `specs/agent-stack.md` — omp primary + Claude Code CLI, per-harness loading table, measured context budget
- [x] `specs/knowledge.md` — Syncthing owns the vault, Nextcloud owns files; 4 plugins retired; second-brain gap filed
- [x] `specs/README.md` — eight domains, gap-closing convention
- [x] `SYSTEM.md` — Stack of record · Retired · Hygiene
- [x] `AGENTS.md` — keyboard-first north star, stack table, approval contract, output contract + Evaluation mode, gate named
- [x] `.claude/rules/*.md` — `globs:` + `description:` added beside `paths:`; `.omp/rules/*` symlinks
- [x] `.omp/RULES.md` — sticky hard constraints
- [x] `.omp/config.yml` — bash deny/prompt gate + `tools.approval.eval`
- [x] `.claude/settings.json` — `Bash(git commit:*)`, `Bash(git push:*)`, `Bash(git reset --hard:*)` denied
- [x] `GLOSSARY.md` — **note** disambiguated, malformed rows fixed, keyboard vocabulary + KLM added
- [x] `README.md` — keyboard-first framing, new layout, stack table
- [x] `notes/` removed
- [x] `changes/BACKLOG.md` — rebuilt: 6 new keyboard rows, closed items struck, second-brain row deferred by Luis
- [x] `scripts/check.sh` — moved out of the skill dir, 13 gates
- [x] `.claude/skills/{verify-repo,vault-note}/SKILL.md` — new gate path, no `notes/` routing
- [ ] Machine-side follow-ups are **not** in this change: uninstall the retired tools, bring Karabiner under `devSetup`, bind Ghostty's quick terminal, resolve the `ctrl+h`/`ctrl+l` collision (BACKLOG 21–24, 13, 7)

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

Executed 2026-09-17. `scripts/check.sh` → 13 gates, **clean, exit 0**.

### Measured delta

| Metric | Before | After |
|---|---|---|
| Rules reaching omp | 0 of 3 | 3 of 3 — verified in a fresh session: `omp -p 'read rule://vault …'` → `# Working with the Obsidian vault` (previously `Unknown rule: vault`) |
| Rule files per harness | 1 set, 1 harness | 1 set, 2 harnesses (`paths:` + `globs:` + `description:` in one physical file, symlinked) |
| Gate checks | 9 | 13 (+ rule loading, hook executability, commit gates, terminology, `notes/` absence) |
| Verified-false machine claims | 5 | 0 — all corrected against the live files |
| Keyboard layer specs | 0 | 1 spec, 6 layers, 6 documented collisions, 9 gaps |
| Deterministic commit gate | none | `bash.patterns` deny (omp) + `permissions.deny` (Claude Code) |
| Instruction-layer breadth | 5 agents claimed | 2 harnesses, each labelled with what it actually loads |
| omp always-on context | 1588 tok (claimed, method unrecorded) | **1969 tok** — `tiktoken o200k_base`: `AGENTS.md` 1752 + 3 skill descriptions 148 + 3 rule descriptions 69. The ≤1200 target in Verification is **not met** |

### Verified, not assumed

- **`bash.patterns` keys were wrong on the first attempt and failed silently.** The initial config used
  `pattern:`/`policy:` (the shape in `omp://approval-mode.md`'s prose); the settings schema wants
  `match:` + `approval:`. Proof, throwaway git repo under `$HOME` with `match: "echo GATED*"` /
  `approval: deny`:

  ```
  Reason: Blocked by bash pattern: echo GATED*
  No command output — the call was blocked by policy before execution.
  ```

  With `pattern:`/`policy:` the same command **ran**. A gate written from prose, not from the schema, is
  worse than no gate: it reads as protection and is inert. `.omp/config.yml` now carries the schema
  form and a comment recording the trap.
- Link-check false negative proven and fixed: greedy `sed` returned only the last link on a line
  (`see [b](./nope.md) and [a](./real.md)` → `./real.md`), so an earlier broken link passed. `grep -o`
  now extracts every link.
- **The gate was negative-tested, not just run green.** Ten defects injected into a `cp -a` copy of the
  repo; all ten produced a `FAIL` and exit 1: broken `@AGENTS.md` import · broken relative link · a
  rule **copied** instead of symlinked into `.omp/rules/` · a rule missing `globs:` · hook exec bit
  removed · `git push` rule deleted from `.omp/config.yml` · `spec-first` reintroduced into live
  guidance · `notes/` recreated · a spec's `## Gaps` heading renamed · `AGENTS.md` pushed to 245 lines.
  Two first-round "misses" were faults in the test, not the gate: prepending a line still left the
  import inside the `head -5` window, and the terminology injection replaced a string README does not
  contain (`keyboard-first` appears only capitalised). Re-tested with the real failure modes — import
  line deleted, term written into `specs/shell.md` — both caught.
- Known slack, deliberate: gate 2 accepts `@AGENTS.md` anywhere in the first five lines, not strictly
  line 1.
- Link gate over-fired once it was fixed: prose *about* link syntax in this file's own Outcome counted
  as two broken links. Fenced blocks and inline code spans are now stripped before matching, so
  documentation about markdown cannot fail the gate.
- The repo changed under this session: `0003-ghostty-tmux-integration` landed Ghostty + the full tmux
  config while these specs were being written, and `specs/terminal.md` was rewritten twice. Live
  `~/.config/ghostty/config` is **678 B with 11 lines**, while 0003's Outcome records 1237 B including
  `command = tmux new-session -A -s dev`; the discrepancy is recorded in `specs/terminal.md` rather
  than silently reconciled.
- **The `notes/` removal was incomplete and the gate could not see it.** `.claude/hooks/block-vault-writes.sh`
  still told the model "Write the note to notes/ instead" in both block messages — the one piece of
  dead routing that reaches the model at the moment it is deciding what to do instead. Gate 12 scanned
  `*.md` only, so hook stderr was outside its file set. Hook text rewritten (repo docs → spec/change
  file; real vault note → Luis names the path and runs the write), and gate 12 now greps
  `.claude/hooks/*.sh` + `.claude/settings.json`. Negative-tested: re-injecting `notes/` into the hook
  produces `FAIL dead reference in a hook or settings` and exit 1.
- **The ≤1200-token acceptance line contradicted this change's own Baseline** ("Context size is *not*
  the problem: 1588 tok ≈ 0.8 % of a 200k window") and was never measured at close. Measured now with
  `tiktoken o200k_base`: 1969 tok — the restack **grew** the always-on layer by 24 %, because
  `AGENTS.md` went 107 → 125 lines. Not silently trimmed: the two duplications are named with costs in
  `specs/agent-stack.md` → Gaps 9 and deferred to `BACKLOG 33`, since dropping locked contract text is
  Luis's call. The 1588 figure carried no method, so before/after are only comparable in order of
  magnitude.
- **Two gaps in `specs/agent-stack.md` were falsified by this change's own gate and still stood.**
  Gap 3 claimed `check.sh` never asserts the hook exists (gate 11 does) and gap 8 claimed no
  terminology check (gate 12 does). Folding a change into specs means re-reading the gaps the change
  closed, not only adding new ones; both rewritten to what is still missing (the block firing is
  asserted by shape only; no `[UNVERIFIED]`/drift/date-freshness checks).

### Surprises

1. **An agent will not execute a command its own rules forbid, even for a gate test.** Three attempts
   to obtain the literal block text for `git push --dry-run` produced a cited refusal instead. The
   mechanism had to be proven in a throwaway repo with a harmless pattern. A gate assertion therefore
   belongs in `scripts/check.sh` as a config-shape check, not as a live destructive-command attempt
   (BACKLOG 27).
2. **Tab-as-Ctrl was documented as active for twelve days and is not.** The selected Karabiner profile
   is `Neo_QWERTZ_onlyMod3` with 3 of 9 rules enabled; Tab-as-Ctrl and layer 6 live in the unselected
   `Neo_QWERTZ_full`. Nobody reads a 1 MB JSON file, which is exactly why the keyboard layer needed a
   spec.
3. **Session-persistence already existed** (resurrect + continuum, restore on, 5-minute interval) while
   `SYSTEM.md` claimed "no session-persistence story". The stale claim was three days old.
4. **`notes/` never held a note.** The Diátaxis explanation tier was created in 0001 and its only note
   was moved to the vault in the same change; it stayed in four files as a routing target for twelve
   days. Removed, and the gate now fails if it reappears.

### Folded into

`specs/keyboard.md` (new), `specs/editor.md` (new), `specs/desktop.md` (new), `specs/agent-stack.md`,
`specs/terminal.md`, `specs/knowledge.md`, `specs/README.md`, `SYSTEM.md`, `AGENTS.md`, `GLOSSARY.md`,
`README.md`, `changes/BACKLOG.md`.
