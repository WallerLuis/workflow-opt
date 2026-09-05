# spec: dotfiles

`~/devSetup` — the repo that ships configuration to the machine. Reproducibility and secrets.

## Current

- `~/devSetup`, remote `git@github.com:WallerLuis/devSetup.git`, branch `main`. Last touched ~5 months ago.
- Mechanism: hand-rolled `link()` helper in `shell/functions.sh` (`ln -snf src → $HOME/dest`), with
  example invocations commented out. **Only `~/.zshrc` was ever linked.**
- Tracked and real: `Brewfile` (216 lines, includes ~100 `vscode "…"` extension lines),
  `shell/zsh/.zshrc`, `config/{git,nvim,tmux,raycast,ssh}`, `config/settings.json`, `editors/vscode`.
- Broken: `install.sh` copies `./configs/.*`, `./scripts/*`, reads `./vscode-extensions.txt` — the repo
  has `config/`, `scripts/bin/`, and no such txt file.
- Empty (0 bytes): `docs/architecture.md`, `docs/bootstrap.md`, `docs/recovery.md`,
  `shell/aliases.sh`, `shell/exports.sh`, `secrets/README.md`, **`.gitignore`**.
- Empty dirs: `os/macos/`, `languages/rust/`.
- Unmanaged live state: `~/.zprofile`, `~/.gitconfig` (diverged — has aliases + `push.autoSetupRemote`),
  `~/.tmux.conf`, `~/.p10k.zsh`, `~/.config/karabiner/`, `~/.claude/*`, `~/.local/bin/*`,
  VS Code `settings.json` / `mcp.json` / `keybindings.json`.

→ ~90 % of the machine is not reproducible. A wipe loses Karabiner Neo2, all agent config,
all `~/.local/bin` scripts, and every VS Code setting.

## Invariants

- One mechanism only. Mixing `link()`, `install.sh` copies, and manual edits is the current failure.
- `.gitignore` is non-empty and denies secrets before any new file is added.
- Anything referenced by `install.sh`/bootstrap must exist; a bootstrap that cannot run clean is broken.
- Secrets never enter the repo. Reference a secret manager (`bitwarden-cli` and `keepassxc` are already
  installed) or an ignored local file.
- `Brewfile` is regenerated, not hand-edited: `brew bundle dump --describe --force`.

## Gaps

1. Mechanism undecided. Real options, in increasing power:
   - **GNU stow** — `brew install stow`, per-package symlink farms, ~zero config, no templating.
   - **chezmoi** — templating, per-machine variance, encrypted secrets (age/gpg), `chezmoi apply` is
     idempotent. Heaviest but the only one that handles secrets and multiple machines properly.
   - **bare git repo + `$GIT_DIR` alias** — no tool, but no templating and easy to mis-commit.
   - **fix the hand-rolled `link()`** — least new knowledge, keeps the current rot pattern.
   Not decided here. This is a `changes/` decision.
2. Empty `.gitignore` in a repo that also has a `secrets/` folder.
3. No bootstrap that actually runs on a clean machine, and no recovery doc.
4. No macOS `defaults write` automation → GUI settings are entirely manual.
5. `~/.gitconfig` has diverged from `config/.gitconfig`; no drift detection.
