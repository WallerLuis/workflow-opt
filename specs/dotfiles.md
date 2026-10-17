# spec: dotfiles

`~/devSetup` — the repo that ships configuration to the machine. Reproducibility and secrets.

## Current

- `~/devSetup`, remote `git@github.com:WallerLuis/devSetup.git`, branch `main`. Last touched ~5 months ago.
- Mechanism: hand-rolled idempotent `link()` in `install.sh` (`ln -s`, pre-existing target moved to
  `~/.dotfiles-backup/<ts>/`). Verified 2026-09-15, extended 2026-09-17: it links
  `shell/zsh/.zshenv`, `shell/zsh/.zshrc`, `config/tmux/tmux.conf`,
  `config/ghostty/config` → `~/.config/ghostty/config`, `config/agents/AGENTS.md` →
  `~/.pi/agent/AGENTS.md` and `~/.claude/CLAUDE.md` (added 2026-10-17, 0010), then runs
  `ghostty +validate-config` (a bad key or unknown theme is otherwise only visible as a GUI error
  dialog on next launch), loops `scripts/bin/*` into `~/.local/bin`, bootstraps tpm on a throwaway
  tmux socket, fetches the `tmux-fingers` release binary into the tpm clone
  (`install-wizard.sh download-binary`, non-interactive — otherwise the plugin opens its wizard on
  first tmux start), and reads `editors/vscode/vscode-extensions.txt` (which exists). The older
  description of it referencing `./configs/` and a root-level `vscode-extensions.txt` is stale.
- `brew bundle` over the stale Brewfile is the slow step: on 2026-09-17 it *adopted* ~11 already
  installed casks (discord, docker-desktop, firefox, gimp, google-chrome, iterm2, notion, obsidian,
  rectangle, surfshark, vlc — receipts written, apps untouched, all predate today) and then ran long
  enough to be interrupted twice. Verifying only the linking steps means shimming `brew bundle` or
  running them directly.
- Tracked and real: `Brewfile` (220 lines, includes ~100 `vscode "…"` extension lines),
  `shell/zsh/.zshrc`, `shell/zsh/.zshenv`, `config/{ghostty,git,nvim,tmux,raycast,ssh}`,
  `config/settings.json`, `editors/vscode`.
- `link()` compares `readlink "$dst"` against an **absolute** `$REPO/...` path. `~/.zshrc` is a
  *relative* symlink (`devSetup/shell/zsh/.zshrc`), so a re-run backs it up and relinks instead of
  reporting `ok`. Cosmetic today, but it makes `install.sh` non-idempotent in output.
- Empty (0 bytes), verified 2026-09-15: `docs/architecture.md`, `docs/recovery.md`,
  `shell/aliases.sh`, `shell/exports.sh`, `secrets/README.md`. No longer empty:
  `docs/bootstrap.md` (1839 B) and `.gitignore` (24 lines — denies `secrets/*`, `*.pem`, `*.key`,
  `id_rsa`, `id_ed25519`, `.env`, `*.swp`, `.DS_Store`), so `shell/exports.sh` is dead weight now
  that env lives in `.zshenv`.
- Empty dirs: `os/macos/`, `languages/rust/`.
- Unmanaged live state: `~/.zprofile`, `~/.gitconfig` (diverged — has aliases + `push.autoSetupRemote`),
  `~/.p10k.zsh`, `~/.config/karabiner/`, `~/.claude/*` (except `CLAUDE.md`), `~/.pi/*` (except
  `agent/AGENTS.md`), `~/.local/bin/*`,
  VS Code `settings.json` / `mcp.json` / `keybindings.json`. (`~/.tmux.conf` no longer exists; the
  XDG path is managed.)

→ ~90 % of the machine is not reproducible. A wipe loses Karabiner Neo2, all agent config,
all `~/.local/bin` scripts, and every VS Code setting.

## Invariants

- One mechanism only. Mixing `link()`, `install.sh` copies, and manual edits is the current failure.
- `.gitignore` is non-empty and denies secrets before any new file is added.
- Anything referenced by `install.sh`/bootstrap must exist; a bootstrap that cannot run clean is broken.
- Secrets never enter the repo. Reference a secret manager (`bitwarden-cli` and `keepassxc` are already
  installed) or an ignored local file.
- `Brewfile` is regenerated, not hand-edited: `brew bundle dump --force`. The `--describe` switch
  named here until 2026-09-17 is **disabled** by current Homebrew ("Calling the `--describe` switch
  is disabled!"); descriptions are the default now. Regeneration today would also absorb 5 months of
  drift (41 lines removed / 81 added), so single-line additions — `cask "ghostty"`, and the removal
  of the duplicate `brew "tmux-fingers"` — were hand-edited on 2026-09-17 and the full regeneration
  is deferred to its own change.

## Gaps

1. Mechanism undecided. Real options, in increasing power:
   - **GNU stow** — `brew install stow`, per-package symlink farms, ~zero config, no templating.
   - **chezmoi** — templating, per-machine variance, encrypted secrets (age/gpg), `chezmoi apply` is
     idempotent. Heaviest but the only one that handles secrets and multiple machines properly.
   - **bare git repo + `$GIT_DIR` alias** — no tool, but no templating and easy to mis-commit.
   - **fix the hand-rolled `link()`** — least new knowledge, keeps the current rot pattern.
   Not decided here. This is a `changes/` decision.
2. ~~Empty `.gitignore` in a repo that also has a `secrets/` folder.~~ — closed 2026-09-15:
   24 lines, denies `secrets/*`, `*.pem`, `*.key`, `id_rsa`, `id_ed25519`, `.env`, `*.swp`, `.DS_Store`.
3. ~~No bootstrap that actually runs on a clean machine~~ — closed 2026-09-15: `install.sh` runs clean
   and is idempotent by design. Still open: **no recovery doc** (`docs/recovery.md` is 0 bytes).
4. No macOS `defaults write` automation → GUI settings are entirely manual.
5. `~/.gitconfig` has diverged from `config/.gitconfig`; no drift detection.
