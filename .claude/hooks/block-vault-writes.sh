#!/bin/sh
# PreToolUse hook: deterministically block any mutation of the Obsidian vault.
#
# Deny rules in settings.json are advisory-adjacent: `Edit(...)` gates the file-editing tools, but a
# Bash redirection into the vault is not path-matched at all. Claude Code docs: "To block an action
# regardless of what Claude decides, use a PreToolUse hook." This is that gate.
#
# Reads the hook JSON on stdin. Exit 2 = block, stderr goes to the model. Exit 0 = allow.
# sh + sed only, no jq/python dependency.

VAULT_ABS='/Users/luis/luis_obsidian_vault'
payload=$(cat)

field() {
  printf '%s' "$payload" | sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" | head -1
}

tool=$(field tool_name)

targets_vault() {
  case "$1" in
    */"$VAULT_ABS"/*|"$VAULT_ABS"/*|"$VAULT_ABS") return 0 ;;
    vault/*|./vault/*|*/workflow-opt/vault/*) return 0 ;;
  esac
  return 1
}

case "$tool" in
  Write|Edit|MultiEdit|NotebookEdit)
    path=$(field file_path)
    if targets_vault "$path"; then
      echo "BLOCKED: the Obsidian vault is read-only. Write the note to notes/ instead; Obsidian sees it through the reverse symlink. ($path)" >&2
      exit 2
    fi
    ;;
  Bash)
    cmd=$(field command)
    case "$cmd" in
      *vault/*|*luis_obsidian_vault*) ;;
      *) exit 0 ;;
    esac
    # Path is mentioned. Block only mutating constructs; reads (grep/cat/find/ls) stay allowed.
    case "$cmd" in
      *'>'*|*'tee '*|*'rm '*|*'mv '*|*'cp '*|*'sed -i'*|*'truncate'*|*'mkdir '*|*'touch '*|*'ln '*|*'chmod '*|*'dd '*)
        echo "BLOCKED: mutating command targets the Obsidian vault, which is read-only. Write to notes/ instead. ($cmd)" >&2
        exit 2
        ;;
    esac
    ;;
esac

exit 0
