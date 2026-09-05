# SYSTEM.md — current machine state

Reference. Verified 2026-09-05 by read-only inspection of the live filesystem. Not auto-loaded.
When a `changes/` file lands, update the affected section here and in the matching `specs/*.md`.

Machine: MacBook, Apple M4 Pro, Darwin 24.2.0 (macOS), arm64.

## Substrate

- Homebrew at `/opt/homebrew`. ~155 formulae, ~50 casks.
- Declarative manifest: `~/devSetup/Brewfile` (216 lines, includes ~100 `vscode "…"` extension lines).
- Toolchains: node 26.8.1 (brew) **and** v22.18.0 (nvm) **and** fnm; python 3.14.7 (brew) + pyenv 3.13.7; `uv`.
  No Go, no Rust. → three Node managers, `node` is nondeterministic.

## Shell

- zsh. `~/.zshrc` is a symlink → `~/devSetup/shell/zsh/.zshrc` (the only link `devSetup` ever applied).
- oh-my-zsh, `plugins=(git)` only. No autosuggestions, no syntax-highlighting, no fzf-tab.
- Prompt: powerlevel10k sourced (`~/.p10k.zsh`, 87 KB) **then** `starship init zsh`. Starship wins;
  the p10k instant-prompt block and config are dead startup cost. No `~/.config/starship.toml`.
- Modern CLI aliases: `eza`, `bat`, `rg`, `lazygit`, `zoxide`, `fzf`, `git-delta`.
- `move()` = fzf file pick → `zi` dir pick → `mv`.
- `~/.zprofile` (brew shellenv, `~/.local/bin`, Obsidian CLI path) is **not** managed by `devSetup`.

## Terminal / multiplexer

- Installed: Ghostty (no config), iTerm2, Warp. Warp has telemetry + cloud conversation storage **on**.
- tmux: `~/.tmux.conf` is 3 lines (vi mode, mouse, 100k history). No tpm, no prefix remap,
  no session picker. → no session-persistence story.

## Editors

- VS Code + VSCodeVim (leader `space`, `jk`→Esc, easymotion), relative numbers, format-on-save/prettier,
  JetBrains Mono, telemetry off. ~100 extensions incl. `asvetliakov.vscode-neovim`.
- **No `~/.config/nvim`** — vim keybindings everywhere (VS Code, Claude Code `editorMode: vim`, tmux,
  Obsidian vimrc-support) but no actual Neovim config. `vscode-neovim` therefore unusable.
- No Cursor. Windsurf installed but stale. No JetBrains.

## Agent stack

| Tool | Config | State |
| --- | --- | --- |
| Claude Code 2.1.236 | `~/.claude/settings.json` | model `opus[1m]`, effort medium, vim mode, custom statusline, auto-memory **off** |
| Codex | `~/.codex/config.toml` | one trusted project, no model config; heavy use (10 MB log db) |
| opencode | `~/.config/opencode` | package.json only |
| omp (this harness) | `~/.omp` | — |
| copilot-cli, pi-coding-agent, devin-desktop | — | installed |

- `~/.claude/commands/write-ticket.md` is the **only** custom command. Zero skills, zero subagents,
  zero hooks, no user-level `~/.claude/CLAUDE.md`.
- MCP is fragmented: Claude global → `n8n`; one Claude project → `dbhub`; VS Code → `context7`,
  `appwrite-docs`. No shared set across agents.
- `~/.local/bin/`: `claude-swap`/`cswap` (account switch, aliased `cs`), `gittum`,
  `kb_2_vanilla` / `kb_2_neo_mod3` / `kb_2_neo_full` (Karabiner profile switchers), `hf`, `tiny-agents`.

## Keyboard / window management

- Karabiner-Elements, 1 MB config, 2 profiles: German **Neo2** emulation (mod3/mod4/layer6),
  Tab-as-Ctrl-when-chorded, both-shifts→caps toggle. Several rules `enabled: false`.
- Raycast (3 extensions), Rectangle, AltTab, Stats, Wispr Flow (voice).
- No Hammerspoon, no Alfred, no yabai/aerospace/skhd, no `defaults write` automation.

## Knowledge layer

- Obsidian vault `~/luis_obsidian_vault`, ~2240 notes, PARA-style numeric folders
  (`000 Index`, `100 Projects - now`, `200 Areas - longterm`, `300 Resources - future`,
  `400 Archive`, `600 Knowledge`, `800 Daily Notes`, `901 Template`, `950 Scripts`).
- Sync: **Syncthing** (`.stfolder/`). Also installed and redundant: obsidian-git, obsidian-livesync,
  remotely-save, local-backup → conflict surface. 60+ community plugins (dataview, templater, tasks,
  periodic-notes, excalidraw, latex-suite, vimrc-support, quickadd).
- Existing agentic-coding knowledge cluster:
  `600 Knowledge/Software-IT - General/Agentic Development - Prompting/` (5 notes, newest 2026-09-04).
- Note conventions: see `GLOSSARY.md`.

## Dotfiles repo — `~/devSetup`

`git@github.com:WallerLuis/devSetup.git`, branch `main`, hand-rolled `link()` symlink helper
(not chezmoi/stow/yadm). **Broken and abandoned ~5 months:**

- `install.sh` references `./configs/`, `./scripts/*`, `./vscode-extensions.txt` — none exist
  (repo has `config/`, `scripts/bin/`, extensions live in the Brewfile).
- `docs/{architecture,bootstrap,recovery}.md`, `shell/{aliases,exports}.sh`, `secrets/README.md`,
  and `.gitignore` are all **0 bytes**.
- Managed: `Brewfile`, `shell/zsh/.zshrc` (live symlink), `config/{git,nvim,tmux,raycast,ssh}`.
- **Unmanaged live state:** `~/.zprofile`, `~/.gitconfig` (diverged: aliases + `push.autoSetupRemote`),
  `~/.tmux.conf`, `~/.p10k.zsh`, `~/.config/karabiner/`, `~/.claude/*`, `~/.local/bin/*`,
  VS Code `settings.json`/`mcp.json`. → ~90 % of the machine is not reproducible.

## Hygiene flags

1. `~/Library/Application Support/Code/User/mcp.json` embeds a **context7 API key in plaintext**.
2. Vault note `100 Projects - now/150 Own Projects-wishlist/AI agents/AI agents - MOC.md` contains
   what look like **live OpenAI + Telegram API keys**; `Windows to linux switch.md` holds a Brave sync phrase.
3. `~/devSetup/.gitignore` is empty → nothing ignored in the dotfiles repo.
4. Warp: telemetry + cloud conversation storage enabled.
5. `~/.claude/statusline-command.sh` depends on `jq`; `jq` was not found in the brew formula list. `[UNVERIFIED]`
6. Unmanaged secret files exist under `~/freelancing/secrets/`, `~/home/luis/italysasse/secrets/`,
   `tum-moodle-downloader/credentials.json`, `ItalySasseRemarke/.env.production`. Contents not read.
