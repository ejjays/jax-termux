#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/version"
import "@/utils/uninstall"

LOG_FILE="$CORE_CACHE/install_npm.log"
GLIBC_LOADER="/data/data/com.termux/files/usr/glibc/lib/ld-linux-aarch64.so.1"

_wrangler_dependencies() {
  if command -v node &>/dev/null && command -v npm &>/dev/null; then
    log_info "Node.js and npm are already installed"
    return 0
  fi

  log_info "Installing Nodejs..."
  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg install nodejs-lts &>>"$LOG_FILE"
}

# workerd postinstall aborts on android; install scriptless, fix up after.
_install_wrangler_npm() {
  loading "Installing Wrangler CLI (scripts off)" _install_wrangler_npm_impl
}

_install_wrangler_npm_impl() {
  if ! npm install -g wrangler --ignore-scripts &>>"$LOG_FILE"; then
    log_error "Failed to install Wrangler CLI"
    return 1
  fi
  return 0
}

_install_workerd_binary() {
  loading "Fetching workerd linux-arm64 binary" _install_workerd_binary_impl
}

_install_workerd_binary_impl() {
  local root
  root="$(npm root -g 2>/dev/null)" || { log_error "npm root not found"; return 1; }
  [[ -x "$root/@cloudflare/workerd-linux-arm64/bin/workerd" ]] && return 0

  local workdir="$CORE_CACHE/wrangler-workerd"
  mkdir -p "$workdir" || return 1
  local ver
  ver="$(npm view workerd version 2>/dev/null)" || { log_error "cannot resolve workerd version"; return 1; }
  (
    cd "$workdir" || exit 1
    npm pack "@cloudflare/workerd-linux-arm64@$ver" &>>"$LOG_FILE" || exit 1
    mkdir -p "$root/@cloudflare"
    tar -xzf cloudflare-workerd-linux-arm64-*.tgz -C "$root/@cloudflare" || exit 1
    rm -rf "$root/@cloudflare/workerd-linux-arm64"
    mv "$root/@cloudflare/package" "$root/@cloudflare/workerd-linux-arm64" || exit 1
  ) || { log_error "Failed to unpack workerd binary"; return 1; }
  rm -rf "$workdir"
  return 0
}

_patch_workerd_platform() {
  local root
  root="$(npm root -g 2>/dev/null)" || return 1
  local line='  "android arm64 LE": "@cloudflare/workerd-linux-arm64",'
  local f
  for f in "$root/wrangler/node_modules/workerd/bin/workerd" "$root/wrangler/node_modules/workerd/lib/main.js"; do
    [[ -f "$f" ]] || { log_error "workerd file missing: $f"; return 1; }
    grep -q "android arm64 LE" "$f" || sed -i "s|\"linux arm64 LE\": \"@cloudflare/workerd-linux-arm64\",|\"linux arm64 LE\": \"@cloudflare/workerd-linux-arm64\",\n$line|" "$f"
  done
  return 0
}

_patch_workerd_interp() {
  local root
  root="$(npm root -g 2>/dev/null)" || return 1
  local bin="$root/@cloudflare/workerd-linux-arm64/bin/workerd"
  [[ -f "$bin" ]] || { log_error "workerd binary missing"; return 1; }
  python3 "$CORE_PATH/tools/npm/turbopack/bin/patch-interp.py" "$bin" "$GLIBC_LOADER" &>>"$LOG_FILE"
}

# npm's bin stub resolves relative to itself; replace with a direct wrapper.
_install_wrangler_wrapper() {
  local root
  root="$(npm root -g 2>/dev/null)" || return 1
  printf '#!/data/data/com.termux/files/usr/bin/bash\nexec node --no-warnings %s/wrangler/wrangler-dist/cli.js "$@"\n' "$root" >"$PREFIX/bin/wrangler"
  chmod +x "$PREFIX/bin/wrangler"
}

install_wrangler() {
  if command -v wrangler &>/dev/null && wrangler --version &>/dev/null; then
    return 0
  fi
  log_info "Installing Wrangler CLI..."

  _wrangler_dependencies

  mkdir -p "$(dirname "$LOG_FILE")"

  _install_wrangler_npm || return 1
  _install_workerd_binary || return 1
  loading "Patching workerd platform map" _patch_workerd_platform || return 1
  loading "Patching workerd ELF interpreter" _patch_workerd_interp || return 1
  loading "Installing CLI wrapper" _install_wrangler_wrapper || return 1

  if ! wrangler --version &>>"$LOG_FILE"; then
    log_error "Wrangler CLI installed but does not boot — see $LOG_FILE"
    return 1
  fi
  log_success "Wrangler CLI installed"
  return 0
}

_uninstall_wrangler_npm() {
  loading "Uninstalling Wrangler CLI" _uninstall_wrangler_npm_impl
}

_uninstall_wrangler_npm_impl() {
  local root
  root="$(npm root -g 2>/dev/null)" || return 1
  npm uninstall -g wrangler &>>"$LOG_FILE"
  rm -rf "$root/@cloudflare/workerd-linux-arm64" "$PREFIX/bin/wrangler"
  return 0
}

uninstall_wrangler() {
  if ! command -v wrangler &>/dev/null; then
    log_info "Wrangler CLI is not installed"
    return 0
  fi

  confirm_remove_configs "Wrangler CLI" \
    "$HOME/.config/.wrangler" \
    "$HOME/.wrangler"

  log_info "Uninstalling Wrangler CLI..."
  mkdir -p "$(dirname "$LOG_FILE")"

  _uninstall_wrangler_npm || return 1
  log_success "Wrangler CLI uninstalled"
  return 0
}

update_wrangler() {
  _check_update_needed "Wrangler CLI" "$(_get_installed_npm_version wrangler Wrangler CLI)" "$(_get_remote_npm_version wrangler)" _update_wrangler_impl
}

_update_wrangler_impl() {
  loading "Updating Wrangler CLI" _do_wrangler_update
}

_do_wrangler_update() {
  local root
  root="$(npm root -g 2>/dev/null)" || return 1
  npm update -g wrangler &>>"$LOG_FILE"
  # update refreshes wrangler's tree, so re-apply the Termux fixes
  _install_workerd_binary || return 1
  loading "Patching workerd platform map" _patch_workerd_platform || return 1
  loading "Patching workerd ELF interpreter" _patch_workerd_interp || return 1
  loading "Installing CLI wrapper" _install_wrangler_wrapper || return 1
}

reinstall_wrangler() {
  uninstall_wrangler
  install_wrangler
}
