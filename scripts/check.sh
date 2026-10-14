#!/bin/sh
# Repo verification gate. Exit 0 = clean. Any FAIL exits 1.
# Dependency-light on purpose: sh + grep + sed + find. Run from anywhere.

cd "$(dirname "$0")/.." || exit 2
fails=0
pass() { printf '  ok   %s\n' "$1"; }
fail() { printf '  FAIL %s\n' "$1"; fails=$((fails + 1)); }

md_files() {
  find . -name '*.md' -not -path './.git/*' -not -path './vault/*' | sort
}

echo "1. structure"
for f in AGENTS.md CLAUDE.md README.md SYSTEM.md GLOSSARY.md .gitignore \
         specs/README.md changes/TEMPLATE.md changes/BACKLOG.md \
         .pi/extensions/git-guard.ts scripts/check.sh; do
  [ -f "$f" ] && pass "$f" || fail "missing $f"
done
[ -d changes/archive ] && pass "changes/archive/" || fail "missing changes/archive/"

echo "2. CLAUDE.md imports AGENTS.md"
if head -5 CLAUDE.md | grep -q '^@AGENTS\.md$'; then
  pass "@AGENTS.md import present"
else
  fail "CLAUDE.md must start with the line '@AGENTS.md'"
fi

echo "3. AGENTS.md size (<=150 lines)"
n=$(wc -l < AGENTS.md | tr -d ' ')
[ "$n" -le 150 ] && pass "AGENTS.md ${n} lines" || fail "AGENTS.md ${n} lines, over the 150-line budget"

echo "4. spec sections"
for f in specs/*.md; do
  [ "$f" = "specs/README.md" ] && continue
  miss=""
  for s in Current Invariants Gaps; do
    grep -q "^## $s\$" "$f" || miss="$miss $s"
  done
  [ -z "$miss" ] && pass "$f" || fail "$f missing section(s):$miss"
done

echo "5. change sections"
for f in changes/[0-9]*.md changes/archive/[0-9]*.md; do
  [ -f "$f" ] || continue
  miss=""
  for s in Problem Baseline Options Decision Tasks Verification Outcome; do
    grep -q "^## $s\$" "$f" || miss="$miss $s"
  done
  grep -q '^- status: ' "$f" || miss="$miss status"
  [ -z "$miss" ] && pass "$f" || fail "$f missing:$miss"
done

echo "6. relative links resolve"
# grep -o extracts EVERY link on a line; a greedy sed only caught the last one.
# Fenced blocks and inline code spans are stripped first: documentation *about* link
# syntax is not a link (a `[x](./nope.md)` example must not fail the gate).
strip_code() {
  awk '/^[[:space:]]*```/ { fence = !fence; next } !fence' "$1" | sed 's/`[^`]*`//g'
}
md_files | while read -r f; do
  d=$(dirname "$f")
  strip_code "$f" | grep -o '](\([^)]*\))' 2>/dev/null | sed 's/^](//; s/)$//' | while read -r link; do
    case "$link" in
      http*|mailto:*|'#'*|'') continue ;;
    esac
    target=$(echo "$link" | sed 's/#.*//')
    [ -z "$target" ] && continue
    [ -e "$d/$target" ] || [ -e "$target" ] || printf '  FAIL broken link in %s -> %s\n' "$f" "$link"
  done
done | tee /tmp/wo-links.$$ >/dev/null
if [ -s /tmp/wo-links.$$ ]; then cat /tmp/wo-links.$$; fails=$((fails + 1)); else pass "no broken relative links"; fi
rm -f /tmp/wo-links.$$

echo "7. secret scan (tracked files only)"
hits=$(git ls-files -z 2>/dev/null | xargs -0 grep -InE \
  'sk-[A-Za-z0-9]{20}|ghp_[A-Za-z0-9]{20}|github_pat_[A-Za-z0-9_]{20}|AIza[0-9A-Za-z_-]{30}|xox[baprs]-[A-Za-z0-9-]{10}|-----BEGIN [A-Z ]*PRIVATE KEY-----' \
  2>/dev/null)
if [ -z "$hits" ]; then pass "no key-shaped strings in tracked files"; else printf '%s\n' "$hits"; fail "possible secret in tracked files"; fi

echo "8. symlinks"
if [ -L vault ] && [ -d vault ]; then
  pass "vault -> $(readlink vault)"
else
  fail "vault symlink missing or dangling (see README.md)"
fi
rev="$HOME/luis_obsidian_vault/300 Resources - future/340 Workflow Documentation - Home lab/workflow-opt"
if [ -L "$rev" ] && [ -d "$rev" ]; then
  pass "obsidian reverse link -> $(readlink "$rev")"
else
  fail "obsidian reverse symlink missing (see README.md)"
fi

echo "9. vault is not tracked"
if git ls-files 2>/dev/null | grep -q '^vault/'; then
  fail "vault contents are tracked by git"
else
  pass "vault untracked"
fi

echo "10. rules and skills reach both harnesses"
# Canonical files live in .agents/. Claude reaches them through directory symlinks; pi reads skills
# natively from .agents/skills and rules through the AGENTS.md pointer table. Never a copy.
for link in .claude/rules:../.agents/rules .claude/skills:../.agents/skills; do
  p=${link%%:*}; want=${link#*:}
  if [ -L "$p" ] && [ "$(readlink "$p")" = "$want" ] && [ -d "$p" ]; then
    pass "$p -> $want"
  else
    fail "$p must be a live directory symlink to $want (never a copy)"
  fi
done
for r in .agents/rules/*.md; do
  b=$(basename "$r")
  miss=""
  grep -q '^paths:' "$r"       || miss="$miss paths:(claude-trigger)"
  grep -q '^description:' "$r" || miss="$miss description:"
  grep -q "\`.agents/rules/$b\`" AGENTS.md || miss="$miss AGENTS.md-pointer(pi)"
  [ -z "$miss" ] && pass "rule $b (frontmatter + pi pointer)" || fail "rule $b missing:$miss"
done
for s in .agents/skills/*/SKILL.md; do
  d=$(basename "$(dirname "$s")")
  n=$(sed -n 's/^name: *//p' "$s" | head -1)
  if [ "$n" = "$d" ] && grep -q '^description: ' "$s"; then
    pass "skill $d (name = dir, description)"
  else
    fail "skill $d: name must equal directory and description must exist (Agent Skills spec)"
  fi
done

echo "11. deterministic gates present"
# Vault-write hook retired by decision in changes/0007 (Claude may edit the vault). Its absence is
# asserted so a stale registration cannot silently block again.
if grep -q 'block-vault-writes' .claude/settings.json || [ -e .claude/hooks/block-vault-writes.sh ]; then
  fail "vault-write hook reappeared — retired in changes/0007"
else
  pass "no vault-write hook (retired, 0007)"
fi
miss=""
for op in commit push reset; do
  grep -q "\\\\s+$op(" .pi/extensions/git-guard.ts || miss="$miss $op"
done
grep -q 'block: true' .pi/extensions/git-guard.ts || miss="$miss block:true"
[ -z "$miss" ] && pass "pi git-guard blocks commit/push/reset" || fail ".pi/extensions/git-guard.ts missing:$miss"
miss=""
for op in 'git commit' 'git push' 'git reset --hard'; do
  grep -q "Bash($op:\*)" .claude/settings.json || miss="$miss '$op'"
done
[ -z "$miss" ] && pass "claude denies commit/push/reset --hard" || fail ".claude/settings.json deny missing:$miss"

echo "12. terminology and dead references"
# Scope: live guidance only. changes/ is the historical record, scripts/ contains the patterns
# themselves, GLOSSARY.md defines the term it is not allowed to use loosely.
live() {
  find . -name '*.md' -not -path './.git/*' -not -path './vault/*' \
         -not -path './changes/*' -not -path './GLOSSARY.md' | sort
}
hits=$(live | xargs grep -n 'spec-first' 2>/dev/null)
if [ -z "$hits" ]; then
  pass "spec-anchored terminology consistent"
else
  printf '%s\n' "$hits"; fail "'spec-first' outside its GLOSSARY definition — this repo is spec-anchored"
fi
# Routing a note into a repo notes/ directory, or naming the old gate path, is dead guidance.
hits=$(live | xargs grep -nE 'skills/verify-repo/check\.sh|in `notes/`|`notes/` in this repo|belongs in `notes/`' 2>/dev/null)
if [ -z "$hits" ]; then
  pass "no dead path references"
else
  printf '%s\n' "$hits"; fail "dead reference: the gate is scripts/check.sh and notes/ was removed"
fi
# Hook stderr is live guidance too: it is the text the model acts on at block time, and it is not
# markdown, so the scan above cannot see it. Missed until 0004 verification.
hits=$(grep -nE 'notes/|skills/verify-repo/check\.sh' .claude/hooks/*.sh .claude/settings.json 2>/dev/null)
if [ -z "$hits" ]; then
  pass "no dead path references in hooks or settings"
else
  printf '%s\n' "$hits"; fail "dead reference in a hook or settings: notes/ was removed, the gate is scripts/check.sh"
fi
[ -d notes ] && fail "notes/ exists again — explanation content belongs in the vault" || pass "no notes/ directory"
# omp was retired as a harness in 0006; its config directories must not come back as half-live assets.
for d in .omp .codex; do
  [ -e "$d" ] && fail "$d exists — harnesses are pi + Claude Code only (0006)" || pass "no $d/"
done
hits=$(live | xargs grep -nE '\.omp/|rule://|omp://' 2>/dev/null)
if [ -z "$hits" ]; then
  pass "no omp references in live guidance"
else
  printf '%s\n' "$hits"; fail "dead omp reference — omp is retired (0006)"
fi

echo "13. whitespace convention"
ws=$(md_files | xargs grep -ln ' $' 2>/dev/null)
if [ -z "$ws" ]; then pass "no trailing whitespace"; else printf '%s\n' "$ws"; fail "trailing whitespace"; fi

echo
if [ "$fails" -eq 0 ]; then echo "clean"; exit 0; else echo "$fails check(s) failed"; exit 1; fi
