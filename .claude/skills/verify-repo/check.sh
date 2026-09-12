#!/bin/sh
# Repo verification gate. Exit 0 = clean. Any FAIL exits 1.
# Dependency-light on purpose: sh + grep + sed only. Run from the repo root.

cd "$(dirname "$0")/../../.." || exit 2
fails=0
pass() { printf '  ok   %s\n' "$1"; }
fail() { printf '  FAIL %s\n' "$1"; fails=$((fails + 1)); }

md_files() {
  find . -name '*.md' -not -path './.git/*' -not -path './vault/*' | sort
}

echo "1. structure"
for f in AGENTS.md CLAUDE.md README.md SYSTEM.md GLOSSARY.md .gitignore \
         specs/README.md changes/TEMPLATE.md changes/BACKLOG.md; do
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
md_files | while read -r f; do
  d=$(dirname "$f")
  sed -n 's/.*](\([^)#][^)]*\)).*/\1/p' "$f" | while read -r link; do
    case "$link" in
      http*|mailto:*|'#'*) continue ;;
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

echo
if [ "$fails" -eq 0 ]; then echo "clean"; exit 0; else echo "$fails check(s) failed"; exit 1; fi
