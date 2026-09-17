# spec: keyboard

The keyboard layer. This workflow is keyboard-first: every layer below is a binding engine, and the
cost of a workflow is measured in keystrokes and hand-offs to the mouse.

Six layers, each with its own engine and its own precedence. Lower layers consume events first:
Karabiner virtual HID → macOS / Secure Input → global-hotkey apps → focused app → terminal program.

## Current

Verified 2026-09-17 by reading the live configs.

### L0 — Karabiner-Elements (HID remap)

- `~/.config/karabiner/karabiner.json`, 1004 KB, **3 profiles**:
  - `Vanilla` — 0 rules.
  - **`Neo_QWERTZ_onlyMod3` — `selected: true`**, 9 rules, **3 enabled**: Neo2 mod3 (all keyboards);
    Neo2 mod4 `↖`/`↘` → Home/End in terminal apps; both-shifts → caps-lock toggle.
  - `Neo_QWERTZ_full` — 10 rules, 5 enabled: the above plus Neo2 mod3+layer4, Neo2 layer 6, and
    **Tab-acts-as-Ctrl-when-chorded**.
- Layer emulation uses one variable, `neo2_mod_4` (`set_variable` + `variable_if`).
- Profile switching by script: `~/.local/bin/kb_2_vanilla`, `kb_2_neo_mod3`, `kb_2_neo_full`.
- → **Tab-as-Ctrl and layer 6 are not active today.** They exist only in `Neo_QWERTZ_full`.
- Neo2 itself (neo-layout.org): 6 layers; L3 = Caps-Lock/Mod3 → programming symbols
  `[]{}()<>?#$~`; L4 = navigation cross + numpad inside the home block, lockable.

### L1 — global hotkeys

- Raycast (3 extensions) — launcher, aliases, window management. Hotkey specifics `[UNVERIFIED]`
  (stored in Raycast's own DB, not a readable config file).
- AltTab — window/tab switching. Default trigger is Option-Tab (chosen upstream to avoid
  Command-Tab). Actual binding `[UNVERIFIED]`.
- Rectangle — window snapping. Stats — menubar metrics.
- Wispr Flow — dictation; injects text into whatever mode is focused.
- **Ghostty has no config** (`~/.config/ghostty/config` absent) → no `keybind`, no
  `global:cmd+backquote=toggle_quick_terminal`, no leader sequences, `macos-option-as-alt` unset.

### L3/L4 — tmux

`~/.config/tmux/tmux.conf` → `/Users/luis/devSetup/config/tmux/tmux.conf`, 3553 B, devSetup-managed.
tpm at `/opt/homebrew/opt/tpm/share/tpm/tpm`.

- Prefix: default `C-b`, unchanged. `bind r` reloads the config.
- `mode-keys vi`; `copy-mode-vi`: `v` begin-selection, `C-h/j/k/l/C-\` pane select.
- **Root-table bindings** (`bind-key -n`) `C-h/C-j/C-k/C-l/C-\` implement vim-tmux-navigator: they
  forward to the pane when it runs vim/nvim/fzf (`is_vim` ps probe), otherwise select a pane.
- Plugins: `tmux-resurrect` + `tmux-continuum` (`@continuum-restore on`, 5-minute save interval),
  `tmux-fingers` (keyboard hint-jumping over pane text), `tmux-open` (`o`, `C-o`, `S` in copy mode),
  `tmux-yank` (`y`/`Y` → pbcopy, OSC 52).
- Terminal plumbing: `default-terminal tmux-256color`, `terminal-features xterm-ghostty:RGB:extkeys`,
  `escape-time 0`, `extended-keys always` + `csi-u`, `allow-passthrough on`, `focus-events on`,
  `set-clipboard on`, `mouse on`, `base-index 1`, `history-limit 50000`.

### L4 — modal layers inside apps

| Surface | Engine | Config | State |
|---|---|---|---|
| Brave | **Vimium** (verified installed: extension `dbepggeogbaibhgnhhndojpepiihcmeb`, 15 extensions in `Default` profile) | browser-profile storage, unversioned `[UNVERIFIED]` | defaults assumed |
| Obsidian | vimrc-support + codemirror-vim | `~/luis_obsidian_vault/.obsidian.vimrc`, 306 B | `H`→`^`, `L`→`$`, `<F9>`→`:nohl<CR>`, `<C-w>h`→`obcommand workspace:split-horizontal`, `jk`/`kj`→Esc in insert |
| VS Code | **VSCodeVim** (emulator) — `vscode-neovim` also installed but unusable | `settings.json` (leader `space`, `jk`→Esc, easymotion) + `keybindings.json`, 18 entries | active |
| Terminal editor | nvim 0.12.5 / vim 9.1 (Apple) | **no `~/.config/nvim`, no `~/.vimrc`** | stock defaults |
| omp prompt | readline-style `tui.editor.*` only; `Ctrl+G` hands the draft to `$VISUAL` (nvim) | no `~/.omp/agent/keybindings.yml` → defaults | no modal editing in-prompt |

### Known collisions

1. **`ctrl+h` / `ctrl+l` — VS Code vs tmux.** `keybindings.json` binds both to
   `workbench.action.terminal.focusPreviousPane`/`focusNextPane` under `when: terminalFocus`, and again
   to `focusLeftGroup`/`focusRightGroup` under `vim.mode == 'Normal'`. tmux binds the same keys in the
   **root** table. Running tmux inside the VS Code integrated terminal, VS Code consumes them first →
   vim-tmux-navigator dies in that context only.
2. **Caps Lock has three claimants**: Neo2 Mod3 (active), Karabiner's canonical `to_if_alone` example,
   and Raycast's Hyper Key (which additionally requires macOS *Modifier Keys → Caps Lock = Caps Lock*).
   Only one can own the key. Raycast documents Karabiner explicitly as an interceptor that breaks its
   Hyper Key (manual.raycast.com/hyper-key.md).
3. **`VSCodeVim` ⟂ `vscode-neovim`** — both register VS Code's `type` command; only one extension may
   own it. vscode-neovim fails with `command 'type' already exists` (its own README).
4. **Karabiner chord semantics** are the documented failure mode of Tab-as-Ctrl setups:
   `from.simultaneous` needs both keys inside 50 ms and silently declines if one is released early;
   `to_if_alone` is cancelled by any other key and cannot key-repeat; `to_if_held_down` reorders events
   against fast typing.
5. **Obsidian 1.7.2+** requires `<CR>` on normal-mode Ex mappings; failures are silent. The current
   vimrc already complies.
6. **Vimium is absent** on `brave://` pages, the extension store, view-source, the PDF viewer and the
   new-tab page, and cannot focus the real omnibox (upstream Chrome restriction).

## Invariants

- One owner per physical key per context. A new binding is checked against this spec's collision list
  before it is added.
- Exactly one Karabiner profile is authoritative for daily work; the others are experiments and must
  say so. Rules left `enabled: false` are not documented as active behaviour.
- Exactly one modal engine per editor surface. Two engines claiming the same `type` command is a defect.
- tmux prefix must not collide with the active Neo2 layers; `send-prefix` moves with any prefix change.
- Every keyboard claim in this file names the file it was read from, or carries `[UNVERIFIED]`.
- A keyboard change is justified by a keystroke or hand-off delta, estimated with the keystroke-level
  model (Card, Moran & Newell, CACM 1980: `K` 0.12–0.20 s, `H` hand-off ≈ 0.40 s, `M` 1.35 s), never by
  "feels faster". KLM carries ~21 % RMS error and assumes expert, error-free execution — state that.

## Gaps

1. Active profile (`Neo_QWERTZ_onlyMod3`) lacks Tab-as-Ctrl and layer 6, while `Neo_QWERTZ_full` has
   them. Which profile is the real one is undecided; 11 of 19 rules across both profiles are disabled.
2. Karabiner config (1 MB) is unmanaged — not in `devSetup`, so the entire Neo2 layer is unreproducible.
3. Ghostty has no config at all: no global quick-terminal hotkey, no keybinds, and
   `macos-option-as-alt` unset on a German layout where Option produces printable characters.
4. `ctrl+h`/`ctrl+l` collision above is unresolved.
5. No Neovim config → the deepest modal surface in the stack runs on stock defaults, and
   `vscode-neovim` (which requires a real nvim config) stays unusable.
6. Insert-mode escape differs per surface: `jk` in VS Code, `jk` **and** `kj` in Obsidian, nothing in
   nvim/vim, nothing in omp's prompt.
7. Vimium and Raycast bindings are unversioned — both live in app-private storage, so neither survives
   a machine rebuild.
8. No keystroke baseline exists for any task, so no keyboard change in this repo can currently be
   justified numerically.
9. Wispr Flow's hotkey and its behaviour when dictating into a modal editor are `[UNVERIFIED]`;
   docs.wisprflow.ai publishes no machine-readable documentation.
