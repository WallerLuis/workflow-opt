# spec: terminal

Terminal emulator, multiplexer, session persistence. Keybindings live in `specs/keyboard.md`.

## Current

Verified 2026-09-17.

- **Ghostty 1.3.1** is the emulator of record (brew cask), configured and devSetup-managed:
  `~/.config/ghostty/config` → `/Users/luis/devSetup/config/ghostty/config`, 1237 B, validated by
  `ghostty +validate-config` (silent = valid). It holds only keys that differ from
  `ghostty +show-config --default`: fonts + padding, `cursor-style-blink = false`,
  `theme = dark:Material Darker,light:Material`, `macos-option-as-alt = left`,
  `shell-integration = zsh`, `shell-integration-features = cursor,title,path,ssh-env,ssh-terminfo`,
  `command = tmux new-session -A -s dev`. Defaults deliberately left alone: `term`,
  `clipboard-write`, `cursor-style`, `clipboard-read = ask`, `clipboard-paste-protection = true`.
- `command` is not a shell, so Ghostty cannot detect one: without the explicit
  `shell-integration = zsh` it injects no `ZDOTDIR` and tmux panes get no integration at all.
  Verified by launching with `--command=` and reading the tmux server environment.
- Every Ghostty window runs the same `new-session -A -s dev` → all windows are clients of one
  session: panes mirror and the width clamps to the smallest client. Parallel work uses tmux
  windows/sessions, not Ghostty tabs.
- Remote terminfo is Ghostty's job, not a manual step: the `ssh` wrapper from
  `shell-integration-features = ssh-terminfo` pipes `infocmp -x xterm-ghostty` into `tic -x -` on
  first connect and caches the host (`ghostty +ssh-cache --list`); `ssh-env` forwards
  `COLORTERM`/`TERM_PROGRAM`. It reaches tmux panes only because `devSetup/shell/zsh/.zshrc` sources
  `$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration` — shells Ghostty did not spawn
  directly (tmux, `exec zsh`, `sudo -E zsh`) never auto-load it. Verified in a pane:
  `whence -w ssh` → `ssh: function`.
- Also installed, both retired: **iTerm2** (`~/Library/Preferences/com.googlecode.iterm2.plist`,
  `~/.config/iterm2/`), **Warp** (`~/.warp/settings.toml` — `telemetry_enabled`, `crash_reporting`,
  `cloud_conversation_storage` all `true`). No alacritty / kitty / wezterm.
- **tmux 3.7c**, configured and devSetup-managed:
  `~/.config/tmux/tmux.conf` → `/Users/luis/devSetup/config/tmux/tmux.conf`, 3553 B.
  `~/.tmux.conf` **no longer exists** — the XDG path is the live one.
- tpm at `/opt/homebrew/opt/tpm/share/tpm/tpm`; plugins cloned into `~/.config/tmux/plugins/`:
  `tmux-resurrect`, `tmux-continuum`, `tmux-fingers`, `tmux-open`, `tmux-yank`.
- Each plugin has exactly one owner. `tmux-fingers` is the tpm clone's own binary
  (`~/.config/tmux/plugins/tmux-fingers/bin/tmux-fingers`, 2.7.1, fetched by
  `install-wizard.sh download-binary` from `install.sh`); the duplicate `brew "tmux-fingers"`
  formula was uninstalled 2026-09-17. Copy-mode yanking belongs to `tmux-yank`
  (`y`/`Y`/`MouseDragEnd1Pane` → `pbcopy`); the only local copy-mode bind is `v` → begin-selection,
  since `C-v` → rectangle-toggle is already a tmux default.
- **Session persistence exists**: `@continuum-restore on`, `@continuum-save-interval 5` → environment
  saved every 5 min, restored on tmux start after a reboot.
- Terminal plumbing tuned for Ghostty + nvim: `default-terminal tmux-256color`,
  `terminal-features xterm-ghostty:RGB:extkeys` (plus `*256col*:RGB` for the VS Code terminal),
  `escape-time 0`, `extended-keys always` with `csi-u` format, `allow-passthrough on` (Kitty graphics),
  `focus-events on`, `set-clipboard on` (OSC 52, works over ssh).
- Ergonomics: `base-index 1`, `pane-base-index 1`, `renumber-windows on`, `automatic-rename on`,
  `set-titles on`, `mouse on`, `history-limit 50000`, status line `#S` left / `%H:%M %d-%b` right.

## Invariants

- One primary emulator; its config is version-controlled in `devSetup`.
- Long-running agent sessions survive terminal close. Closing a window must never kill work in
  progress — this is what resurrect + continuum are for, and it must stay verified, not assumed.
- tmux config stays a symlink into `devSetup`. Editing the live file directly is a defect.
- `terminal-features` keys match the **outer** terminal's `TERM`
  (`tmux display -p '#{client_termname}'`), never the inner `default-terminal`.
- `RGB` is the terminfo-standard spelling of the legacy `Tc` override — never both.
- tmux prefix and root-table bindings are checked against `specs/keyboard.md` collisions before change.

## Gaps

1. ~~Ghostty has zero configuration~~ — closed 2026-09-17 (`changes/archive/0003-ghostty-tmux-integration.md`):
   font, theme pair, padding, shell integration, ssh terminfo. Still absent by choice: no `keybind`
   entries and no `toggle_quick_terminal` hotkey — the one keyboard-first feature Ghostty uniquely
   offers is still unbound, and belongs with `specs/keyboard.md`.
2. ~~`macos-option-as-alt` unset~~ — closed 2026-09-17: `left`. Left Option sends Alt for
   tmux/readline, right Option keeps macOS Unicode composition for the German layout, so the
   either/or is sidestepped rather than chosen.
3. Three emulators installed, two retired but not uninstalled; Warp still ships telemetry and cloud
   conversation storage while agent work happens locally.
4. No decision on where agents run: Ghostty + tmux panes vs. the VS Code integrated terminal. The two
   differ behaviourally — see the `ctrl+h`/`ctrl+l` collision in `specs/keyboard.md`.
5. Session-persistence has never been drill-tested: no recorded reboot → restore verification.
