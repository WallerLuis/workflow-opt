# spec: terminal

Terminal emulators, multiplexer, session persistence.

## Current

- Installed: **Ghostty** (cask + app, **no `~/.config/ghostty`**), **iTerm2**
  (`~/Library/Preferences/com.googlecode.iterm2.plist`, `~/.config/iterm2/`), **Warp**
  (`~/.warp/settings.toml` — `telemetry_enabled`, `crash_reporting`, `cloud_conversation_storage` all true).
- No alacritty / kitty / wezterm.
- tmux installed. `~/.tmux.conf` is 3 lines: `mode-keys vi`, `mouse on`, `history-limit 100000`.
  No `~/.config/tmux`, no tpm, no prefix remap, no session picker, no popup bindings.
- Current session in tmux 3.7c.

## Invariants

- One primary emulator, config version-controlled in `devSetup`.
- Long-running agent sessions survive terminal close. A closed window must never kill work in progress.
- tmux prefix must not collide with the Karabiner Neo2 layers or Tab-as-Ctrl (see `SYSTEM.md` →
  Keyboard). The vault's macOS MOC already documents a shortcut-conflict map — check it before rebinding.

## Gaps

1. Three emulators, none configured; the fastest one (Ghostty) has no config at all.
2. tmux effectively unconfigured → no named-session workflow for parallel agent runs, which is the
   main reason to have a multiplexer when agents run long jobs.
3. Warp sends telemetry and stores conversations in the cloud while agent work happens locally.
4. No decision on where agents run: emulator tabs vs. tmux sessions vs. VS Code terminal.
