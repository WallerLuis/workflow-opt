---
description: How to write a changes/NNNN-slug.md decision file, and what to fold where on completion.
paths:
  - "changes/**/*.md"
globs:
  - "changes/**/*.md"
---

# Writing a change

Structure is fixed by `changes/TEMPLATE.md`. Do not drop sections; write `n/a` with a reason instead.

- **Problem** needs evidence: a command and its real output, or a file path and line. No hypotheticals.
- **Baseline** is a number or the literal `baseline: not measured` plus the judgement criterion.
  Never estimate a baseline and present it as measured.
- **Options** needs ≥2 real alternatives with pros, cons and a verdict, plus sources. One-option
  tables mean the analysis was skipped.
- **Decision** must say why each rejected option lost, on a named tradeoff axis.
- **Tasks** are ordered and each names the file it touches.
- **Verification** is a command an agent can run, not "check that it works".
- **Outcome** is written only after execution, with the measured delta.

On completion: fold durable facts into the matching `specs/*.md`, update `SYSTEM.md` if machine state
changed, remove the candidate from `changes/BACKLOG.md`, then `git mv` the file into `changes/archive/`.

Numbers are zero-padded 4 digits, monotonic, never reused. Next number = highest in `changes/` and
`changes/archive/` plus one.
