# 0012 — pi-clickable-wrapped-links

- status: in-progress
- domain: specs/terminal.md
- opened: 2026-10-28
- closed: —

## Problem

Long URLs in pi (running in a tmux pane inside Ghostty) open truncated: Cmd+Shift+click and
`C-b F` + Shift+hint both work on short URLs, fail on URLs pi broke across lines.

Mechanism, verified in pi 1.3.0 source
(`/opt/homebrew/Cellar/pi-coding-agent/1.3.0/libexec/lib/node_modules/@earendil-works/pi-coding-agent/node_modules/@earendil-works/pi-tui/dist/`):

- pi-tui lays out rows itself and writes each row explicitly → the terminal sees hard line breaks,
  not soft wrap. Ghostty's URL regex and tmux-fingers match per visible row → URL fragment.
- `terminal-image.js:20-30`: under tmux, pi emits OSC 8 hyperlinks only if
  `tmux display-message -p '#{client_termfeatures}'` contains `hyperlinks`.
- `components/markdown.js:542-557`: otherwise falls back to printing `text (https://…)` as plain text.
- `utils.js:690`: with OSC 8, wrapping closes and re-opens the link on every row → each fragment
  carries the full URL.

Evidence:

```
$ tmux display -p '#{client_termname} | #{client_termfeatures}'
xterm-ghostty | bpaste,ccolour,clipboard,cstyle,extkeys,focus,RGB,title
```

Manual test by Luis: `printf '\e]8;;https://example.com\e\\OSC8-test\e]8;;\e\\\n'` was clickable in
Ghostty both inside and outside tmux, even though `hyperlinks` is missing from `client_termfeatures`.
Unexplained `[UNVERIFIED]`: tmux 3.8 may forward OSC 8 regardless. Irrelevant for pi, which
gates on the feature string, not on actual behaviour.

## Baseline

```
$ node -e 'import("./terminal-image.js").then(m=>console.log(JSON.stringify(m.getCapabilities())))'
{"images":null,"trueColor":true,"hyperlinks":false}
```

Wrapped URL failure rate: not measured as a count. Judgement criterion: a URL wrapped over ≥ 2
rows in pi opens in full via Cmd+Shift+click on its second row (today: no, per Luis's report).

## Options

| Option | Pros | Cons | Verdict |
| --- | --- | --- | --- |
| A. Do nothing; copy and reassemble | 0 cost | mouse + manual join on every wrapped URL | rejected |
| B. Add `hyperlinks` to `terminal-features` for `xterm-ghostty` | 1 line; uses pi's built-in OSC 8 path; per-row re-open fixes wrapping | markdown links render as text only (URL hidden) → `C-b F` can't see them; mouse click required | **chosen** |
| C. URL picker plugin (`tmux-fzf-url`, urlview) | keyboard-first | still reads visible text → same truncation; duplicates tmux-fingers | rejected |
| D. Widen pane / zoom (`C-b z`) before opening | 0 config | only helps if URL fits in one row; extra keys each time | fallback only |

Sources: tmux(1) `terminal-features` → `hyperlinks` (tmux ≥ 3.4); OSC 8 spec
<https://gist.github.com/egmontkob/eb114294efbcd5adb1944c9f3cb5feda>; pi-tui source lines above.
Prior knowledge: n/a (no vault note on OSC 8 found; not grepped `[UNVERIFIED]`).

## Decision

B. Axis: **correctness of the opened URL**. C fails it (still regex over visible text); D only works
for short URLs; A fails it. B is the only option where the link target survives pi's
hard-wrapping. Accepted cost: OSC 8 markdown links can't be reached with tmux-fingers. Keyboard access
to those goes to the backlog.

## Tasks

- [x] `/Users/luis/devSetup/config/tmux/tmux.conf:51-55`: `xterm-ghostty:RGB:extkeys` →
      `xterm-ghostty:RGB:extkeys:hyperlinks` + comment. `tmux source-file` done.
- [x] Same file, same commit: `set -su terminal-features` before the `-as` appends. Found during this
      change: `-as` re-appended both entries on every `C-b r` (7 entries after one reload instead
      of 5). `-su` resets the array to tmux defaults first → idempotent (2 reloads → 5 entries).
- [x] Luis: detach + reattach (`C-b d`, `tmux a`). tmux computes `client_termfeatures` at attach.
- [x] Luis: restart pi (capabilities are cached per process).
- [x] Verify commands (below): `hyperlinks` present, `getCapabilities()` → `"hyperlinks":true`.
- [ ] Manual test (wrapped link, 2nd row click), fill Outcome.
- [ ] Append `specs/terminal.md` Gap 6: OSC 8 markdown links not reachable by keyboard (BACKLOG 45).
- [ ] Fold into `specs/terminal.md` → Current (terminal-features line; also fix stale `tmux 3.7c` →
      3.8) and Invariants (pi gates OSC 8 on `client_termfeatures`).
- [ ] Luis commits in `~/devSetup`.

## Verification

```sh
tmux display -p '#{client_termfeatures}' | tr , '\n' | grep -x hyperlinks
cd /opt/homebrew/Cellar/pi-coding-agent/1.3.0/libexec/lib/node_modules/@earendil-works/pi-coding-agent/node_modules/@earendil-works/pi-tui/dist \
  && node -e 'import("./terminal-image.js").then(m=>console.log(JSON.stringify(m.getCapabilities())))'
# expect "hyperlinks":true
```

Manual: in a narrow pane, ask pi to print a markdown link with a > 100-char URL; Cmd+Shift+click its
second row → full URL opens.

## Outcome

Partial (2026-10-28): pi capability `hyperlinks` false → true; `client_termfeatures` now lists
`hyperlinks`; `terminal-features` stable at 5 entries across reloads (was +2 per reload).
Pending: manual wrapped-link click test.
