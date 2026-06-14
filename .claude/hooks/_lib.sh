#!/usr/bin/env bash
# Shared bootstrap for all hooks.
# Why this exists: hooks run in whatever shell Claude Code launched with. On Windows,
# jq may be installed (e.g. via winget) but not on that process's PATH — the env was
# captured when Claude Code started. So we locate jq ourselves instead of trusting PATH.

# ensure_jq: make `jq` callable, searching common install locations. Returns 0 if found.
ensure_jq() {
  command -v jq >/dev/null 2>&1 && return 0

  local candidates=(
    "$HOME/AppData/Local/Microsoft/WinGet/Links"
    "$HOME/AppData/Local/Microsoft/WinGet/Packages"/jqlang.jq_*
    "$HOME/scoop/shims"
    "$HOME/bin"
    "/c/ProgramData/chocolatey/bin"
    "/usr/bin" "/usr/local/bin" "/mingw64/bin"
  )

  local d
  for d in "${candidates[@]}"; do
    if [ -x "$d/jq" ] || [ -x "$d/jq.exe" ]; then
      PATH="$d:$PATH"; export PATH
      command -v jq >/dev/null 2>&1 && return 0
    fi
  done
  return 1
}

# hlog: append one human-readable line to the unified hook activity log.
# Usage: hlog <hook-name> <DECISION> <detail...>
#   DECISION is a short tag: FIRED | SKIP | PASS | BLOCK | INJECT | AUDIT | OK
# This is observability only — it never changes a hook's exit code.
HOOK_LOG="${CLAUDE_PROJECT_DIR:-.}/.claude/audit/hooks.log"
hlog() {
  local hook="$1"; local decision="$2"; shift 2 2>/dev/null || true
  local detail="$*"
  # collapse newlines/tabs so each event stays on one grep-able line
  detail=$(printf '%s' "$detail" | tr '\n\t' '  ' | cut -c1-200)
  mkdir -p "$(dirname "$HOOK_LOG")" 2>/dev/null || true
  printf '%s | %-22s | %-6s | %s\n' \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$hook" "$decision" "$detail" >> "$HOOK_LOG"
}
