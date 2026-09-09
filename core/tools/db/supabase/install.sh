#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_db.log"
SUPABASE_DATA_DIR="$HOME/.local/share/core-termux-data/supabase"
SUPABASE_REPO="supabase/cli"
SUPABASE_ARCHIVE="supabase_linux_arm64.tar.gz"

_get_remote_supabase_version() {
	_get_remote_github_version "$SUPABASE_REPO"
}

_supabase_install_deps_impl() {
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
		["clang"]="clang"
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

_supabase_install_deps() {
	loading "Installing glibc and dependencies" _supabase_install_deps_impl
}

_download_supabase_binary_impl() {
	local version="$1"
	local tag="v${version}"
	local download_url

	download_url=$(curl -fsSL "https://api.github.com/repos/${SUPABASE_REPO}/releases/tags/${tag}" 2>/dev/null \
		| grep '"browser_download_url":' | grep 'linux.*arm64.*\.tar\.gz' | grep -v -e '\.apk' -e '\.deb' -e '\.rpm' | head -1 \
		| sed -E 's/.*"([^"]+)".*/\1/')

	if [ -z "$download_url" ]; then
		download_url="https://github.com/${SUPABASE_REPO}/releases/download/${tag}/${SUPABASE_ARCHIVE}"
	fi

	mkdir -p "$SUPABASE_DATA_DIR"

	if ! curl -fsSL "$download_url" -o "$SUPABASE_DATA_DIR/$SUPABASE_ARCHIVE" &>>"$LOG_FILE"; then
		log_error "Failed to download Supabase CLI v${version}"
		return 1
	fi

	if ! tar -xzf "$SUPABASE_DATA_DIR/$SUPABASE_ARCHIVE" -C "$SUPABASE_DATA_DIR" &>>"$LOG_FILE"; then
		log_error "Failed to extract Supabase CLI"
		return 1
	fi

	rm -f "$SUPABASE_DATA_DIR/$SUPABASE_ARCHIVE" "$SUPABASE_DATA_DIR/supabase-go"

	if [ ! -f "$SUPABASE_DATA_DIR/supabase" ]; then
		log_error "Supabase binary not found after extraction"
		return 1
	fi

	chmod +x "$SUPABASE_DATA_DIR/supabase"
	printf '%s' "$version" >"$SUPABASE_DATA_DIR/.version"
	return 0
}

_download_supabase_binary() {
	local version="$1"
	loading "Downloading Supabase CLI v${version}" _download_supabase_binary_impl "$version"
}

_compile_supabase_helper_impl() {
	local helper_src="$CORE_PATH/tools/db/supabase/helper/supabase_helper.c"
	if [ ! -f "$helper_src" ]; then
		log_error "Helper source not found at $helper_src"
		return 1
	fi

	local build_dir
	build_dir=$(mktemp -d)
	sed "s|__DATA_DIR__|$SUPABASE_DATA_DIR|g" "$helper_src" >"$build_dir/supabase_helper.c"

	if ! clang -O2 -o "$PREFIX/bin/supabase" "$build_dir/supabase_helper.c" &>>"$LOG_FILE"; then
		rm -rf "$build_dir"
		log_error "Failed to compile supabase helper"
		return 1
	fi

	rm -rf "$build_dir"
	chmod +x "$PREFIX/bin/supabase"
	return 0
}

_compile_supabase_helper() {
	loading "Compiling helper" _compile_supabase_helper_impl
}

install_supabase() {
	if command -v supabase &>/dev/null; then
		log_info "Supabase CLI is already installed"
		return 2
	fi
	log_info "Installing Supabase CLI..."

	mkdir -p "$(dirname "$LOG_FILE")"

	_supabase_install_deps || return 1

	local version
	version=$(_get_remote_supabase_version)
	if [ -z "$version" ]; then
		log_error "Failed to fetch latest Supabase CLI version"
		return 1
	fi

	_download_supabase_binary "$version" || return 1
	_compile_supabase_helper || return 1

	log_success "Supabase CLI v${version} installed"
	log_warn "supabase start needs Docker/Podman (not available in Termux)"
	return 0
}

_uninstall_supabase_impl() {
	rm -f "$PREFIX/bin/supabase"
	rm -rf "$SUPABASE_DATA_DIR"
	return 0
}

uninstall_supabase() {
	if ! command -v supabase &>/dev/null && [ ! -f "$SUPABASE_DATA_DIR/supabase" ]; then
		log_info "Supabase CLI is not installed"
		return 2
	fi

	log_info "Uninstalling Supabase CLI..."
	loading "Uninstalling Supabase CLI" _uninstall_supabase_impl
}

_update_supabase_impl() {
	local version
	version=$(_get_remote_supabase_version)
	if [ -z "$version" ]; then
		log_error "Failed to fetch latest Supabase CLI version"
		return 1
	fi

	_download_supabase_binary "$version" || return 1
	_compile_supabase_helper || return 1

	log_success "Supabase CLI updated to v${version}"
	return 0
}

update_supabase() {
	mkdir -p "$(dirname "$LOG_FILE")"
	_check_update_needed "Supabase" "$(_get_installed_version supabase)" "$(_get_remote_supabase_version)" _update_supabase_impl
}

_update_supabase() {
	_update_supabase_impl
}

reinstall_supabase() {
	uninstall_supabase
	install_supabase
}
