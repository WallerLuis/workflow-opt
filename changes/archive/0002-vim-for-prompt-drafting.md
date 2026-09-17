# 0002 — vim-for-prompt-drafting

- status: done
- domain: specs/shell.md, specs/dotfiles.md
- opened: 2026-09-15
- closed: 2026-09-15

## Problem

Long omp prompts are composed in omp's own single-line-ish prompt editor, which is readline-style
(`tui.editor.*` actions: `ctrl+a/e/w/u/k`, `alt+b/f`, kill-ring `ctrl+y`) and has **no modal editing**.
Verified against the installed build `/opt/homebrew/Cellar/omp/18.1.13/bin/omp`: no `vimMode`,
no `/vim` command, and `keybindings.yml` is a flat action-id → chord map with no mode state machine.

omp's escape hatch is `app.editor.external` (`Ctrl+G`), which hands the draft to a real editor:

```
// packages/coding-agent/src/utils/external-editor.ts
function n0() { return we.VISUAL?.trim() || we.EDITOR?.trim(); }   // VISUAL then EDITOR
async function r0(e, t, s) {
  const o = s?.extension ?? ".md";                                  // omp passes ".omp.md"
  const n = join(tmpdir(), `omp-editor-${Jt.next()}${o}`);
  ... sh -c '<EDITOR> "$1"' sh <file> , stdio inherited, ui.stop() around it
  if (exitCode === 0) return text.replace(/\n$/, "");               // :wq applies
  return null;                                                      // :cq discards
}
```

Neither variable is set in the real shell:

```
$ env -u EDITOR -u VISUAL zsh -lic 'echo "VISUAL=[${VISUAL-unset}] EDITOR=[${EDITOR-unset}]"'
VISUAL=[unset] EDITOR=[unset]
$ git config --global --get core.editor
(unset)
```

So `Ctrl+G` warns `No editor configured. Set $VISUAL or $EDITOR environment variable.`, and
`git commit` without `-m` drops into git's compiled fallback (`vi`) rather than a chosen editor.

The only trace of intent is a block that oh-my-zsh's template ships **commented out**
(`~/devSetup/shell/zsh/.zshrc:91-96`):

```zsh
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi
```

Related false lead, recorded so it is not re-diagnosed: `printenv` **inside an omp bash tool call**
shows `EDITOR=true`, `VISUAL=true`, `GIT_EDITOR=true`, `PAGER=cat`, `TERM=dumb`, `CI=true`. That is
omp's deliberate agent sandbox env (a no-op editor cannot hang an agent on an interactive buffer),
not machine state. Never measure user env from inside the tool.

## Baseline

- `Ctrl+G` in omp: unusable (warning, draft untouched). Multi-paragraph prompts are written with
  readline motions only — no `ciw`, no counts, no `.`, no macros, no visual block.
- zsh interactive startup, 10 runs of `/usr/bin/time -p zsh -i -c exit`:
  `min=0.140s median=0.150s max=0.440s`. Recorded because the fix adds a startup file, so it must
  not regress.
- Editor config present on the machine: **none**. No `~/.vimrc`, no `~/.config/nvim`;
  `~/.vim/` holds only `.netrwhist`. Binaries: `/usr/bin/vim` (VIM 9.1, Apple), `/opt/homebrew/bin/nvim`
  (NVIM v0.12.5).

## Options

Two independent axes: **which file** exports the variable, and **which editor** it names.

### Axis 1 — where the export lives

| Option | Pros | Cons | Verdict |
| --- | --- | --- | --- |
| A `.zshrc` | file already managed by `devSetup`; zero new plumbing | read by **interactive** shells only → `ssh mac 'git commit'`, LaunchAgents, scripts, GUI-launched processes get nothing. Wrong layer: an env var for child programs is not interactive config | rejected |
| B `.zshenv` | read by **every** zsh (interactive, non-interactive, scripts, remote command); canonical home for environment per zsh manual | new file + one `install.sh` line; must stay cheap (exports only, never `eval "$(tool init)"`) | **chosen** |
| C `.zprofile` | login shells only, so no script overhead | `~/.zprofile` is currently unmanaged live state (`specs/dotfiles.md` gap 1); managing it is its own change. Still misses non-login non-interactive shells | rejected |
| D per-tool (`GIT_EDITOR`, omp only) | most explicit | N tools × N variables; omp reads `VISUAL`/`EDITOR` anyway, so it solves nothing | rejected |

### Axis 2 — which editor, and `VISUAL` vs `EDITOR`

The split is historical, not cosmetic: `EDITOR` meant a **line** editor usable on a hardcopy/dumb
terminal (`ed`, `ex`); `VISUAL` meant the **full-screen** editor (`vi`). Consumers differ in order —
omp: `VISUAL` → `EDITOR`; git: `GIT_EDITOR` → `core.editor` → `VISUAL` → `EDITOR` → compiled `vi`;
`systemctl edit` inverts to `EDITOR` → `VISUAL`; older tools read `EDITOR` only.

| Option | Pros | Cons | Verdict |
| --- | --- | --- | --- |
| A `EDITOR` only | works with everything that has a fallback chain | tools preferring `VISUAL` never see a full-screen editor by name; relies on fallback | rejected |
| B `VISUAL` only | correct for omp/git/crontab | tools that read only `EDITOR` are left editor-less | rejected |
| C both = `vim` | Apple-maintained, instant, already in muscle memory, zero risk | stock vim defaults are poor for prose (no `linebreak`/`spell` tuning); Apple build lacks `+clipboard` | rejected |
| D both = `nvim` | identical keystrokes; sane stock defaults (syntax, `incsearch`/`hlsearch`, persistent undo, treesitter markdown in 0.12); one config to grow toward LSP | second binary to keep current | **chosen** |
| E `EDITOR=vim`, `VISUAL=nvim` | encodes the split's original meaning; boring floor + rich frontend | the branch can never actually differ on this box — both binaries are local and capable; two things to reason about for zero observable gain | rejected |

### Axis 3 — the `$SSH_CONNECTION` conditional in the template

`sshd` exports `SSH_CONNECTION` into the shell of an **incoming** login, so the test means "this shell
is remote-facing". Its real rationale: a remote host may lack your editor or your config, and a
redraw-heavy UI hurts over high-RTT links. Here it can only fire when Luis ssh's *into* this Mac,
where both `vim` and `nvim` exist — a branch with no behavioural difference. **Deleted, not enabled.**

Sources:
- zsh manual, *Startup/Shutdown Files* — <https://zsh.sourceforge.io/Doc/Release/Files.html>
- `git-var(1)` editor precedence — <https://git-scm.com/docs/git-var>
- POSIX `mailx` (`EDITOR`/`VISUAL` both specified) — <https://pubs.opengroup.org/onlinepubs/9699919799/utilities/mailx.html>
- oh-my-zsh `templates/zshrc.zsh-template` (origin of the commented block)
- `omp://keybindings.md` (`app.editor.external`), plus the decompiled `external-editor.ts` above

Prior knowledge in the vault:
- `vault/600 Knowledge/Software-IT - General/VIM - Cheat Sheet, Best practices, settings.md`
- `vault/.obsidian.vimrc` + `vault/.obsidian/plugins/obsidian-vimrc-support` — the same pattern
  already applied to Obsidian: host gets a vim layer, config is version-controlled

## Decision

`export EDITOR=nvim` **and** `export VISUAL=nvim` in a new `~/devSetup/shell/zsh/.zshenv`, linked to
`~/.zshenv`; delete the dead commented block from `.zshrc`.

Tradeoff axis for axis 1 is **coverage vs. plumbing**: `.zshenv` costs one new file and one
`install.sh` line and buys every non-interactive consumer. Axis 2 is **fidelity vs. risk**: with no
editor config on the machine, "your own vim" is currently vacuous for both candidates, so the
decider is stock defaults plus where future investment goes — nvim wins both, at identical keystroke
cost. Axis 3 is **explicitness vs. dead branches**: a conditional that cannot change behaviour is a
comprehension tax.

Value stays a **bare binary name**. `VISUAL="nvim -c 'set wrap linebreak spell'"` would work for omp
(it spawns via `sh -c`), but tools that `exec` the value directly as `argv[0]` break on spaces.
Prompt-specific behaviour therefore belongs in nvim, keyed on omp's temp-file pattern
`$TMPDIR/omp-editor-<n>.omp.md` — i.e. an `*.omp.md` autocmd. That is deferred to the Neovim-config
decision (`changes/BACKLOG.md` row 14), which is what makes this change pay off beyond stock defaults.

Not prejudicial to `specs/dotfiles.md` gap 1 (stow vs chezmoi vs bare git vs `link()`): the file must
exist under any mechanism; only the one `link` line moves.

## Tasks

- [x] Create `~/devSetup/shell/zsh/.zshenv` — exports only, `EDITOR` + `VISUAL` = `nvim`.
- [x] `~/devSetup/install.sh`: add `link "shell/zsh/.zshenv" "$HOME/.zshenv"` beside line 48.
- [x] `~/devSetup/shell/zsh/.zshrc`: delete the dead commented `EDITOR` block (lines 91-96).
- [x] Run `~/devSetup/install.sh`'s link step for the new file (or `ln -s` equivalent), then verify.
- [x] Fold into `specs/shell.md`, `specs/dotfiles.md`, `SYSTEM.md`.

## Verification

```sh
# 1. symlink is in place and points into devSetup
readlink ~/.zshenv                      # -> /Users/luis/devSetup/shell/zsh/.zshenv

# 2. both variables reach a clean shell, non-interactive included
env -u EDITOR -u VISUAL zsh -c   'echo "$VISUAL $EDITOR"'    # nvim nvim
env -u EDITOR -u VISUAL zsh -lic 'echo "$VISUAL $EDITOR"'    # nvim nvim

# 3. omp's own resolution order (VISUAL first) picks a real binary
env -u EDITOR -u VISUAL zsh -c 'command -v "${VISUAL:-$EDITOR}"'   # /opt/homebrew/bin/nvim

# 4. the round-trip contract: exit 0 applies, non-zero discards
f=$(mktemp -t omp-editor-XXXX).omp.md; printf 'draft\n' > "$f"
sh -c "$VISUAL \"\$1\"" sh "$f"      # :wq -> 0 ; :cq -> 1
echo $?

# 5. startup did not regress
for i in $(seq 10); do /usr/bin/time -p zsh -i -c exit; done 2>&1 | awk '/^real/{print $2}'
```

Manual observation (cannot be scripted): in an omp session, type text, press `Ctrl+G` → nvim opens on
`/var/folders/.../omp-editor-N.omp.md` with `filetype=markdown`; `:wq` returns the edited text into the
prompt, `:cq` leaves the draft untouched.

## Outcome

Executed 2026-09-15. Measured, not asserted:

- `readlink ~/.zshenv` → `/Users/luis/devSetup/shell/zsh/.zshenv`.
- `VISUAL`/`EDITOR` now `nvim` in all three shell kinds, previously unset in all three:

  ```
  env -u EDITOR -u VISUAL zsh -c   'echo "$VISUAL $EDITOR"'   -> nvim nvim
  env -u EDITOR -u VISUAL zsh -ic  'echo "$VISUAL $EDITOR"'   -> nvim nvim
  env -u EDITOR -u VISUAL zsh -lic 'echo "$VISUAL $EDITOR"'   -> nvim nvim
  env -u EDITOR -u VISUAL zsh -c 'command -v "${VISUAL:-$EDITOR}"' -> /opt/homebrew/bin/nvim
  ```

- Exit-code contract, run through omp's exact spawn shape `sh -c '<EDITOR> "$1"' sh <file>`:

  ```
  wq -> exit=0 content=edited        # omp applies the buffer
  cq -> exit=1 content=edited        # omp returns null, draft untouched
  filetype on omp-editor-XXXX.omp.md -> markdown
  ```

- **Live end-to-end in a real omp TUI** (headless pty, `omp --no-session --no-tools`, no model call):
  typed `smoke test draft`, sent `Ctrl+G` (0x07). `pgrep` during the handoff:

  ```
  43739 nvim        /var/folders/.../T/omp-editor-1580d803ca644d23.omp.md
  43740 nvim --embed /var/folders/.../T/omp-editor-1580d803ca644d23.omp.md
  ```

  Appended text + `:wq` → prompt line became `╰─ smoke test draft EDITED-IN-NVIM`.
  Second `Ctrl+G`, typed `DISCARD-ME`, `:cq` → prompt line still
  `╰─ smoke test draft EDITED-IN-NVIM` (the string appeared only in nvim's own pty echo, never in the
  draft). Temp file removed by omp's `finally` after each round trip.
- Startup cost: none measurable. Interleaved A/B, 20 runs of `/usr/bin/time -p zsh -i -c exit` each:
  `with-zshenv median=0.150s min=0.140s` / `without median=0.150s min=0.140s` /
  `with-zshenv (repeat) median=0.150s min=0.140s`. Intrinsic cost of the file:
  1000 × `source ~/.zshenv` = 0.02 s → **0.02 ms** per shell. Baseline `max` spread (0.42–0.44 s)
  is p10k/nvm noise, unrelated (→ BACKLOG rows 5, 6).

Surprises:

1. The `EDITOR=true` red herring. omp's bash tool injects a full non-interactive env
   (`EDITOR/VISUAL/GIT_EDITOR=true`, `PAGER=cat`, `TERM=dumb`, `CI=true`, `AGENT=1`, `npm_config_yes=true`)
   so an agent can never hang on an interactive editor or pager. Any claim about user env measured
   through an agent tool is invalid by construction — measure with `env -u VAR zsh -lic`, which also
   strips the inherited value.
2. `tui.editor.*` action IDs are remappable from `~/.omp/agent/keybindings.yml` even though
   `omp://keybindings.md` documents only `app.*`: the default table is `Mne = { ...o4e, "app.*": … }`,
   one manager serving both namespaces. Useful, but it cannot produce modal editing — no mode state,
   no operator-pending, no counts, no registers.
3. `SYSTEM.md` and `specs/dotfiles.md` were stale on `~/devSetup`. Verified today: `install.sh` is a
   working idempotent bootstrap (backup + `ln -s`), `.gitignore` is 24 lines and denies secrets,
   `docs/bootstrap.md` is 1839 B. Corrected in both files; SYSTEM hygiene flag 3 closed. The rest of
   the 2026-09-05 snapshot was not re-verified and may carry more drift (BACKLOG row 10).
4. `link()` compares `readlink "$dst"` to an **absolute** `$REPO/...` path, but `~/.zshrc` is a
   *relative* symlink → a re-run backs it up into `~/.dotfiles-backup/<ts>/` and relinks instead of
   printing `ok`. Recorded in `specs/dotfiles.md`, folded into BACKLOG row 3. The new `.zshenv` link
   was created absolute, so it reports `ok`.
5. Full `install.sh` was not run to completion on purpose — it would trigger `brew bundle` and ~100
   `code --install-extension` calls. The link step was validated by evaluating `install.sh`'s own
   predicate (`[ "$(readlink "$dst")" = "$src" ]`) against both targets, plus `bash -n`.

Fold-out: `specs/shell.md` (Current + new invariant), `specs/dotfiles.md` (Current corrected),
`SYSTEM.md` (Shell, Editors, Dotfiles, Hygiene 3), `changes/BACKLOG.md` (rows 3, 14).
