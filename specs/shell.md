# spec: shell

zsh interactive shell, prompt, aliases, toolchain version managers.

## Current

- zsh. `~/.zshrc` is a symlink → `~/devSetup/shell/zsh/.zshrc` — the only symlink `devSetup` applied.
- oh-my-zsh, `plugins=(git)`, theme `robbyrussell`.
- Prompt loaded **twice**: powerlevel10k theme + instant-prompt + `~/.p10k.zsh` (87 KB), then
  `eval "$(starship init zsh)"` later in the file. Starship wins; p10k work is dead cost.
- No `~/.config/starship.toml` → starship runs on defaults.
- Init blocks: fzf, zoxide, pyenv, nvm, fnm (`--use-on-cd`).
- Aliases: `ll=eza -la --git`, `lt=eza --tree --level=2`, `cat=bat`, `grep=rg`, `lg=lazygit`,
  `gs`/`gd`/`gl`/`gcan`, `dps`/`dcl`/`dcu`/`dcd`, `c=clear`, `reveal='open -R'`,
  `cc=claude`, `cr=claude --resume`, `cs=cswap --switch`, `vpn-nbg-r|s|stop`.
- Function `move()`: fzf file pick → `zi` (zoxide interactive) dir pick → `mv`.
- `~/.zprofile`: brew shellenv, PATH += `~/.local/bin`, Obsidian.app CLI dir. **Not** managed by devSetup.
- Node: brew 26.8.1, nvm v22.18.0, fnm shells in `~/.local/state/fnm_multishells`.
  Python: brew 3.14.7, pyenv 3.13.7, plus `uv`. No mise, no asdf, no direnv, no pipx.

## Invariants

- `~/.zshrc` stays a symlink into `devSetup`. Editing the live file directly is a defect.
- Exactly one prompt renderer initialised.
- Exactly one authoritative Node manager; `which node` must be predictable from the directory alone.
- Aliases that shadow a real binary (`cat`, `grep`) must not be assumed present by scripts. Scripts
  call `bat`/`rg` explicitly or the coreutils binary, never the alias.

## Gaps

1. Prompt duplication: p10k + starship. Kill one. Startup cost not yet measured → needs a baseline
   (`for i in $(seq 10); do /usr/bin/time zsh -i -c exit; done`).
2. Three Node managers → nondeterministic `node`.
3. oh-my-zsh loaded for `plugins=(git)` alone. Missing the high-value plugins:
   `zsh-autosuggestions`, `zsh-syntax-highlighting`, `fzf-tab`.
4. `~/.zprofile` unmanaged → not reproducible on a new machine.
5. No `starship.toml`, so prompt content is not version-controlled either.
