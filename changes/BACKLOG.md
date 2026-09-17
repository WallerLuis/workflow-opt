# BACKLOG

Candidate changes, ranked by leverage ÷ effort. Not decisions — a candidate becomes a decision only
when it gets a `changes/NNNN-slug.md` file. Every entry names the spec it would mutate and the gap it closes.

Leverage: **H** = changes daily work or removes a real risk. **M** = removes friction. **L** = nice.

## Now

| # | Candidate | Spec | Gap | Lev | Effort |
| --- | --- | --- | --- | --- | --- |
| 1 | Rotate + purge the API keys in the vault and in `Code/User/mcp.json` | knowledge, agent-stack | knowledge#1, SYSTEM Hygiene 1–2 | H | 30 min |
| 2 | Write `~/.claude/CLAUDE.md` (user scope): concision, learning contract, vim, evidence hierarchy — sourced from the vault's AI-Personalisation note | agent-stack | agent-stack#1 | H | 30 min |
| 3 | Decide the dotfiles mechanism (stow vs chezmoi vs bare git vs keep `link()`); fix `link()`'s absolute-vs-relative `readlink` compare. `.gitignore` and a runnable `install.sh` are **done** (verified 2026-09-15) | dotfiles | dotfiles#1 | H | half day |
| 4 | Bring the unmanaged 90 % under `devSetup`: `.zprofile`, `.gitconfig`, `.tmux.conf`, `karabiner/`, `~/.local/bin/*`, VS Code settings | dotfiles | dotfiles#1 | H | half day |
| 5 | Kill the prompt duplication (p10k vs starship); measure `zsh -i -c exit` before and after | shell | shell#1 | M | 1 h |
| 6 | Pick one Node manager, remove the other two | shell | shell#2 | M | 1 h |
| 7 | Pick one vault sync mechanism; disable the other three plugins | knowledge | knowledge#2 | H | 1 h |

## Next

| # | Candidate | Spec | Gap | Lev | Effort |
| --- | --- | --- | --- | --- | --- |
| 8 | Convert `~/.claude/commands/write-ticket.md` (9.7 KB) into a skill with a short body + reference files | agent-stack | agent-stack#5 | M | 1 h |
| 9 | Consolidate MCP: one declared set, keys out of plaintext, shared across Claude/Codex/opencode | agent-stack | agent-stack#4 | M | half day |
| 10 | A verification check this repo can hand an agent: link resolution + `specs/` ↔ `SYSTEM.md` drift | agent-stack | agent-stack#6 | H | 2 h |
| 11 | tmux session workflow for parallel agent runs (Ghostty runs one shared `-s dev` session — every window mirrors it); check prefix against the Neo2/Tab-as-Ctrl conflict map | terminal | terminal#4 | H | 2 h |
| 12 | Retire one of the three emulators — Ghostty config itself is **done** (`changes/archive/0003`); also bind Ghostty's quick terminal | terminal, keyboard | terminal#1, terminal#3 | M | 30 min |
| 13 | Turn off Warp telemetry + cloud conversation storage, or drop Warp | terminal | terminal#3 | M | 10 min |
| 14 | Decide Neovim: real config (now load-bearing — it is `$EDITOR`/`$VISUAL` and omp's `Ctrl+G` target, still stock defaults), or uninstall `vscode-neovim` and stay on VSCodeVim. First win: `*.omp.md` autocmd for prompt drafts | — (needs `specs/editor.md`) | SYSTEM Editors | H | half day |
| 15 | oh-my-zsh plugin set: `zsh-autosuggestions`, `zsh-syntax-highlighting`, `fzf-tab` | shell | shell#3 | M | 30 min |

## Later

| # | Candidate | Spec | Gap | Lev | Effort |
| --- | --- | --- | --- | --- | --- |
| 16 | Golden-task evals for the skills in this repo | agent-stack | agent-stack#7 | M | days |
| 17 | Git-worktree workflow for parallel agents | terminal, agent-stack | knowledge#4 | M | half day |
| 18 | Fill the vault topic gaps: SDD, verification loops, evals, dotfiles-as-repo, PARA/Zettelkasten method | knowledge | knowledge#4 | M | ongoing |
| 19 | Strip unrendered `<% tp… %>` Templater syntax from vault notes; fix the broken Prompt-Engineering MOC link | knowledge | knowledge#5–6 | L | 1 h |
| 20 | macOS `defaults write` automation; decide on a real window manager (aerospace/yabai) vs Rectangle | dotfiles | dotfiles#4 | L | half day |
