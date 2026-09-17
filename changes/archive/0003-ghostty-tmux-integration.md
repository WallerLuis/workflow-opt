# 0003 — ghostty-tmux-integration

- status: done
- domain: specs/terminal.md, specs/dotfiles.md
- opened: 2026-09-17
- closed: 2026-09-17

Audit of the staged config copied from <https://tmux.app/doc/ghostty/> into `~/devSetup`
(`config/tmux/tmux.conf` staged diff, `config/ghosty/config` untracked). Covers BACKLOG #12 and
part of #11.

## Problem

The tmux.app guide is generic SEO documentation, not a Ghostty 1.3.1 reference. Taken verbatim it
produced one hard config error, six lines that change nothing, two security downgrades, and it
omits the two things that actually matter for tmux + Ghostty on this machine.

Evidence, all gathered 2026-09-17 on Ghostty 1.3.1 / tmux 3.7c:

```
$ ghostty +validate-config --config-file=~/devSetup/config/ghosty/config
theme "dark" not found, tried path "/Users/luis/.config/ghostty/themes/dark"
theme "dark" not found, tried path "/Applications/Ghostty.app/Contents/Resources/ghostty/themes/dark"

$ ghostty +show-config --default | grep -E '^(term|clipboard-write|clipboard-read|cursor-style|clipboard-paste-protection|shell-integration-features) ='
clipboard-read = ask
clipboard-write = allow
clipboard-paste-protection = true
cursor-style = block
shell-integration-features = cursor,no-sudo,title,no-ssh-env,no-ssh-terminfo,path
term = xterm-ghostty

$ ghostty +list-keybinds --default | grep fullscreen
keybind = super+enter=toggle_fullscreen
keybind = super+ctrl+f=toggle_fullscreen

$ TERM=xterm-ghostty tmux -L probe -f config/tmux/tmux.conf new-session -d 'printenv TERM'
tmux-256color                      # pane TERM, despite `update-environment TERM`
$ tmux -L probe show-environment -t p | grep TERM
TERM=xterm-ghostty                 # session env only; tmux overrides TERM/TERM_PROGRAM per pane
TERM_PROGRAM=ghostty               # pane sees TERM_PROGRAM=tmux

$ tmux -L d -f /dev/null new-session -d; tmux -L d list-keys -T copy-mode-vi | awk '$4=="C-v"'
bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle    # already the default

$ open -na Ghostty.app --args --command="tmux -L gtest new-session -A -s t"
$ tmux -L gtest show-environment -g | grep -E 'GHOSTTY|ZDOTDIR'
GHOSTTY_BIN_DIR=…  GHOSTTY_RESOURCES_DIR=…  GHOSTTY_SHELL_FEATURES=cursor:blink,path,title
                                   # no ZDOTDIR -> zsh integration never injected
$ # same launch with --shell-integration=zsh:
ZDOTDIR=/Applications/Ghostty.app/Contents/Resources/ghostty/shell-integration/zsh

$ # inside a tmux pane under Ghostty:
$ zsh -i -c 'whence -w ssh'
ssh: command                       # ghostty ssh wrapper absent -> no automatic remote terminfo

$ grep -n ghostty ~/devSetup/Brewfile
(nothing)                          # cask iterm2 + cask warp present, Ghostty unmanaged
```

## Baseline

`baseline: not measured` — this is a correctness audit, not a latency change. Judgement criterion:
**every line in a config file must change observable behaviour relative to the shipped default, or
it goes.** Count today: 6 lines fail that test, 1 line is a startup error, 2 lines weaken defaults.

## Findings

### `config/tmux/tmux.conf`

| Line | Verdict | Why |
| --- | --- | --- |
| `terminal-overrides ",xterm-ghostty:Tc"` | duplicate — drop | `man tmux`: "`Tc` … This is equivalent to the `RGB` terminfo(5) capability." You already set `terminal-features ",xterm-ghostty:RGB:extkeys"`. |
| `terminal-overrides ",*256col*:Tc"` | not about Ghostty | `terminal-*` keys match the **outer client** `TERM` (`tmux display -p '#{client_termname}'` → `xterm-ghostty`). `*256col*` only fires under iTerm2/Warp/VS Code. Keep, but as a `terminal-features … RGB` line — `specs/dotfiles.md` invariant: one mechanism. |
| `update-environment TERM` | no-op — drop | tmux sets pane `TERM` from `default-terminal`; verified pane `TERM=tmux-256color` while session env held `xterm-ghostty`. |
| `update-environment TERM_PROGRAM` | no-op — drop | tmux sets `TERM_PROGRAM=tmux` + `TERM_PROGRAM_VERSION` in every pane; verified. |
| `allow-passthrough on` | keep | Default `off` (verified on a `-f /dev/null` server). Required for Kitty-graphics passthrough (yazi, nvim image). Comment must lose "Sixel": ghostty.org/docs/features lists the Kitty graphics protocol only. |
| `extended-keys always` + `extended-keys-format csi-u` | keep | Stronger than the guide's `on`; works because `extkeys` is in `terminal-features`. |
| `bind -T copy-mode-vi C-v rectangle-toggle` | duplicate — drop | tmux default already binds `C-v` (and `v`) to `rectangle-toggle`. Your `v` → `begin-selection` is the real change; keep that. |
| `y` / `Enter` / `MouseDragEnd1Pane` → `pbcopy` | redundant with plugin | `tmux-yank` (`~/.config/tmux/plugins/tmux-yank/yank.tmux:46-51`) binds `y`, `Y`, `MouseDragEnd1Pane` to `pbcopy` on macOS, and tpm runs *after* these lines. Keep one owner. Do **not** take the guide's bare `copy-pipe-and-cancel` — it drops the pbcopy pipe. |
| missing: `focus-events on` | add | Default `off` (verified). tmux knows the terminal can report focus (builtin feature `xterm*:…:focus` matches `xterm-ghostty`) but will not request/forward it. Without it nvim `autoread`/`FocusGained` and lazygit auto-refresh are dead inside tmux. |
| missing: `set-clipboard on` | add | Default `external` (verified) = only forward an application's OSC 52. `on` makes tmux itself emit OSC 52 on copy — the only clipboard path that works when tmux runs on one of the 12 hosts in `config/ssh/config`, where `pbcopy` does not exist. |
| `Brewfile: brew "tmux-fingers"` vs `@plugin 'Morantron/tmux-fingers'` | duplicate install | brew ships `Cellar/tmux-fingers/2.7.1/bin/tmux-fingers`; tpm clones its own copy to `~/.config/tmux/plugins/tmux-fingers`. The conf loads only the tpm copy → the formula is dead weight. |

### `config/ghosty/config`

| Line | Verdict | Why |
| --- | --- | --- |
| `theme = "dark"` | **error** | No bundled theme named `dark`; `+validate-config` fails (output above). Ghostty wants a theme name or a `dark:X,light:Y` pair. |
| `term = "xterm-ghostty"` | duplicate — drop | Already the default. |
| `clipboard-write = allow` | duplicate — drop | Already the default. |
| `cursor-style = block` | duplicate — drop | Already the default. |
| `keybind = super+ctrl+f=toggle_fullscreen` | duplicate — drop | Already a default keybind (`+list-keybinds --default`). |
| `clipboard-read = allow` | drop — weakens default | Default `ask`. `allow` lets any program in any pane — an agent, or a remote host over SSH — read the macOS clipboard silently via OSC 52. `SYSTEM.md` → Hygiene: the vault holds plaintext secrets. |
| `clipboard-paste-protection = false` | drop — weakens default | Default `true`; it is the guard that warns before pasting text containing a newline, i.e. a command that self-executes. Agents print commands all day. |
| `font-family = "JetBrains Mono"` | keep (harmless) | Differs from the default only by preferring the `font-jetbrains-mono` cask over Ghostty's bundled JetBrains Mono NF. Nerd-font glyphs still resolve: `ghostty +show-face --font-family="JetBrains Mono" --string=$'\uf09b'` → "found in face Symbols Nerd Font". |
| `font-size`, `font-thicken`, `window-padding-*`, `cursor-style-blink = false` | keep | Each differs from the shipped default (13, false, 2/2, unset). |
| `macos-option-as-alt = true` | narrow to `left` | `true` routes **both** Option keys to Alt and kills macOS Option composition. The Karabiner Neo2 profile (`SYSTEM.md` → Keyboard: mod3/mod4/layer6) is the reason `terminal.md` has a conflict invariant. `left` gives tmux/readline its Alt and leaves right Option composing. |
| `command = tmux new-session -A -s dev` | keep, with two fixes | (a) Setting `command` to a non-shell stops shell-integration detection — verified: no `ZDOTDIR` injected, so no OSC 7 cwd, no OSC 133 prompt marks, no ssh wrapper. Needs an explicit `shell-integration = zsh`. (b) Every new Ghostty window/tab runs `-A -s dev` → all clients attach the *same* session, panes mirror and the size clamps to the smallest client. Use tmux windows/sessions inside one Ghostty window; revisit under BACKLOG #11. |
| missing: `shell-integration = zsh` | add | See above; verified it restores `ZDOTDIR` injection with `command` set. |
| missing: `shell-integration-features = ssh-env,ssh-terminfo,…` | add | This is the guide's biggest omission — its manual `infocmp -x xterm-ghostty \| ssh host "tic -x -"` step is built in since 1.1. Wrapper: `Resources/ghostty/shell-integration/zsh/ghostty-integration:317-385` (`ssh -G` → `ghostty +ssh-cache --host` → `tic -x -` → cache). Defaults are `no-ssh-env,no-ssh-terminfo`, so it is off until asked for. |
| missing: `.zshrc` sourcing of the integration | add | Upstream comment in `ghostty-integration:25-31`: "running `exec zsh`, `sudo -E zsh`, `tmux`, or plain `zsh` will create a shell where ghostty-integration won't automatically run." Verified: in a tmux pane `whence -w ssh` → `ssh: command`. Without the `.zshrc` hook, *none* of the ssh/terminfo/prompt-mark work reaches a tmux pane. |
| directory name `config/ghosty/` | rename | Ghostty reads `~/.config/ghostty/config`. Nothing links it today, so the file is currently inert. |

## Options

Remote terminfo for `xterm-ghostty` (12 hosts in `config/ssh/config`):

| Option | Pros | Cons | Verdict |
| --- | --- | --- | --- |
| A — manual `infocmp -x xterm-ghostty \| ssh host "tic -x -"` (the guide) | no config; one-time per host | 12 hosts × every rebuilt box; silently forgotten; nothing records which host has it | reject |
| B — `shell-integration-features = ssh-terminfo,ssh-env` | automatic on first `ssh`, cached (`ghostty +ssh-cache --list`), falls back to `xterm-256color` when `tic` is missing | needs the `.zshrc` hook to exist inside tmux; forces remote `TERM=xterm-ghostty` even when the local client is tmux | **chosen** |
| C — `TERM=xterm-256color` for all ssh (`ssh-env` only) | zero remote state | loses ghostty-specific caps remotely | fallback if B misbehaves: `[[ -z $TMUX ]] \|\| unfunction ssh` after sourcing |

Auto-launching tmux:

| Option | Pros | Cons | Verdict |
| --- | --- | --- | --- |
| A — `command = tmux new-session -A -s dev` (the guide) | one line; survives window close | kills shell-integration detection unless `shell-integration = zsh`; all windows mirror one session | keep + `shell-integration = zsh` |
| B — attach from `.zshrc` when `-z $TMUX` | shell integration intact; per-shell control | recursion risk in nested shells; fights VS Code's terminal | reject for now |
| C — no auto-attach, `sesh`/sessionizer keybind | session per project, matches BACKLOG #11 | needs the session workflow decided first | revisit in #11 |

Sources: <https://ghostty.org/docs/features>, <https://ghostty.org/docs/features/ssh>,
`ghostty +show-config --default --docs`, `man tmux` (`Tc`, `terminal-features`, `set-clipboard`,
`update-environment`), `/Applications/Ghostty.app/Contents/Resources/ghostty/shell-integration/zsh/ghostty-integration`.
Prior knowledge in the vault:
`600 Knowledge/Software-IT - General/linux - Unix/tmux - terminal multiplexer.md`,
`… /tmux Session Persistence - Client-Server Model, Reboot, Resurrect, Continuum, tmuxp - DOC.md`,
`… /Terminal Multiplexers - tmux vs Zellij, Practitioner Configs, Session Managers, sesh, sessionizer - DOC.md`,
`… /Terminal - Terminal Emulator - TTY, PTY, Console.md`.

## Decision

Tradeoff axis: **verified-against-this-binary over copy-paste**. Keep only lines that differ from
the shipped default of Ghostty 1.3.1 / tmux 3.7c, never weaken a security default for convenience,
and prefer the emulator's own mechanism (`ssh-terminfo`) over hand-run commands.

## Tasks

- [ ] `git mv config/ghosty config/ghostty` in `~/devSetup`; write the pruned config:

```
# ~/.config/ghostty/config — see workflow-opt changes/0003
font-family = "JetBrains Mono"
font-size = 14
font-thicken = true
theme = dark:Material Darker,light:Material

window-padding-x = 4
window-padding-y = 4
cursor-style-blink = false

# left Option = Alt for tmux/readline; right Option keeps macOS composition (Neo2)
macos-option-as-alt = left

# `command` is not a shell, so integration must be named explicitly, otherwise
# Ghostty injects no ZDOTDIR and the tmux panes get no integration at all.
shell-integration = zsh
shell-integration-features = cursor,title,path,ssh-env,ssh-terminfo
command = tmux new-session -A -s dev
```

- [ ] `config/tmux/tmux.conf`: drop `terminal-overrides ",xterm-ghostty:Tc"`, both
      `update-environment` lines and the `C-v` copy-mode bind; convert `*256col*:Tc` to
      `set -as terminal-features ",*256col*:RGB"`; add `set -g focus-events on` and
      `set -s set-clipboard on`; drop "Sixel" from the passthrough comment.
- [ ] `shell/zsh/.zshrc`: append the upstream hook so integration reaches tmux panes —

```
if [[ -n $GHOSTTY_RESOURCES_DIR ]]; then
  source "$GHOSTTY_RESOURCES_DIR"/shell-integration/zsh/ghostty-integration
fi
```

- [ ] `install.sh`: add `link "config/ghostty/config" "$HOME/.config/ghostty/config"` next to the
      tmux link, and a validation step after linking:

```
log "Validating Ghostty config"
GHOSTTY=/Applications/Ghostty.app/Contents/MacOS/ghostty
if [ -x "$GHOSTTY" ]; then
    "$GHOSTTY" +validate-config && printf '    ok    ghostty config valid\n'
else
    printf '    skip  Ghostty.app not installed\n'
fi
```

- [ ] `Brewfile`: add `cask "ghostty"` — absent today while `cask "iterm2"` and `cask "warp"` are
      present, so a clean machine bootstraps every emulator except the one this config targets.
      Hand-add the single line: `brew bundle dump --describe` (the command named in
      `specs/dotfiles.md`) now errors — "Calling the `--describe` switch is disabled!" — and a full
      regeneration drags in 5 months of drift (41 removed / 81 added lines). Fix the invariant text
      and do the regeneration as its own change.
- [ ] Decide the `tmux-fingers` duplicate: drop `brew "tmux-fingers"` (conf loads the tpm clone) or
      drop the tpm plugin and `run-shell` the brew copy. One owner.
- [ ] Decide the `tmux-yank` duplicate: keep the plugin or the three explicit `pbcopy` binds.

## Verification

```sh
cd ~/devSetup && ./install.sh                       # links ghostty config, validates it
/Applications/Ghostty.app/Contents/MacOS/ghostty +validate-config   # must print nothing
tmux -L v -f config/tmux/tmux.conf new-session -d -s v 'sleep 5'
tmux -L v show -gv focus-events                     # on
tmux -L v show -sv set-clipboard                    # on
tmux -L v show -gv terminal-overrides               # no xterm-ghostty entry
tmux -L v kill-server
# in a fresh Ghostty window, inside tmux:
zsh -i -c 'whence -w ssh'                           # ssh: function
tmux display -p '#{client_termname} #{?RGB,RGB,no-RGB}'   # xterm-ghostty RGB
```

## Outcome

Applied 2026-09-17. All seven tasks executed; the two open questions were decided by Luis:
tmux-fingers stays on tpm (brew formula uninstalled), tmux-yank owns copy-mode yanking.

Files changed in `~/devSetup`: `config/ghosty/` → `config/ghostty/config` (rewritten, 1237 B),
`config/tmux/tmux.conf`, `shell/zsh/.zshrc`, `install.sh`, `Brewfile`.

Measured against the criterion (every line must change behaviour vs. default):

| | before | after |
| --- | --- | --- |
| Ghostty config | invalid (`theme "dark" not found`), unlinked, 15 lines of which 5 duplicated defaults and 2 weakened them | `+validate-config` silent, linked, 13 settings all differing from default |
| tmux no-op lines | 4 (`xterm-ghostty:Tc`, 2× `update-environment`, `C-v`) | 0 |
| tmux missing behaviour | `focus-events off`, `set-clipboard external` | both on |
| tmux-fingers copies | 2 (brew 2.7.1 + tpm clone) | 1 (tpm clone binary) |
| copy-mode yank owners | 2 (manual binds + tmux-yank) | 1 (tmux-yank) |
| ghostty integration in tmux panes | absent (`whence -w ssh` → `ssh: command`) | live (`ssh: function`) |

Verification output:

```
$ ./install.sh                 # brew bundle shimmed out, see below
    ok    /Users/luis/.config/tmux/tmux.conf
    link  /Users/luis/.config/ghostty/config -> /Users/luis/devSetup/config/ghostty/config
>>> Validating Ghostty config
    ok    ghostty config valid

$ tmux -L live -f ~/.config/tmux/tmux.conf new-session -d …
focus-events on · set-clipboard on · allow-passthrough on · extended-keys always
terminal-overrides   linux*:AX@                      # tmux's own default entry only
terminal-features    … xterm-ghostty:RGB:extkeys, *256col*:RGB
copy-mode-vi         v=begin-selection (local) · y/Y/MouseDragEnd1Pane=pbcopy (tmux-yank) · C-v=default
prefix F             …/plugins/tmux-fingers/bin/tmux-fingers      # single owner

$ # real Ghostty window -> tmux pane:
whence -w ssh                  -> ssh: function
tmux display -p '#{client_termfeatures}'
                               -> bpaste,ccolour,clipboard,cstyle,extkeys,focus,RGB,title
ESC[38;2;255;100;0m…           -> renders orange (truecolor through tmux)
```

Surprises worth keeping:

1. **`brew bundle` is not a cheap verification step.** Two runs were interrupted at 600 s and 300 s.
   It adopted ~11 already-installed casks (receipts only — every app predates today) and the stale
   Brewfile makes it the dominant cost of `install.sh`. A `SKIP_BREW` escape hatch or a split
   `install.sh link` target is the obvious follow-up (BACKLOG #3 territory).
2. **Dropping `brew "tmux-fingers"` would have broken a clean bootstrap.** The tpm plugin resolves
   `tmux-fingers` on `PATH` first and falls back to `<clone>/bin/tmux-fingers`; with neither present
   it launches an *interactive* wizard on first tmux start. `install-wizard.sh download-binary` is
   the non-interactive path, so `install.sh` now calls it. The plugin also compares the binary's
   version against the clone's `shard.yml` and re-opens the wizard on mismatch — pinning tpm and
   brew to the same version was load-bearing, and is now moot.
3. **`shell-integration = zsh` is not cosmetic.** With `command = tmux …` and the default
   `detect`, Ghostty exports `GHOSTTY_SHELL_FEATURES` but no `ZDOTDIR`, so the integration never
   runs anywhere — the features string is advertised and inert.
4. **`terminal-features` are read when a client attaches.** The already-running server kept
   `RGB`-less features until a fresh attach; sourcing the config is not enough.
5. `#{?RGB,…}` is not a tmux format variable — it always renders false. `#{client_termfeatures}`
   is the honest check.

Residual risk, deliberately accepted: inside tmux the Ghostty `ssh` wrapper sets the remote
`TERM=xterm-ghostty` once terminfo is installed, while the local client is `tmux-256color`. If a
remote app misbehaves, gate it in `.zshrc` with `[[ -z $TMUX ]] || unfunction ssh` after sourcing.
