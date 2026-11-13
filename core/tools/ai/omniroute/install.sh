#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/version"
import "@/utils/uninstall"

LOG_FILE="$CORE_CACHE/install_ai.log"
OMNIROUTE_DATA_DIR="$HOME/.omniroute"

_omniroute_dependencies() {
  loading "Installing dependencies" _omniroute_dependencies_impl
}

_omniroute_dependencies_impl() {
  # Node.js / npm
  if ! command -v node &>/dev/null || ! command -v npm &>/dev/null; then
    if ! yes | pkg install nodejs-lts &>>"$LOG_FILE"; then
      log_error "Failed to install Node.js"
      return 1
    fi
  fi

  # sqlite3 CLI for DB integrity checks / recovery
  if ! command -v sqlite3 &>/dev/null; then
    if ! yes | pkg install sqlite &>>"$LOG_FILE"; then
      log_error "Failed to install sqlite"
      return 1
    fi
  fi

  return 0
}

_install_omniroute_npm() {
  loading "Installing OmniRoute (npm)" _install_omniroute_npm_impl
}

_install_omniroute_npm_impl() {
  if ! npm install -g omniroute &>>"$LOG_FILE"; then
    log_error "Failed to install omniroute"
    return 1
  fi
  return 0
}

_install_omniroute_wrapper() {
  loading "Creating omniroute wrapper (DB guard)" _install_omniroute_wrapper_impl
}

_install_omniroute_wrapper_impl() {
  local real_bin="$PREFIX/lib/node_modules/omniroute/bin/omniroute.mjs"

  # remove symlink/file first so we don't follow a symlink into the npm module
  rm -f "$PREFIX/bin/omniroute"

  cat >"$PREFIX/bin/omniroute" <<WRAPPER
#!/data/data/com.termux/files/usr/bin/bash
# OmniRoute wrapper: guards against corrupt SQLite DB (internal server error)
DB_DIR="\$HOME/.omniroute"
DB="\$DB_DIR/storage.sqlite"
BACKUP_DIR="\$DB_DIR/db_backups"

mkdir -p "\$DB_DIR" "\$BACKUP_DIR"

_check_db() {
  [ -f "\$1" ] || return 1
  command -v sqlite3 >/dev/null 2>&1 || return 0
  [ "\$(sqlite3 "\$1" "PRAGMA integrity_check;" 2>/dev/null | head -1)" = "ok" ]
}

if [ -f "\$DB" ] && ! _check_db "\$DB"; then
  # quarantine corrupt DB
  mv "\$DB" "\$DB_DIR/storage.sqlite.corrupt.\$(date +%s)" 2>/dev/null
  # restore from latest healthy backup
  restored=0
  for b in \$(ls -t "\$BACKUP_DIR"/*.sqlite "\$BACKUP_DIR"/*.bak 2>/dev/null); do
    if _check_db "\$b"; then
      cp "\$b" "\$DB"
      restored=1
      break
    fi
  done
  if [ "\$restored" -eq 0 ]; then
    echo "OmniRoute: DB corrupt and no healthy backup found; starting fresh." >&2
  fi
fi

# backup healthy DB before start (keep last 5)
if [ -f "\$DB" ] && _check_db "\$DB"; then
  cp "\$DB" "\$BACKUP_DIR/storage.sqlite.\$(date +%Y%m%d%H%M%S).bak" 2>/dev/null
  ls -t "\$BACKUP_DIR"/*.bak 2>/dev/null | tail -n +6 | xargs -r rm -f
fi

exec node "$real_bin" "\$@"
WRAPPER

  chmod +x "$PREFIX/bin/omniroute"
  return 0
}

install_omniroute() {
  mkdir -p "$(dirname "$LOG_FILE")"

  if ! command -v omniroute &>/dev/null || [ ! -f "$PREFIX/lib/node_modules/omniroute/package.json" ]; then
    _omniroute_dependencies || return 1
    _install_omniroute_npm || return 1
  else
    log_info "OmniRoute is already installed"
  fi

  # always (re)apply the DB-guarding wrapper
  _install_omniroute_wrapper || return 1

  log_success "OmniRoute installed"
  return 0
}

uninstall_omniroute() {
  if ! command -v omniroute &>/dev/null; then
    log_info "OmniRoute is not installed"
    return 2
  fi

  confirm_remove_configs "OmniRoute" \
    "$HOME/.omniroute"

  log_info "Uninstalling OmniRoute..."
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Removing OmniRoute" _uninstall_omniroute_impl

  log_success "OmniRoute uninstalled"
  return 0
}

_uninstall_omniroute_impl() {
  npm uninstall -g omniroute &>>"$LOG_FILE" || true
  rm -f "$PREFIX/bin/omniroute"
  return 0
}

update_omniroute() {
  if [ ! -d "$PREFIX/lib/node_modules/omniroute" ]; then
    log_warn "OmniRoute is not installed"
    return 1
  fi

  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Updating OmniRoute" _update_omniroute_impl

  log_success "OmniRoute updated"
  return 0
}

_update_omniroute_impl() {
  if ! npm install -g omniroute@latest &>>"$LOG_FILE"; then
    log_error "Failed to update omniroute"
    return 1
  fi
  # re-apply wrapper (npm may have restored symlink)
  _install_omniroute_wrapper_impl
  return 0
}

reinstall_omniroute() {
  uninstall_omniroute
  install_omniroute
}
