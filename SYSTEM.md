# SYSTEM.md — machine state

Machine-wide snapshot: what is installed, what is retired, what is a hazard. Per-domain detail lives in
`specs/*.md`; when the two disagree, re-verify against the machine and fix both. Not auto-loaded.

Machine: MacBook, Apple M4 Pro, Darwin 24.2.0 (macOS), arm64.

## Stack of record

Verified 2026-09-17 unless the row says otherwise.

| Layer | In use | Config location | Managed by devSetup? |
|---|---|---|---|
| Agent harness | pi (`pi-coding-agent` 1.0.0) — `defaultProvider: openai-codex`, `defaultModel: gpt-5.6-terra`, package `@gotgenes/pi-anthropic-auth`; trust entry `/Users/luis/home/luis` | `~/.pi/agent/settings.json` (584 B), `trust.json` | no |
| Agent harness | Claude Code CLI 2.1.285 — `opus[1m]`, effort medium, vim mode, custom statusline, auto-memory off | `~/.claude/settings.json` | no |
| Model providers | Claude (`anthropic`), Codex (`openai`) | provider credentials | no |
| Keyboard | Karabiner-Elements, active profile `Neo_QWERTZ_onlyMod3` (Neo2 mod3 + mod4 Home/End + both-shifts caps) | `~/.config/karabiner/karabiner.json` (1004 KB, 3 profiles) | **no** |
| Terminal | Ghostty 1.3.1 — `macos-option-as-alt = left`, `shell-integration = zsh` + `cursor,title,path,ssh-env,ssh-terminfo`; no `command`, no theme/font overrides (all Ghostty defaults) | `~/.config/ghostty/config` → `devSetup/config/ghostty/config` (678 B) | **yes** |
| Multiplexer | tmux 3.7c — `xterm-ghostty:RGB:extkeys` via `terminal-features`, `focus-events on`, `set-clipboard on`, `allow-passthrough on`, `extended-keys always`; tpm, resurrect + continuum (restore on, 5-min), fingers (tpm-owned binary), open, yank; vim-tmux-navigator root binds | `~/.config/tmux/tmux.conf` → `devSetup/config/tmux/tmux.conf` (3553 B) | **yes** |
| Editor | VS Code + VSCodeVim (~100 extensions) | `~/Library/Application Support/Code/User/{settings,keybindings,mcp}.json` | no |
| Editor | nvim 0.12.5 (`$EDITOR`/`$VISUAL`), vim 9.1 (Apple) | **no `~/.config/nvim`, no `~/.vimrc`** | n/a |
| Shell | zsh + oh-my-zsh (`plugins=(git)`) | `~/.zshrc`, `~/.zshenv` → `devSetup/shell/zsh/` | yes (2 files) |
| Browser | Brave + Vimium (15 extensions, `Default` profile) | browser-profile storage | no |
| Desktop | Raycast (3 ext.), AltTab, Rectangle, Stats, Wispr Flow | app-private storage | no |
| Files | Nextcloud, self-hosted | config not found at either documented path `[UNVERIFIED]` | no |
| Second brain | Obsidian vault `~/luis_obsidian_vault`, ~2240 notes, **Syncthing**-synced, 60+ plugins | vault + `.obsidian/` | no |
| Toolchains | node 26.8.1 (brew) **and** v22.18.0 (nvm) **and** fnm; python 3.14.7 (brew) + pyenv 3.13.7; `uv`. No Go, no Rust | — | Brewfile only |
| Substrate | Homebrew `/opt/homebrew`, ~155 formulae / ~50 casks; `jq` at `/usr/bin/jq` (Apple) | `~/devSetup/Brewfile` (216 lines, ~100 `vscode` lines) | yes |
| Dotfiles | `~/devSetup`, `git@github.com:WallerLuis/devSetup.git`, hand-rolled `link()` | `install.sh` | — |

`~/.local/bin/`: `claude-swap`/`cswap` (aliased `cs`), `gittum`, `kb_2_vanilla` / `kb_2_neo_mod3` /
`kb_2_neo_full` (Karabiner profile switchers), `hf`, `tiny-agents`.

**Unmanaged live state** — lost on a wipe: `~/.zprofile`, `~/.gitconfig` (diverged: aliases +
`push.autoSetupRemote`), `~/.p10k.zsh`, `~/.config/karabiner/`, `~/.claude/*`, `~/.pi/*`,
`~/.local/bin/*`, VS Code settings/keybindings/mcp, every desktop app's preferences, Vimium, Raycast.
→ ~90 % of the machine is not reproducible.

## Retired — installed, not in the workflow

Remove from the machine, then delete the row.

| Tool | Why retired | Since |
|---|---|---|
| iTerm2, Warp | Ghostty is the emulator of record. Warp also ships telemetry + cloud conversation storage | 2026-09-17 |
| Windsurf | stale; VS Code + nvim cover editing | 2026-09-17 |
| omp, opencode, copilot-cli, devin-desktop | pi + Claude Code CLI are the harnesses (omp retired 2026-10-13, `changes/archive/0006-*`) | 2026-10-13 |
| powerlevel10k (theme + instant prompt + 87 KB `~/.p10k.zsh`) | starship initialises later in `.zshrc` and wins; p10k work is dead startup cost | 2026-09-17 |
| two of three Node managers (brew / nvm / fnm) | `node` is nondeterministic; one must own it. Which one: undecided (`specs/shell.md` gap 2) | — |
| obsidian-git, obsidian-livesync, remotely-save, local-backup | Syncthing owns the vault; four mechanisms over one folder is a conflict surface | 2026-09-17 |
| `vscode-neovim` **or** VSCodeVim | both register VS Code's `type` command; only one can run (`specs/editor.md` gap 2) | — |
| MCP: `n8n`, `dbhub`, `appwrite-docs` | fragmented per agent and per project, no shared set; keep only what is used | — |

## Hygiene

1. `~/Library/Application Support/Code/User/mcp.json` embeds a **context7 API key in plaintext**.
2. Vault note `100 Projects - now/150 Own Projects-wishlist/AI agents/AI agents - MOC.md` contains what
   look like **live OpenAI + Telegram API keys**; `Windows to linux switch.md` holds a Brave sync phrase.
   Rotate and purge.
3. ~~`~/devSetup/.gitignore` is empty~~ — closed 2026-09-15: 24 lines, denies `secrets/*`, `*.pem`,
   `*.key`, `id_rsa`, `id_ed25519`, `.env`, `*.swp`, `.DS_Store`.
4. Warp: telemetry + cloud conversation storage enabled (retire the app to close this).
5. ~~`jq` missing for `~/.claude/statusline-command.sh`~~ — closed 2026-09-17: `/usr/bin/jq` exists
   (Apple-shipped, absent from the brew formula list).
6. Unmanaged secret files under `~/freelancing/secrets/`, `~/home/luis/italysasse/secrets/`,
   `tum-moodle-downloader/credentials.json`, `ItalySasseRemarke/.env.production`. Contents not read.
7. Karabiner config (1 MB) and every desktop-app preference are unmanaged → the keyboard layer, which
   the whole workflow rests on, cannot be rebuilt.
