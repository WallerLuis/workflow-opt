# spec: editor

Code editors and the modal layer inside them. Cross-app keybinding collisions: `specs/keyboard.md`.

## Current

Verified 2026-09-17.

- **VS Code** (`/Applications/Visual Studio Code.app`), ~100 extensions. Relevant settings: VSCodeVim
  active (leader `space`, `jk` → Esc, easymotion), relative line numbers, format-on-save via prettier,
  JetBrains Mono, telemetry off.
- `~/Library/Application Support/Code/User/keybindings.json`, 18 entries, terminal-heavy:
  `shift+enter` → `\u001b\r` sequence in the terminal (newline for agent prompts), terminal
  kill/rename/focus, `cmd+alt+t` new terminal, scroll bindings, `shift+cmd+b` → toggle maximized panel,
  and `ctrl+h`/`ctrl+l` bound **twice** — terminal pane focus under `terminalFocus`, editor group focus
  under `vim.mode == 'Normal'`.
- `asvetliakov.vscode-neovim` is installed but **cannot run**: it and VSCodeVim both register VS Code's
  `type` command and only one extension may own it (vscode-neovim README). It also requires a real
  Neovim config, which does not exist.
- Binaries: `/usr/bin/vim` (VIM 9.1, Apple build, no `+clipboard`), `/opt/homebrew/bin/nvim`
  (NVIM v0.12.5).
- **No `~/.config/nvim`, no `~/.vimrc`** (`~/.vim/` holds only `.netrwhist`).
- `EDITOR` and `VISUAL` = `nvim`, exported from `~/.zshenv` (`changes/archive/0002-*`). Consumers:
  omp `Ctrl+G` (`app.editor.external`, reads `VISUAL` then `EDITOR`, edits
  `$TMPDIR/omp-editor-<n>.omp.md`, `:wq` applies / `:cq` discards), git (no `core.editor` set),
  `crontab -e`, tmux-open's `C-o`.
- Windsurf installed, stale, retired. No Cursor, no JetBrains.
- Obsidian is a text surface too, with its own vim layer — see `specs/keyboard.md` and
  `specs/knowledge.md`.

## Invariants

- Exactly one modal engine owns VS Code's `type` command.
- `EDITOR`/`VISUAL` are exported from `.zshenv` only, as bare binary names (a value with spaces breaks
  tools that `exec` it as `argv[0]`).
- Editor-specific behaviour for agent prompt drafts keys off omp's temp-file pattern
  (`*.omp.md`), not off a wrapper command in `$VISUAL`.
- Any editor config that must survive a rebuild lives in `devSetup`, not in `~`.

## Gaps

1. No Neovim config, while nvim is `$EDITOR`/`$VISUAL` and the target of omp's `Ctrl+G` → the editor
   used for every prompt draft and commit message runs on stock defaults.
2. VSCodeVim (emulator) vs vscode-neovim (embeds real nvim, needs a config): undecided; one of the two
   extensions is dead weight and the decision is coupled to gap 1.
3. `ctrl+h`/`ctrl+l` bound in VS Code and in tmux's root table → broken pane navigation inside the
   VS Code integrated terminal.
4. Insert-mode escape is inconsistent across surfaces (`jk` in VS Code, `jk`+`kj` in Obsidian, none in
   nvim/vim).
5. VS Code `settings.json`, `keybindings.json` and `mcp.json` are unmanaged live state → not
   reproducible; `mcp.json` additionally holds a plaintext API key (see `SYSTEM.md` → Hygiene).
6. ~100 VS Code extensions, never audited against actual use.
