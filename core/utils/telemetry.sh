#!/data/data/com.termux/files/usr/bin/bash

# Opt-in failure telemetry for JAX. Default off. When on, tool install /
# update / reinstall / uninstall failures send one small report each:
# command, module, tool, exit code, a sanitized error line, JAX version.
# Never sent: paths, prompts, tokens, file contents, IPs (the server
# stores none of that either). Transport failures never fail the CLI.

import "@/utils/log"

TELEMETRY_ENDPOINT="https://jax-telemetry.christsonalloso021.workers.dev/report"
TELEMETRY_CONFIG="$HOME/.config/core-termux/telemetry"
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
# stripped of home paths, control codes and anything over 200 chars.
telemetry_error_class() {
  local logfile
  logfile="$(ls -t "$HOME/.cache/core-termux"/install_*.log 2>/dev/null | head -n 1)"
  [[ -n "$logfile" ]] || { echo "unknown"; return; }
  local line
  line="$(grep -a -i -m 1 "error\|failed\|✖\|cannot\|not found" "$logfile" 2>/dev/null | tail -n 1)"
  [[ -n "$line" ]] || { echo "unknown"; return; }
  line="$(echo "$line" | sed -r 's/\x1b\[[0-9;]*m//g' | sed "s|$HOME|~|g" | tr -d '\000-\010\013\014\016-\037')"
  echo "${line:0:200}"
}

telemetry_send() {
  local cmd="$1" module="$2" tool="$3" rc="$4"
  local error_class
  error_class="$(telemetry_error_class)"
  local version="${CORE_VERSION:-unknown}"
  local payload
  payload="$(printf '{"command":"%s","module":"%s","tool":"%s","exit_code":%d,"error_class":"%s","jax_version":"%s"}' \
    "$cmd" "$module" "$tool" "$rc" \
    "${error_class//\"/}" "${version//\"/}")"
  curl -fsSL --max-time 8 -X POST "$TELEMETRY_ENDPOINT" \
    -H "Content-Type: application/json" \
    --data "$payload" &>/dev/null || true
}

# Shared per-tool result hook. Replaces the bare
#   case $? in 0) ((ok++));; 1) ((fail++));; esac
# idiom: keeps the counters identical, plus fires a report on failure.
# Usage: install_foo; _tool_result install ai foo $? installed_count failed_count
_tool_result() {
  local cmd="$1" module="$2" tool="$3" rc="$4"
  local -n _ok_ref="$5" _fail_ref="$6"
  if [[ "$rc" -eq 0 ]]; then
    ((_ok_ref++))
  else
    ((_fail_ref++))
    if telemetry_is_on || telemetry_ask_once; then
      telemetry_send "$cmd" "$module" "$tool" "$rc"
    fi
  fi
}
