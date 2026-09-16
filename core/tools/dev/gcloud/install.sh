#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_dev.log"
GCLOUD_DATA_DIR="$HOME/.local/share/core-termux-data/gcloud"
GCLOUD_BASE_URL="https://dl.google.com/dl/cloudsdk/channels/rapid/downloads"
GCLOUD_VERSION_URL="https://dl.google.com/dl/cloudsdk/channels/rapid/components-2.json"

_gcloud_arch() {
	case "$(uname -m)" in
	aarch64 | arm64) echo "arm" ;;
	x86_64 | amd64) echo "x86_64" ;;
	*) echo "" ;;
	esac
}

_get_remote_gcloud_version() {
	curl -fsSL "$GCLOUD_VERSION_URL" 2>/dev/null \
		| python3 -c "import json,sys; print(json.load(sys.stdin).get('version',''))" 2>/dev/null
}

_gcloud_install_deps_impl() {
	declare -A DEPS=(
		["curl"]="curl"
		["tar"]="tar"
		["python"]="python3"
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

_gcloud_install_deps() {
	loading "Installing dependencies" _gcloud_install_deps_impl
}

_download_gcloud_impl() {
	local arch="$1"
	local archive="google-cloud-cli-linux-${arch}.tar.gz"
	local build_dir
	build_dir=$(mktemp -d)

	if ! curl -fSL "$GCLOUD_BASE_URL/$archive" -o "$build_dir/$archive" &>>"$LOG_FILE"; then
		rm -rf "$build_dir"
		log_error "Failed to download Google Cloud CLI"
		return 1
	fi

	rm -rf "$GCLOUD_DATA_DIR"
	mkdir -p "$GCLOUD_DATA_DIR"

	if ! tar -xzf "$build_dir/$archive" -C "$GCLOUD_DATA_DIR" --strip-components=1 &>>"$LOG_FILE"; then
		rm -rf "$build_dir"
		log_error "Failed to extract Google Cloud CLI"
		return 1
	fi

	rm -rf "$build_dir"

	if [ ! -x "$GCLOUD_DATA_DIR/bin/gcloud" ]; then
		log_error "gcloud binary not found after extraction"
		return 1
	fi

	if command -v termux-fix-shebang &>/dev/null; then
		termux-fix-shebang "$GCLOUD_DATA_DIR/bin/gcloud" "$GCLOUD_DATA_DIR/bin/gsutil" "$GCLOUD_DATA_DIR/bin/bq" &>>"$LOG_FILE" || true
	fi

	ln -sf "$GCLOUD_DATA_DIR/bin/gcloud" "$PREFIX/bin/gcloud"
	ln -sf "$GCLOUD_DATA_DIR/bin/gsutil" "$PREFIX/bin/gsutil"
	ln -sf "$GCLOUD_DATA_DIR/bin/bq" "$PREFIX/bin/bq"

	"$GCLOUD_DATA_DIR/bin/gcloud" config set disable_usage_reporting true &>>"$LOG_FILE" || true

	printf '%s' "$(_get_installed_version gcloud)" >"$GCLOUD_DATA_DIR/.version"
	return 0
}

_download_gcloud() {
	local arch="$1"
	loading "Downloading Google Cloud CLI" _download_gcloud_impl "$arch"
}

install_gcloud() {
	if command -v gcloud &>/dev/null; then
		log_info "Google Cloud CLI is already installed"
		return 2
	fi
	log_info "Installing Google Cloud CLI..."

	local arch
	arch=$(_gcloud_arch)
	if [ -z "$arch" ]; then
		log_error "Google Cloud CLI needs 64-bit ARM or x86_64 (detected: $(uname -m))"
		return 1
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	_gcloud_install_deps || return 1
	_download_gcloud "$arch" || return 1

	log_success "Google Cloud CLI $(cat "$GCLOUD_DATA_DIR/.version" 2>/dev/null) installed"
	log_info "Login with: gcloud auth login --no-launch-browser"
	return 0
}

_uninstall_gcloud_impl() {
	rm -f "$PREFIX/bin/gcloud" "$PREFIX/bin/gsutil" "$PREFIX/bin/bq"
	rm -rf "$GCLOUD_DATA_DIR"
	return 0
}

uninstall_gcloud() {
	if ! command -v gcloud &>/dev/null && [ ! -x "$GCLOUD_DATA_DIR/bin/gcloud" ]; then
		log_info "Google Cloud CLI is not installed"
		return 2
	fi

	log_info "Uninstalling Google Cloud CLI..."
	loading "Uninstalling Google Cloud CLI" _uninstall_gcloud_impl
	log_info "Kept login/config in ~/.config/gcloud"
}

_update_gcloud_impl() {
	local arch
	arch=$(_gcloud_arch)
	if [ -z "$arch" ]; then
		log_error "Unsupported architecture: $(uname -m)"
		return 1
	fi

	_download_gcloud "$arch" || return 1

	log_success "Google Cloud CLI updated to $(cat "$GCLOUD_DATA_DIR/.version" 2>/dev/null)"
	return 0
}

update_gcloud() {
	mkdir -p "$(dirname "$LOG_FILE")"
	_check_update_needed "Google Cloud CLI" "$(_get_installed_version gcloud)" "$(_get_remote_gcloud_version)" _update_gcloud_impl
}

reinstall_gcloud() {
	uninstall_gcloud
	install_gcloud
}
