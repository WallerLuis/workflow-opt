---
description: Editing specs/*.md and SYSTEM.md — what is, never what should be; gap numbering; drift rules.
paths:
  - "specs/**/*.md"
  - "SYSTEM.md"
globs:
  - "specs/**/*.md"
  - "SYSTEM.md"
---

# Editing specs and SYSTEM.md

These files describe **what is**, never what should be.

- Three sections only: `## Current`, `## Invariants`, `## Gaps`. Do not add a "Plan" or "Desired" section.
- Every line under `Current` must be traceable to a file path, command output, or an observation made
  in this session. Anything else gets `[UNVERIFIED]` inline.
- Do not add a gap's solution here. Solutions live in `changes/`; the gap gets an entry in
  `changes/BACKLOG.md` referencing `<spec>#<gap number>`.
- Specs change only when a `changes/NNNN-*.md` file reaches `status: done`. Editing a spec to record
  an intention is the failure mode this structure exists to prevent.
- Renumbering gaps breaks backlog references. Append new gaps; never reorder.
- When a spec and `SYSTEM.md` disagree, re-verify against the machine and fix both in the same edit.
