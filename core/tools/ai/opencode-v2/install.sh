#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"
import "@/utils/version"
import "@/utils/uninstall"
import "@/utils/walkie"

LOG_FILE="$CORE_CACHE/install_ai.log"
OPENCODE_V2_DATA_DIR="$HOME/.local/share/core-termux-data/opencode-v2"
OPENCODE_V2_VERSION_URL="https://opencode.ai/update/api/latest/cli/npm"

_opencode_v2_detect_ubuntu_root() {
  local root
  root="$(find /data/data/com.termux -maxdepth 10 -type d \
    -name "rootfs" -path "*/containers/ubuntu/*" 2>/dev/null | head -1)"

  if [ -z "$root" ]; then
    root="$(find /data/data/com.termux -maxdepth 10 -type d \
      -name "ubuntu" -path "*/installed-rootfs/*" 2>/dev/null | head -1)"
  fi

  echo "$root"
}

_opencode_v2_proot_ubuntu() {
  proot-distro login \
    --shared-tmp \
    ubuntu \
    -- "$@"
}

_get_latest_opencode_v2_version() {
  local meta ver
  meta=$(curl -fsSL "$OPENCODE_V2_VERSION_URL" 2>/dev/null)
  ver=$(printf '%s' "$meta" | sed -n 's/.*"version":"\([^"]*\)".*/\1/p')

  if [ -z "$ver" ]; then
    meta=$(curl -fsSL "https://registry.npmjs.org/@opencode/cli/latest" 2>/dev/null)
    ver=$(printf '%s' "$meta" | sed -n 's/.*"version":"\([^"]*\)".*/\1/p')
  fi

  _parse_version "$ver"
}

_get_remote_opencode_v2_version() {
  _spin_capture "Checking OpenCode V2" _get_latest_opencode_v2_version
}

_opencode_v2_install_deps_native() {
  loading "Installing glibc and dependencies" _opencode_v2_install_deps_native_impl
}

_opencode_v2_install_deps_native_impl() {
  if [[ ! -f $PREFIX/etc/apt/sources.list.d/glibc.list ]]; then
    if ! yes | pkg install glibc-repo &>>"$LOG_FILE"; then
      log_error "Failed to install glibc-repo"
      return 1
    fi
  fi

  if [[ ! -f $PREFIX/glibc/lib/libc.so.6 ]]; then
    if ! yes | pkg install glibc &>>"$LOG_FILE"; then
      log_error "Failed to install glibc"
      return 1
    fi
  fi

  declare -A DEPS=(
    ["git"]="git"
    ["ripgrep"]="rg"
    ["jq"]="jq"
    ["nodejs-lts"]="node"
    ["curl"]="curl"
    ["tar"]="tar"
  )

  local pkg_name bin_name
  for pkg_name in "${!DEPS[@]}"; do
    bin_name="${DEPS[$pkg_name]}"
    if ! command -v "$bin_name" &>/dev/null; then
      if ! yes | pkg install "$pkg_name" &>>"$LOG_FILE"; then
        log_error "Failed to install $pkg_name"
        return 1
      fi
    fi
  done

  return 0
}

_download_opencode_v2_binary() {
  loading "Downloading OpenCode V2" _download_opencode_v2_binary_impl
}

_download_opencode_v2_binary_impl() {
  local latest_version
  latest_version=$(_get_latest_opencode_v2_version)
  if [ -z "$latest_version" ]; then
    log_error "Failed to fetch latest OpenCode V2 version"
    return 1
  fi

  mkdir -p "$OPENCODE_V2_DATA_DIR"

  local tgz="cli-linux-arm64-$latest_version.tgz"
  local download_url="https://registry.npmjs.org/@opencode/cli-linux-arm64/-/$tgz"
  local tmp_dir="$OPENCODE_V2_DATA_DIR/.dl-tmp"

  mkdir -p "$tmp_dir"

  if ! curl -fsSL "$download_url" -o "$tmp_dir/$tgz" &>>"$LOG_FILE"; then
    log_error "Failed to download OpenCode V2 binary"
    rm -rf "$tmp_dir"
    return 1
  fi

  if ! tar -xzf "$tmp_dir/$tgz" -C "$tmp_dir" &>>"$LOG_FILE"; then
    log_error "Failed to extract OpenCode V2 binary"
    rm -rf "$tmp_dir"
    return 1
  fi

  if [ ! -f "$tmp_dir/package/bin/opencode" ]; then
    log_error "OpenCode V2 binary not found after extraction"
    rm -rf "$tmp_dir"
    return 1
  fi

  mv "$tmp_dir/package/bin/opencode" "$OPENCODE_V2_DATA_DIR/opencode2"
  chmod +x "$OPENCODE_V2_DATA_DIR/opencode2"
  rm -rf "$tmp_dir"
  return 0
}

_opencode_v2_create_native_wrapper() {
  local wrapper_src="$CORE_PATH/tools/ai/opencode-v2/bin/opencode2.native"
  if [ ! -f "$wrapper_src" ]; then
    log_error "Wrapper template not found at $wrapper_src"
    return 1
  fi
  sed "s|__DATA_DIR__|$OPENCODE_V2_DATA_DIR|g" "$wrapper_src" >"$PREFIX/bin/opencode2"
  chmod +x "$PREFIX/bin/opencode2"
  return 0
}

_install_opencode_v2_native() {
  _opencode_v2_install_deps_native || return 1
  _download_opencode_v2_binary || return 1
  loading "Creating wrapper" _opencode_v2_create_native_wrapper || return 1
  log_success "OpenCode V2 installed natively as opencode2"
  return 0
}

_install_opencode_v2_proot_glibc() {
  _opencode_v2_install_deps_native || return 1
  loading "Installing proot" _opencode_v2_install_proot_pkg || return 1
  _download_opencode_v2_binary || return 1
  loading "Creating proot wrapper" _opencode_v2_create_proot_wrapper || return 1

  printf 'proot-glibc' >"$OPENCODE_V2_DATA_DIR/.install-method"
  log_success "OpenCode V2 installed with glibc + proot as opencode2"
  return 0
}

_opencode_v2_install_proot_pkg() {
  if ! command -v proot &>/dev/null; then
    if ! yes | pkg install proot &>>"$LOG_FILE"; then
      log_error "Failed to install proot"
      return 1
    fi
  fi
  return 0
}

_opencode_v2_create_proot_wrapper() {
  local wrapper_src="$CORE_PATH/tools/ai/opencode-v2/bin/opencode2.proot"
  if [ ! -f "$wrapper_src" ]; then
    log_error "Wrapper template not found at $wrapper_src"
    return 1
  fi
  sed "s|__DATA_DIR__|$OPENCODE_V2_DATA_DIR|g" "$wrapper_src" >"$PREFIX/bin/opencode2"
  chmod +x "$PREFIX/bin/opencode2"
  return 0
}

_install_opencode_v2_proot() {
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Installing proot-distro" _opencode_v2_install_proot_distro || return 1
  loading "Installing Ubuntu container" _opencode_v2_install_ubuntu || return 1
  loading "Installing dependencies (Ubuntu)" _opencode_v2_ubuntu_deps || return 1
  loading "Downloading OpenCode V2 (Ubuntu)" _opencode_v2_ubuntu_install_bin || return 1
  loading "Creating wrapper" _opencode_v2_create_ubuntu_wrapper || return 1

  log_success "OpenCode V2 installed (proot-distro) as opencode2"
  return 0
}

_opencode_v2_install_proot_distro() {
  if ! command -v proot-distro &>/dev/null; then
    if ! yes | pkg install proot-distro &>>"$LOG_FILE"; then
      log_error "Failed to install proot-distro"
      return 1
    fi
  fi
  return 0
}

_opencode_v2_install_ubuntu() {
  if [ ! -d "$(_opencode_v2_detect_ubuntu_root)" ]; then
    if ! proot-distro install ubuntu:24.04 &>>"$LOG_FILE"; then
      log_error "Failed to install Ubuntu container"
      return 1
    fi
  fi
  return 0
}

_opencode_v2_ubuntu_deps() {
  _opencode_v2_proot_ubuntu /bin/bash -c \
    'apt-get update && apt-get upgrade -y && apt-get install -y curl ca-certificates' \
    &>>"$LOG_FILE"
}

_opencode_v2_ubuntu_install_bin() {
  local ver
  ver=$(_get_latest_opencode_v2_version)
  if [ -z "$ver" ]; then
    log_error "Failed to fetch latest OpenCode V2 version"
    return 1
  fi

  _opencode_v2_proot_ubuntu /bin/bash -c \
    'set -e
    curl -fsSL "https://registry.npmjs.org/@opencode/cli-linux-arm64/-/cli-linux-arm64-'"$ver"'.tgz" -o /tmp/oc2.tgz
    mkdir -p /tmp/oc2pkg /root/.opencode-v2/bin
    tar -xzf /tmp/oc2.tgz -C /tmp/oc2pkg
    mv /tmp/oc2pkg/package/bin/opencode /root/.opencode-v2/bin/opencode2
    chmod +x /root/.opencode-v2/bin/opencode2
    rm -rf /tmp/oc2.tgz /tmp/oc2pkg' &>>"$LOG_FILE"

  local opencode_bin
  opencode_bin="$(_opencode_v2_detect_ubuntu_root)/root/.opencode-v2/bin/opencode2"
  if [ ! -f "$opencode_bin" ]; then
    log_error "OpenCode V2 binary not found after install"
    return 1
  fi
  return 0
}

_opencode_v2_create_ubuntu_wrapper() {
  local ubuntu_root
  ubuntu_root="$(_opencode_v2_detect_ubuntu_root)"
  if [ -z "$ubuntu_root" ]; then
    log_error "Ubuntu rootfs not found"
    return 1
  fi

  local wrapper_src="$CORE_PATH/tools/ai/opencode-v2/bin/opencode2"
  if [ ! -f "$wrapper_src" ]; then
    log_error "Wrapper template not found at $wrapper_src"
    return 1
  fi
  sed "s|__UBUNTU_ROOTFS__|$ubuntu_root|g" "$wrapper_src" >"$PREFIX/bin/opencode2"
  chmod +x "$PREFIX/bin/opencode2"
  return 0
}

install_opencode_v2() {
  if command -v opencode2 &>/dev/null; then
    log_info "OpenCode V2 is already installed"
    return 2
  fi

  log_info "Select installation method for OpenCode V2:"
  log_info "Runs side-by-side with V1 as ${D_CYAN}opencode2${D_NC}"
  log_info "Native glibc cannot start the V2 background server (no /lib on Android)"

  read_select "Installation method" SELECTED_METHOD \
    "glibc + proot (recommended)" \
    "glibc native (no background server)" \
    "proot-distro (ubuntu container)"

  case "$SELECTED_METHOD" in
  *"glibc + proot"*)
    _install_opencode_v2_proot_glibc
    ;;
  *"glibc native"*)
    _install_opencode_v2_native
    ;;
  *proot-distro*)
    _install_opencode_v2_proot
    ;;
  esac
}

uninstall_opencode_v2() {
  _walkie_remove_wrapper opencode2
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ ! -f "$PREFIX/bin/opencode2" ]; then
    log_warn "OpenCode V2 is not installed"
    return 1
  fi

  log_info "OpenCode V2 shares its config with V1 (~/.config/opencode) — configs are kept"
  loading "Uninstalling OpenCode V2" _uninstall_opencode_v2_impl
}

_uninstall_opencode_v2_impl() {
  if [ -f "$OPENCODE_V2_DATA_DIR/opencode2" ]; then
    local method="native"
    if [ -f "$OPENCODE_V2_DATA_DIR/.install-method" ]; then
      method="$(cat "$OPENCODE_V2_DATA_DIR/.install-method")"
    fi
    rm -f "$PREFIX/bin/opencode2"
    rm -rf "$OPENCODE_V2_DATA_DIR"
    log_success "OpenCode V2 ($method) uninstalled"
    return 0
  fi

  _opencode_v2_proot_ubuntu /bin/bash -c 'rm -rf /root/.opencode-v2' &>>"$LOG_FILE"

  if rm -f "$PREFIX/bin/opencode2" &>>"$LOG_FILE"; then
    log_success "OpenCode V2 (proot-distro) uninstalled"
    return 0
  else
    log_error "Failed to uninstall OpenCode V2"
    return 1
  fi
}

_update_opencode_v2() {
  _update_opencode_v2_impl
}

_update_opencode_v2_impl() {
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ -f "$OPENCODE_V2_DATA_DIR/opencode2" ]; then
    local method="native"
    if [ -f "$OPENCODE_V2_DATA_DIR/.install-method" ]; then
      method="$(cat "$OPENCODE_V2_DATA_DIR/.install-method")"
    fi
    if [ "$method" = "proot-glibc" ]; then
      _install_opencode_v2_proot_glibc
    else
      _install_opencode_v2_native
    fi
    return $?
  fi

  loading "Updating OpenCode V2 (proot-distro)" _update_opencode_v2_proot_impl
}

update_opencode_v2() {
  _check_update_needed "OpenCode V2" "$(_get_installed_version opencode2)" "$(_get_remote_opencode_v2_version)" _update_opencode_v2
}

_update_opencode_v2_proot_impl() {
  _opencode_v2_proot_ubuntu /bin/bash -c 'rm -rf /root/.opencode-v2' &>>"$LOG_FILE"

  loading "Downloading OpenCode V2 (Ubuntu)" _opencode_v2_ubuntu_install_bin || return 1

  local ubuntu_root
  ubuntu_root="$(_opencode_v2_detect_ubuntu_root)"
  local opencode_bin="$ubuntu_root/root/.opencode-v2/bin/opencode2"

  if [ ! -f "$opencode_bin" ]; then
    log_error "OpenCode V2 binary not found after update"
    return 1
  fi

  log_success "OpenCode V2 (proot-distro) updated"
  return 0
}

reinstall_opencode_v2() {
  uninstall_opencode_v2
  install_opencode_v2
}
