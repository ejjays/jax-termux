#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_ui.log"
TERMUX_DIR="$HOME/.termux"

EXTRA_KEYS_MARKER="# ===== Jax Extra Keys ====="
EXTRA_KEYS_MARKER_END="# ===== End Jax Extra Keys ====="
EXTRA_KEYS_LEGACY_MARKER="terminal-cursor-blink-rate=500"

_extra_keys_installed() {
	local file="$TERMUX_DIR/termux.properties"
	grep -qF "$EXTRA_KEYS_MARKER" "$file" 2>/dev/null ||
		grep -qF "$EXTRA_KEYS_LEGACY_MARKER" "$file" 2>/dev/null
}

_strip_extra_keys() {
	local file="$1"
	[[ -f "$file" ]] || return 0
	local tmp="${file}.jax_tmp"
	awk -v start="$EXTRA_KEYS_MARKER" -v end="$EXTRA_KEYS_MARKER_END" '
		$0 == start { skip = 1; next }
		$0 == end { skip = 0; next }
		skip { next }
		/^terminal-cursor-blink-rate=500$/ { next }
		/^extra-keys[ \t]*=/ { next }
		{ print }
	' "$file" >"$tmp"
	mv "$tmp" "$file"
}

_install_extra_keys_impl() {
	mkdir -p "$(dirname "$LOG_FILE")" "$TERMUX_DIR"
	local file="$TERMUX_DIR/termux.properties"

	_strip_extra_keys "$file"

	{
		if [[ -s "$file" ]]; then
			echo ""
		fi
		echo "$EXTRA_KEYS_MARKER"
		echo "terminal-cursor-blink-rate=500"
		echo "extra-keys = [['ESC','</>','-','HOME',{key: 'UP', display: '▲'},'END','PGUP'], ['TAB','CTRL','ALT',{key: 'LEFT', display: '◀'},{key: 'DOWN', display: '▼'},{key: 'RIGHT', display: '▶'},'PGDN']]"
		echo "$EXTRA_KEYS_MARKER_END"
	} >>"$file"

	log_success "Extra-keys configured (other settings preserved)"
	return 0
}

install_extra_keys() {
	if _extra_keys_installed; then
		log_info "Extra Keys already installed"
		return 0
	fi
	log_info "Installing Extra Keys..."
	loading "Installing Extra Keys" _install_extra_keys_impl
}

_uninstall_extra_keys_impl() {
	local file="$TERMUX_DIR/termux.properties"
	if [[ ! -f "$file" ]]; then
		log_warn "Extra Keys not configured"
		return 0
	fi

	_strip_extra_keys "$file"

	if [[ ! -s "$file" ]]; then
		rm -f "$file"
	fi

	log_success "Extra Keys uninstalled (other settings preserved)"
	return 0
}

uninstall_extra_keys() {
	if ! _extra_keys_installed; then
		log_info "Extra Keys is not installed"
		return 0
	fi
	log_info "Uninstalling Extra Keys..."
	loading "Uninstalling Extra Keys" _uninstall_extra_keys_impl
}

update_extra_keys() {
	log_info "Updating Extra Keys..."
	loading "Updating Extra Keys" _install_extra_keys_impl
}

reinstall_extra_keys() {
	uninstall_extra_keys
	install_extra_keys
}
