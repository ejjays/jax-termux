#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_ui.log"
TERMUX_DIR="$HOME/.termux"

CURSOR_COLOR="#1CF289"
CURSOR_MARKER="# ===== Jax Cursor ====="
CURSOR_MARKER_END="# ===== End Jax Cursor ====="

_cursor_installed() {
	local file="$TERMUX_DIR/colors.properties"
	grep -qF "$CURSOR_MARKER" "$file" 2>/dev/null ||
		grep -qxF "cursor=$CURSOR_COLOR" "$file" 2>/dev/null
}

_strip_cursor() {
	local file="$1"
	[[ -f "$file" ]] || return 0
	local tmp="${file}.jax_tmp"
	awk -v start="$CURSOR_MARKER" -v end="$CURSOR_MARKER_END" '
		$0 == start { skip = 1; next }
		$0 == end { skip = 0; next }
		skip { next }
		/^cursor=/ { next }
		{ print }
	' "$file" >"$tmp"
	mv "$tmp" "$file"
}

_install_cursor_impl() {
	mkdir -p "$(dirname "$LOG_FILE")" "$TERMUX_DIR"
	local file="$TERMUX_DIR/colors.properties"

	_strip_cursor "$file"

	{
		if [[ -s "$file" ]]; then
			echo ""
		fi
		echo "$CURSOR_MARKER"
		echo "cursor=$CURSOR_COLOR"
		echo "$CURSOR_MARKER_END"
	} >>"$file"

	log_success "Cursor color set to $CURSOR_COLOR (other settings preserved)"
	return 0
}

install_cursor() {
	if _cursor_installed; then
		log_info "Cursor Color already configured"
		return 0
	fi
	log_info "Installing Cursor Color..."
	loading "Installing Cursor Color" _install_cursor_impl
}

_uninstall_cursor_impl() {
	local file="$TERMUX_DIR/colors.properties"
	if [[ ! -f "$file" ]]; then
		log_warn "Cursor Color not configured"
		return 0
	fi

	_strip_cursor "$file"

	if [[ ! -s "$file" ]]; then
		rm -f "$file"
	fi

	log_success "Cursor Color uninstalled (other settings preserved)"
	return 0
}

uninstall_cursor() {
	if ! _cursor_installed; then
		log_info "Cursor Color is not installed"
		return 0
	fi
	log_info "Uninstalling Cursor Color..."
	loading "Uninstalling Cursor Color" _uninstall_cursor_impl
}

update_cursor() {
	log_info "Updating Cursor Color..."
	loading "Updating Cursor Color" _install_cursor_impl
}

reinstall_cursor() {
	uninstall_cursor
	install_cursor
}
