#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/telemetry"

telemetry_main() {
  case "${1:-status}" in
  on)
    mkdir -p "$(dirname "$TELEMETRY_CONFIG")"
    echo "on" >"$TELEMETRY_CONFIG"
    log_success "Telemetry on — failures will send anonymous reports"
    ;;
  off)
    mkdir -p "$(dirname "$TELEMETRY_CONFIG")"
    echo "off" >"$TELEMETRY_CONFIG"
    log_success "Telemetry off — nothing leaves this phone"
    ;;
  status)
    if telemetry_is_on; then
      log_info "Telemetry is on"
    else
      log_info "Telemetry is off"
    fi
    echo
    log_info "When on, each failed install, update, reinstall or"
    log_info "uninstall sends one report: command, tool name, exit"
    log_info "code, one error line and versions. Never paths,"
    log_info "prompts, tokens or file contents."
    ;;
  *)
    log_error "Usage: jax telemetry [on|off|status]"
    return 1
    ;;
  esac
}
