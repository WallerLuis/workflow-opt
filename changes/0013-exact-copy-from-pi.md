# 0013 — exact-copy-from-pi

- status: draft
- domain: specs/agent-stack.md, specs/terminal.md
- opened: 2026-10-28
- closed: —

## Problem

Commands copied from pi (tmux pane in Ghostty) contain spurious line breaks and leading spaces;
Luis has to remove them by hand before running them. Reported 2026-10-28; same root cause as the
wrapped-URL bug in `changes/0012-pi-clickable-wrapped-links.md`.

Mechanism, verified in pi 1.3.0 source
(`/opt/homebrew/Cellar/pi-coding-agent/1.3.0/libexec/lib/node_modules/@earendil-works/pi-coding-agent/`,
`pi-tui` = `node_modules/@earendil-works/pi-tui/dist/`):

| Fact | Evidence |
| --- | --- |
| pi runs in fullscreen (alternate screen) | `~/.pi/agent/settings.json`: `"tuiMode": "fullscreen"` |
| pi disables terminal autowrap and wraps every row itself | `pi-tui/tui-alt-screen.js:194` writes `DISABLE_AUTOWRAP` on start |
| → tmux and Ghostty only ever see hard rows; there is no soft-wrap flag to rejoin | consequence of the row above |
| pi's own mouse selection joins screen rows with `\n` | `pi-tui/tui-alt-screen.js:1198-1219` `getActiveSelectionText()` |
| Leading spaces: transcript padding + code-block indent | `docs/settings.md:103` `outputPad` default `1`; `pi-tui/components/markdown.js:393` `codeBlockIndent ?? "  "` |
| Exact (source-text) copy paths exist | `/copy` "Copy the last assistant message" (`docs/slash-commands.md:37`); `app.message.copy` `ctrl+x` (`docs/keybindings.md:165`) |
| Extension API covers a custom copy command | `pi.registerCommand`, `pi.registerShortcut` (`docs/extensions.md:23,79`), `ctx.sessionManager.getBranch()` (`:236`), `copyToClipboard` (`dist/utils/clipboard.js:87`) |

Conclusion: every path that reads the **screen** (pi drag-select, tmux copy-mode, Ghostty
Shift+drag) cannot tell a pi wrap from a real newline. Only paths that read the **message source**
are exact.

pi 1.4.0 checked 2026-10-28 (`npm pack @earendil-works/pi-coding-agent@1.4.0`, released
2026-10-21): CHANGELOG `[1.4.0]` has no entry on selection, copy or wrapping (only a Linux
`wl-copy`/`xclip` Ctrl+Z fix, #11179). `getActiveSelectionText()` in `pi-tui@1.4.0` is byte-identical
to 1.3.0 (`diff` empty). Upgrading does not fix this.

## Baseline

baseline: not measured. Judgement criterion: a command longer than the pane width, or inside an
indented code block, pastes into zsh and runs unchanged (today: no, per Luis).

## Options

| # | Option | Exact? | Cost per copy | Fails when | Verdict |
| --- | --- | --- | --- | --- | --- |
| 0 | Do nothing; clean up by hand | ✗ | select + manual edit | every wrapped/indented command | rejected |
| 1 | Zoom pane (`C-b z`) before copying; pi re-lays out at full width | partial | +2 keys | line > full width; indent remains | interim workaround |
| 2 | `/copy` or `Ctrl+X`, then extract the command in an editor | ✓ | 1 key + editor round-trip | only last message; whole markdown | fallback |
| 3 | Ask the agent to `pbcopy` the command | ✓ | 1 prompt + a turn + tokens | model compliance | ad hoc |
| 4 | pi extension `/cb [n]` + shortcut: fenced code blocks of the last assistant message → picker if > 1 → `copyToClipboard` | ✓ | ~2–3 keys (estimate, not measured) | pi extension API changes; ~40 LOC to own | **recommended** |
| 5 | tmux copy-pipe filter that joins lines / strips indent | ✗ (heuristic) | 0 extra | multi-line scripts, heredocs: wraps and newlines are indistinguishable → silently wrong commands | rejected |
| 6 | `tuiMode: regular` | ✗ | — | pi pre-wraps rows there too `[UNVERIFIED for the main-screen renderer]` | rejected |
| 7 | Upstream: pi tracks its own wrap points and joins them in `getActiveSelectionText()` | ✓ | 0 | not in Luis's control; not in 1.4.0 | file issue; drop 4 if it lands |

Sources: pi 1.3.0 / 1.4.0 package source and `docs/` (paths above); pi CHANGELOG `[1.4.0]`.
npm search `"pi-coding-agent clipboard"` (2026-10-28): no existing code-block-copy package.
Prior knowledge: not grepped in `vault/` yet.

## Decision

Draft, pending Luis. Proposed: **4**, with 1/3 as interim, 7 filed upstream.
Deciding axis: **exactness of the copied bytes per keystroke**. 0, 1, 5, 6 read the screen and
can never be exact. 2 and 3 are exact but cost an editor round-trip or a model turn per copy.
4 is exact at ~2–3 keys. Changes if: upstream ships 7 → retire 4.

## Tasks

- [ ] Decide extension location: `~/.pi/agent/extensions/` symlinked from `~/devSetup` (machine
      config → needs approval).
- [ ] Write `~/devSetup/config/pi/extensions/copy-code-block.ts`: `/cb [n]` + shortcut; read last
      assistant message from `ctx.sessionManager.getBranch()`, extract fenced blocks, picker via
      `ctx.ui.select()` if > 1, `copyToClipboard`. Check the shortcut against `docs/keybindings.md`
      and `specs/keyboard.md`.
- [ ] Symlink into `~/.pi/agent/extensions/`, `/reload` in pi.
- [ ] Optional: file upstream issue for option 7 (join pi's own wraps in selection copy).

## Verification

Ask pi for a fenced bash block with a ~200-char one-liner and a 3-line heredoc in an 80-col pane, then:

```sh
# after /cb 1:
pbpaste | od -c | head          # no leading spaces, no '\n' inside the one-liner
pbpaste | wc -l                 # one-liner → 1
# after /cb 2: pbpaste | wc -l  → 3, heredoc runs unchanged in zsh
```

## Outcome

Not started.
