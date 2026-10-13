---
name: new-change
description: Open a new workflow change in changes/. Use when starting any modification to the dev environment, agent setup, dotfiles, keyboard, terminal, or knowledge workflow, or when the user picks an item from changes/BACKLOG.md.
---

# new-change

## Steps

1. Determine the number: highest `NNNN` across `changes/*.md` and `changes/archive/*.md`, plus one,
   zero-padded to 4. Never reuse.
2. `cp changes/TEMPLATE.md changes/NNNN-<kebab-slug>.md`. Slug names the outcome, not the tool
   (`kill-prompt-duplication`, not `remove-p10k`).
3. Set `status: draft`, `domain:` = the `specs/*.md` this will mutate, `opened:` = today.
4. **Problem** — gather evidence first. Run the command, read the file, paste the real output.
   No hypotheticals; if the symptom cannot be reproduced, say so and stop.
5. **Baseline** — measure. Startup ms (`for i in $(seq 10); do /usr/bin/time zsh -i -c exit; done`),
   keystrokes, step count, minutes/week, failure count. Unmeasurable → write
   `baseline: not measured` and name the judgement criterion.
6. **Options** — at least two real alternatives. Search the field: official docs, primary sources,
   named practitioners. Then grep `vault/` for what Luis already recorded and cite those note paths.
   One-option tables are a skipped analysis.
7. **Decision** — name the tradeoff axis; say why each rejected option lost.
8. **Tasks** — ordered, each naming its file, each independently verifiable.
9. **Verification** — an exact runnable command.
10. Stop and get agreement before executing tasks that alter the live machine
    (`~/devSetup`, `~/.zshrc`, `~/.claude/`, Karabiner). Use plan mode for those.

## On completion

- Fill **Outcome** with the measured delta vs. baseline.
- Fold durable facts into `specs/<domain>.md` (`Current`, and close the `Gaps` entry).
- Update `SYSTEM.md` if machine state changed.
- Remove the candidate row from `changes/BACKLOG.md`.
- `git mv changes/NNNN-*.md changes/archive/`.
- Run `/verify-repo`.

## Scope

Config or script that must reach the machine goes to `~/devSetup` as its own commit. This repo holds
the decision and the record. Cross-reference by absolute path.
