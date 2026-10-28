# 0014 — ssh-config-single-source

- status: done
- domain: specs/dotfiles.md
- opened: 2026-10-28
- closed: 2026-10-28

## Problem

`~/.ssh/config` was a regular file (1630 B, `-rw-------`), not a symlink. `~/devSetup/config/ssh/config`
(917 B, last touched by `25152d8 refactor: folder structure`) had silently drifted: the live file had
3 extra default `IdentityFile` lines and 5 extra hosts (`unraid-nbg`, `deployment`, `acs-sasse`,
`acs-sasse-deploy`, `HC-lindnerteam`). `install.sh` had no `link` line for it. `specs/dotfiles.md`
listed `config/ssh` as "Tracked and real", which hid the drift.

## Baseline

5 of 9 relevant host/identity blocks (by `diff` of Host/HostName/User/IdentityFile lines) missing from
the repo copy → a restore from devSetup would have lost them. Drift detection: none.

## Options

| Option | Pros | Cons | Verdict |
| --- | --- | --- | --- |
| Do nothing | zero effort | drift keeps growing; restore loses hosts | rejected |
| Copy live → repo, symlink via `link()` | one file, same mechanism as zsh/tmux/ghostty | all hosts + IPs in a (private) git repo | **chosen** |
| Repo base + `Include` from a local, untracked `~/.ssh/config` | machine-specific hosts stay out of git | two files, local part unbacked-up, drift between them | rejected |

Sources: `man ssh_config` (`Include`); OpenSSH `readconf.c` permission check — rejects a config that
is group/world-writable or owned by another user, checked on the opened file (symlink target).

## Decision

Single source via the existing `link()` mechanism; axis: one mechanism + backup coverage vs. exposure of
hostnames/IPs. No private keys are in the file (`.gitignore` already denies `id_rsa`, `id_ed25519`).

## Tasks

- [x] Back up live file → `~/.dotfiles-backup/20261028T123111/.ssh/config`
- [x] `cp ~/.ssh/config ~/devSetup/config/ssh/config`, `chmod 600`
- [x] Replace `~/.ssh/config` with symlink → `~/devSetup/config/ssh/config`
- [x] `~/devSetup/install.sh`: `chmod 700 ~/.ssh`, `link "config/ssh/config"`, `chmod 600` on the repo file
      (git stores only 644/755, so a fresh clone gets 644)

## Verification

```sh
readlink ~/.ssh/config                                   # → /Users/luis/devSetup/config/ssh/config
stat -f '%Sp' ~/devSetup/config/ssh/config               # → -rw-------
ssh -G unraid-nbg | grep -E '^(hostname|user) '          # → user root / hostname 192.168.2.3
bash -n ~/devSetup/install.sh
```

## Outcome

Content byte-identical (`cmp`) to the backup; `ssh -G` resolves `unraid-nbg`, `deployment`, `acs-sasse`,
`HC-lindnerteam` through the symlink; `link()` re-run prints `ok`. Repo copy missing hosts: 5 → 0.
Future host additions land in git automatically. Surprise: the spec's "Tracked and real" line made
the stale copy look managed. Full `install.sh` run not executed (slow `brew bundle`).
