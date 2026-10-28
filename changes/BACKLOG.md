# BACKLOG

Candidate changes, ordered by leverage ÷ effort **within each bucket**. Not decisions — a candidate
becomes a decision only when it gets a `changes/NNNN-slug.md` file. Every entry names the spec it would
mutate and the gap it closes.

Leverage: **H** = changes daily work or removes a real risk. **M** = removes friction. **L** = nice.
Keyboard-first is the tie-breaker: a candidate that removes keystrokes or mouse hand-offs outranks one
that only tidies.

## Now

| # | Candidate | Spec | Gap | Lev | Effort |
| --- | --- | --- | --- | --- | --- |
| 1 | Rotate + purge the API keys in the vault and in `Code/User/mcp.json` | knowledge, agent-stack | knowledge#1, SYSTEM Hygiene 1–2 | H | 30 min |
| 13 | Turn off Warp telemetry + cloud conversation storage, or uninstall Warp and iTerm2 | terminal | terminal#3 | M | 10 min |
| 7 | Disable the three retired Obsidian sync plugins (Syncthing owns the vault, decided 0004) | knowledge | knowledge#2 | H | 20 min |
| 21 | Bind Ghostty's quick terminal (`keybind = global:cmd+backquote=toggle_quick_terminal`) — the config has **zero** keybind lines today; needs Accessibility permission | terminal, keyboard | terminal#1, keyboard#3 | H | 20 min |
| 22 | Resolve the `ctrl+h`/`ctrl+l` collision: VS Code `terminalFocus` binds vs tmux root-table vim-tmux-navigator | keyboard, editor | keyboard#4, editor#3 | H | 30 min |
| 23 | Decide one Karabiner profile (`Neo_QWERTZ_onlyMod3` vs `Neo_QWERTZ_full`) and enable or delete the 11 disabled rules; Tab-as-Ctrl is currently documented but inactive | keyboard | keyboard#1 | H | 1 h |
| 24 | Bring `~/.config/karabiner/` under `devSetup` — 1 MB of Neo2 layers, the foundation of the whole stack, unreproducible | keyboard, dotfiles | keyboard#2, dotfiles#1 | H | 1 h |
| 5 | Kill the prompt duplication (p10k vs starship); measure `zsh -i -c exit` before and after | shell | shell#1 | M | 1 h |
| 6 | Pick one Node manager, remove the other two | shell | shell#2 | M | 1 h |
| 3 | Decide the dotfiles mechanism (stow vs chezmoi vs bare git vs keep `link()`); fix `link()`'s absolute-vs-relative `readlink` compare | dotfiles | dotfiles#1 | H | half day |
| 4 | Bring the rest of the unmanaged 90 % under `devSetup`: `.zprofile`, `.gitconfig`, `~/.local/bin/*`, VS Code settings, `~/.pi`, `~/.claude` | dotfiles | dotfiles#1 | H | half day |

## Next

| # | Candidate | Spec | Gap | Lev | Effort |
| --- | --- | --- | --- | --- | --- |
| 25 | Document the rest of the second brain: capture paths (QuickAdd, Quick Note, daily `# Tasks`), daily-note/periodic flow, plugin roles — into the conventions note or Obsidian MOC. Conventions, PARA, MOC/Parent discipline done in 0008 | knowledge | knowledge#8 | M | 2 h |
| 14 | Decide Neovim: real config (it is `$EDITOR`/`$VISUAL` and pi's `Ctrl+G` target, still stock defaults) vs uninstall `vscode-neovim` and stay on VSCodeVim. First win: an autocmd for the harness's prompt-draft temp files | editor | editor#1, editor#2 | H | half day |
| 11 | tmux session workflow for parallel agent runs — nothing auto-attaches since the Ghostty `command` line was dropped, so sessions are started by hand; pick a session-per-project picker (`sesh`/sessionizer) and check its prefix against the Neo2 layers | terminal, keyboard | terminal#4 | H | 2 h |
| 26 | Keystroke baseline: instrument the five most repeated tasks (open project, switch pane, jump to file, capture a note, start an agent) with the keystroke-level model, so keyboard changes can be justified numerically | keyboard | keyboard#8 | H | 2 h |
| 33 | Decide the always-on budget: measured **1969 tok** (`AGENTS.md` 1752 + 6 metadata lines 217) vs 0004's ≤1200 target. Candidates: drop `AGENTS.md` → Verification (116 tok, restates the `verify-repo` skill), compress Repo map (223) and Stack of record (278) into one table. The Obsidian-vault section (229) stays — secret hazard must precede any vault read | agent-stack | agent-stack#9 | M | 1 h |
| 8 | Convert `~/.claude/commands/write-ticket.md` (9.7 KB) into a skill with a short body + reference files | agent-stack | agent-stack#5 | M | 1 h |
| 27 | Assert the deterministic gates in CI-of-one: hook executable, commit/push denial actually fires (currently only presence is checked) | agent-stack | agent-stack#3 | M | 1 h |
| 9 | Consolidate MCP: one declared set, keys out of plaintext, shared across pi and Claude Code | agent-stack | agent-stack#4 | M | half day |
| 34 | Narrow pi project trust: `~/.pi/agent/trust.json` trusts all of `/Users/luis/home/luis`, so any clone below it auto-loads its `.pi/extensions/` | agent-stack | agent-stack#11 | M | 10 min |
| 15 | oh-my-zsh plugin set: `zsh-autosuggestions`, `zsh-syntax-highlighting`, `fzf-tab` | shell | shell#3 | M | 30 min |
| 28 | Version the desktop keyboard layer: Vimium options export, Raycast hotkey/alias list, AltTab + Rectangle prefs → `devSetup` | desktop, keyboard | desktop#1, keyboard#7 | M | 2 h |
| 29 | Verify Nextcloud: account, server, synced folders; prove no overlap with the vault tree | desktop | desktop#2 | M | 30 min |
| 34 | Migrate `~/Nextcloud` to the spec: pilot `Important/Gesundheit` + `Arzt` (14 files), then one root per session; move 80 Git repos + `node_modules` out to the local code root with Git remotes + a safety-net backup (Time Machine or restic) for uncommitted experiments. Needs approval | nextcloud | nextcloud#1–3 | H | days |
| 46 | Exact copy from pi: commands copied from pi's screen carry pi's own wraps (`\n`) + indent; build `/cb [n]` code-block copy extension. Research + options in [`0013-exact-copy-from-pi.md`](0013-exact-copy-from-pi.md) (draft); pi 1.4.0 does not fix it | agent-stack, terminal | see 0013 | H | 1 h |
| 45 | Keyboard access to OSC 8 links: since 0012 pi renders markdown links as text only (URL in the cell, not on screen), so `C-b F` (tmux-fingers, regex on visible text) can't reach them — Cmd+Shift+click only. Candidates: tmux binding over `#{mouse_hyperlink}` / copy-mode hyperlink, fingers custom pattern, or pi-side setting to print the URL | terminal, keyboard | terminal#6 (appended when 0012 closes) | M | 30 min |
| 35 | Test internal link `/f/<fileid>` across rename/move (desktop + iPhone); audit all link shares on the server (5 referenced in vault notes); revoke or set expiry | nextcloud | nextcloud#4–5 | M | 30 min |

## Later

| # | Candidate | Spec | Gap | Lev | Effort |
| --- | --- | --- | --- | --- | --- |
| 30 | Reboot drill: prove tmux resurrect/continuum restores the working set | terminal | terminal#5 | M | 30 min |
| 17 | Git-worktree workflow for parallel agents | terminal, agent-stack | agent-stack#6 | M | half day |
| 16 | Golden-task evals for the rules and skills in this repo | agent-stack | agent-stack#6 | M | days |
| 18 | Fill the vault topic gaps: SDD, verification loops, evals, dotfiles-as-repo, PARA/Zettelkasten method, keyboard-first/KLM | knowledge | knowledge#4 | M | ongoing |
| 19 | Strip unrendered `<% tp… %>` Templater syntax from vault notes; fix the broken Prompt-Engineering MOC link | knowledge | knowledge#5–6 | L | 1 h |
| 20 | macOS `defaults write` automation: function-key behaviour, Caps-Lock mapping, Spaces auto-rearrange — the settings the keyboard layer silently depends on | dotfiles, desktop | dotfiles#4, desktop#6 | L | half day |
| 31 | Decide tiling: keep Rectangle vs AeroSpace (no SIP change, emulates its own workspaces) vs yabai (partial SIP disable) vs Amethyst | desktop | desktop#3 | L | half day |
| 32 | Audit the 15 Brave extensions and ~100 VS Code extensions against actual use | desktop, editor | desktop#5, editor#6 | L | 1 h |
| 36 | Phone access to the agent stack: a pi instance reachable from the iPhone (remote host + SSH/tmux client or web front-end) for research that today runs in ChatGPT, able to write into a repo. Conventions editing on phone explicitly **out of scope** | agent-stack | agent-stack#12 | M | days |
| 37 | `scripts/vault-lint.sh` (read-only): count violations per MUST rule of the vault conventions (size, frontmatter keys, `Parent`, `<% tp`, legacy inline fields, unresolved `[[Daily Notes]]`) | knowledge | knowledge#10 | M | 1–2 h |
| 38 | `Parent` backfill: script proposes `Parent` = the single MOC linking a note (283 notes), Luis picks for the 44 multi-MOC notes; batch approval, backup first. Target 106 → ~433 filled | knowledge | knowledge#11 | H | 1–2 h |
| 39 | Obsidian CLI for agents: test search / backlinks / properties via `obsidian` CLI; if it works, document in `vault-note` skill as preferred retrieval over grep. After BACKLOG 1 (secrets) | knowledge, agent-stack | knowledge#12 | M | 1–2 h |
| 40 | Inbox skill: process `900 Quick Note` (57) — propose folder, `Parent`, split; Luis confirms each | knowledge | knowledge#13 | M | 1 h |
| 41 | Summary-first reading: rule in conventions (agents read `# Summary` before the body); Luis writes summaries, agent may draft on request (280 empty) | knowledge | knowledge#14 | M | 5 min + ongoing |
| 42 | Quiz-me skill: agent asks ~5 questions on a note/section, Luis answers closed-book, gaps → note or flashcards (retrieval practice, Roediger & Karpicke 2006) | knowledge | knowledge#15 | H | 1 h |
| 43 | Session → vault distill: `vault-note distill` action — agent drafts one section with context links from the session, Luis edits | knowledge | knowledge#16 | M | 30 min |
| 44 |  Secret importing evaluation & storage: api keys, bitwarden connect etc. | knowledge, agent-stack, dev-experience | knowledge#17 | H | 60 min |
