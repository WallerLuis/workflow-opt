# spec: desktop

Browser, launcher, window layer, dictation, file sync. The GUI surfaces the keyboard has to drive.
Bindings themselves: `specs/keyboard.md`.

## Current

Verified 2026-09-17 by reading `/Applications` and app support directories.

| Tool | Role | Config state |
|---|---|---|
| **Brave Browser** | browser of record | 15 extensions in the `Default` profile, incl. **Vimium** (`dbepggeogbaibhgnhhndojpepiihcmeb`), Claude, Raycast Companion, Toggl Track, Snowflake, TanStack Query DevTools, Paper2Audio, Apollo.io, ChatGPT LaTeX Copy Tool. Extension settings live in browser-profile storage → unversioned |
| **Raycast** | launcher, aliases, window management | 3 extensions. Hotkeys/aliases stored in Raycast's own database, not a readable file → `[UNVERIFIED]`, unversioned |
| **AltTab** | window / tab switching | preferences unversioned; actual trigger `[UNVERIFIED]` (upstream default is Option-Tab) |
| **Rectangle** | window snapping | unversioned |
| **Stats** | menubar system metrics | unversioned |
| **Wispr Flow** | dictation | unversioned; no machine-readable vendor docs → hotkey and modal-editor behaviour `[UNVERIFIED]` |
| **Nextcloud** | primary file drive, self-hosted | `/Applications/Nextcloud.app` present; **neither** `~/Library/Preferences/com.nextcloud.desktopclient.nextcloud.plist` **nor** `~/Library/Application Support/Nextcloud/nextcloud.cfg` exists → sync folders, server URL and account state not verified |
| **Obsidian** | second brain | vault synced by **Syncthing**, not Nextcloud — see `specs/knowledge.md` |

- Not installed: Hammerspoon, Alfred, yabai, AeroSpace, skhd, Amethyst. No `defaults write` automation.
- Division of storage, decided 2026-09-17: **Syncthing owns the Obsidian vault; Nextcloud owns files.**
  The two must never manage the same directory.

## Invariants

- One tool per role. Two tools claiming the same hotkey or the same directory is a defect.
- Exactly one sync mechanism per directory tree. Vault → Syncthing. Files → Nextcloud.
- A GUI tool that is load-bearing for the keyboard workflow (launcher, switcher, snapping, dictation)
  must have its bindings written down here or in `specs/keyboard.md`, because none of them are
  version-controlled.
- Window management stays SIP-compatible: no tool requiring System Integrity Protection to be disabled
  is installed without an explicit change recording that decision.

## Gaps

1. Every tool in the table is unmanaged: Raycast, AltTab, Rectangle, Stats, Wispr Flow and Vimium keep
   their configuration in app-private storage. A machine rebuild loses the entire desktop keyboard
   layer, and nothing here is reproducible.
2. Nextcloud's own configuration was not found at either documented path → account, server and synced
   folders are `[UNVERIFIED]`. No verification that it does not overlap the vault.
3. No decision on tiling: Rectangle (snapping, manual) vs a real keyboard-driven tiler. The documented
   tradeoff is SIP — AeroSpace requires no SIP change and emulates its own workspaces (it cannot move
   windows between macOS Spaces by hotkey, no public API); yabai needs partial SIP disable for space
   manipulation; Amethyst and Raycast Window Management need only Accessibility. Not decided here.
4. Wispr Flow injects text into whichever mode is focused; interaction with normal mode in Obsidian,
   VS Code and nvim is undocumented and untested.
5. Brave extension set never audited: 15 extensions, several unrelated to the current workflow.
6. No macOS `defaults write` automation, so system-level keyboard settings that the stack depends on
   (function-key behaviour, Caps-Lock mapping, Spaces auto-rearrange) are set by hand and undocumented.
