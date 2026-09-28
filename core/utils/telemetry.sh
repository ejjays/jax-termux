#!/data/data/com.termux/files/usr/bin/bash

# Opt-in failure telemetry for JAX. Default off. When on, tool install /
# update / reinstall / uninstall failures send one small report each:
# command, module, tool, exit code, a sanitized error line, JAX version.
# Never sent: paths, prompts, tokens, file contents, IPs (the server
# stores none of that either). Transport failures never fail the CLI.

import "@/utils/log"

TELEMETRY_ENDPOINT="https://jax-telemetry.christsonalloso021.workers.dev/report"
TELEMETRY_CONFIG="$HOME/.config/core-termux/telemetry"
TELEMETRY_SPOOL="$HOME/.cache/core-termux/telemetry/pending"
_TELEMETRY_ASKED=0

telemetry_is_on() {
  [[ -f "$TELEMETRY_CONFIG" ]] && [[ "$(cat "$TELEMETRY_CONFIG" 2>/dev/null)" == "on" ]]
}

telemetry_ask_once() {
  [[ $_TELEMETRY_ASKED -eq 1 ]] && return 1
  _TELEMETRY_ASKED=1
  [[ -t 0 ]] || return 1
  local answer=""
  echo
  log_info "This failed. Share anonymous failure details so it gets fixed?"
  log_info "Sends only: command, tool name, exit code, one error line, versions."
  read_confirm_default "Send anonymous failure report?" "n" answer || return 1
  mkdir -p "$(dirname "$TELEMETRY_CONFIG")"
  if [[ "$answer" == "y" ]]; then
    echo "on" >"$TELEMETRY_CONFIG"
    return 0
  fi
  echo "off" >"$TELEMETRY_CONFIG"
  log_info "Telemetry stays off. Change anytime with: jax telemetry on"
  return 1
}

# Pull the last error-looking line from the freshest module install log,
# stripped of home paths and every control character (apt/npm progress
# bars leave carriage returns that would otherwise poison the JSON).
telemetry_error_class() {
  local logfile
  logfile="$(ls -t "$HOME/.cache/core-termux"/install_*.log 2>/dev/null | head -n 1)"
  [[ -n "$logfile" ]] || { echo "unknown"; return; }
  local line
  line="$(grep -a -i -m 1 "error\|failed\|✖\|cannot\|not found" "$logfile" 2>/dev/null | tail -n 1)"
  [[ -n "$line" ]] || { echo "unknown"; return; }
  line="$(echo "$line" | sed -r 's/\x1b\[[0-9;]*m//g' | sed "s|$HOME|~|g" | tr -d '[:cntrl:]')"
  echo "${line:0:200}"
}

# Full story, sanitized: last 40 useful lines of the freshest module log.
# Home paths become ~, control codes go, secret-looking lines are dropped
# entirely, total capped so one report stays small.
telemetry_log_tail() {
  local logfile
  logfile="$(ls -t "$HOME/.cache/core-termux"/install_*.log 2>/dev/null | head -n 1)"
  [[ -n "$logfile" ]] || return 0
  grep -a -v '^[[:space:]]*$' "$logfile" 2>/dev/null \
    | grep -a -v -i "token\|secret\|password\|passwd\|api[_-]key\|authorization\|bearer\|cookie\|private[_-]key\|session" \
    | tail -n 40 \
    | sed -r 's/\x1b\[[0-9;]*m//g' \
    | sed "s|$HOME|~|g" \
    | tr -d '\000-\011\013-\037' \
    | head -c 8192
  return 0
}

# JSON-escape free text. Prefers python; without it, falls back to
# stripping the characters that would break the payload.
telemetry_json() {
  if command -v python &>/dev/null; then
    printf '%s' "$1" | python -c "import json,sys; print(json.dumps(sys.stdin.read()))"
  else
    printf '"%s"' "$(printf '%s' "$1" | tr -d '"\\\n\r')"
  fi
}

telemetry_send() {
  local cmd="$1" module="$2" tool="$3" rc="$4"
  local error_class log_tail version payload
  error_class="$(telemetry_error_class)"
  log_tail="$(telemetry_log_tail)"
  version="${CORE_VERSION:-unknown}"
  error_class="$(telemetry_json "$error_class")"
  log_tail="$(telemetry_json "$log_tail")"
  payload="{\"v\":1,\"command\":\"$cmd\",\"module\":\"$module\",\"tool\":\"$tool\",\"exit_code\":$rc,\"error_class\":$error_class,\"jax_version\":\"${version//\"/}\",\"log_tail\":$log_tail}"
  if curl -fsSL --max-time 8 -X POST "$TELEMETRY_ENDPOINT" \
    -H "Content-Type: application/json" \
    --data "$payload" &>/dev/null; then
    telemetry_flush_spool
  else
    mkdir -p "$TELEMETRY_SPOOL" 2>/dev/null || return 0
    printf '%s' "$payload" >"$TELEMETRY_SPOOL/$(date +%s)-$RANDOM.json" 2>/dev/null || true
  fi
  return 0
}

# Best-effort resend of spooled reports (offline at failure time).
telemetry_flush_spool() {
  [[ -d "$TELEMETRY_SPOOL" ]] || return 0
  local f n=0
  for f in "$TELEMETRY_SPOOL"/*.json; do
    [[ -f "$f" ]] || break
    ((n++))
    [[ $n -gt 5 ]] && break
    if curl -fsSL --max-time 8 -X POST "$TELEMETRY_ENDPOINT" \
      -H "Content-Type: application/json" \
      --data @"$f" &>/dev/null; then
      rm -f "$f"
    fi
  done
  return 0
}

# Shared per-tool result hook. Replaces the bare
#   case $? in 0) ((ok++));; 1) ((fail++));; esac
# idiom with identical counting: only exit 1 is a failure (other non-zero
# codes mean already-installed/skipped and touch neither counter).
# Usage: install_foo; _tool_result install ai foo $? installed_count failed_count
_tool_result() {
  local cmd="$1" module="$2" tool="$3" rc="$4"
  local -n _ok_ref="$5" _fail_ref="$6"
  if [[ "$rc" -eq 0 ]]; then
    ((_ok_ref++))
  elif [[ "$rc" -eq 1 ]]; then
    ((_fail_ref++))
    if telemetry_is_on || telemetry_ask_once; then
      telemetry_send "$cmd" "$module" "$tool" "$rc"
    fi
  fi
}
