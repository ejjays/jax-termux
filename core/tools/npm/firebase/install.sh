#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/version"
import "@/utils/uninstall"

LOG_FILE="$CORE_CACHE/install_npm.log"

_firebase_dependencies() {
  if command -v node &>/dev/null && command -v npm &>/dev/null; then
    log_info "Node.js and npm are already installed"
    return 0
  fi

  log_info "Installing Nodejs..."
  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg install nodejs-lts &>>"$LOG_FILE"
}

_install_firebase_npm() {
  loading "Installing Firebase CLI" _install_firebase_npm_impl
}

_install_firebase_npm_impl() {
  if ! npm install -g firebase-tools &>>"$LOG_FILE"; then
    log_error "Failed to install Firebase CLI"
    return 1
  fi
  if command -v termux-fix-shebang &>/dev/null && [[ -n "${PREFIX:-}" ]]; then
    termux-fix-shebang "$PREFIX/bin/firebase" &>>"$LOG_FILE" || true
  fi
  return 0
}

install_firebase() {
  if command -v firebase &>/dev/null; then
    return 0
  fi
  log_info "Installing Firebase CLI..."

  _firebase_dependencies

  mkdir -p "$(dirname "$LOG_FILE")"

  _install_firebase_npm || return 1
  log_success "Firebase CLI installed"
  return 0
}

_uninstall_firebase_npm() {
  loading "Uninstalling Firebase CLI" _uninstall_firebase_npm_impl
}

_uninstall_firebase_npm_impl() {
  if ! npm uninstall -g firebase-tools &>>"$LOG_FILE"; then
    log_error "Failed to uninstall Firebase CLI"
    return 1
  fi
  return 0
}

uninstall_firebase() {
  if ! command -v firebase &>/dev/null; then
    log_info "Firebase CLI is not installed"
    return 0
  fi

  confirm_remove_configs "Firebase CLI" \
    "$HOME/.config/configstore/firebase-tools.json" \
    "$HOME/.cache/firebase" \
    "$HOME/.firebase"

  log_info "Uninstalling Firebase CLI..."
  mkdir -p "$(dirname "$LOG_FILE")"

  _uninstall_firebase_npm || return 1
  log_success "Firebase CLI uninstalled"
  return 0
}

update_firebase() {
  _check_update_needed "Firebase CLI" "$(_get_installed_npm_version firebase-tools Firebase CLI)" "$(_get_remote_npm_version firebase-tools)" _update_firebase_impl
}

_update_firebase_impl() {
  loading "Updating Firebase CLI" _do_firebase_update
}

_do_firebase_update() {
  npm update -g firebase-tools &>>"$LOG_FILE"
  if command -v termux-fix-shebang &>/dev/null && [[ -n "${PREFIX:-}" ]]; then
    termux-fix-shebang "$PREFIX/bin/firebase" &>>"$LOG_FILE" || true
  fi
}

reinstall_firebase() {
  uninstall_firebase
  install_firebase
}
