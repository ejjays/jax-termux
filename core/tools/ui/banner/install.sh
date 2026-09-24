#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_ui.log"

CORE_BANNER_MARKER="# ===== Jax Banner ====="
CORE_BANNER_MARKER_LEGACY="# ===== Core-Termux Banner ====="
CORE_MOTD_BACKUP="$CORE_CACHE/motd.backup"

_backup_motd() {
	if [[ ! -e "$PREFIX/etc/motd" ]]; then
		return 0
	fi

	if [[ -e "$CORE_MOTD_BACKUP" ]]; then
		log_info "Termux MOTD already backed up"
		return 0
	fi

	log_info "Backing up Termux MOTD..."
	mv "$PREFIX/etc/motd" "$CORE_MOTD_BACKUP"
	log_success "Termux MOTD backed up to $CORE_MOTD_BACKUP"
}

_restore_motd() {
	if [[ ! -e "$CORE_MOTD_BACKUP" ]]; then
		return 0
	fi

	if [[ -e "$PREFIX/etc/motd" ]]; then
		log_warn "Termux MOTD already exists, skipping restore"
		return 0
	fi

	log_info "Restoring Termux MOTD..."
	mv "$CORE_MOTD_BACKUP" "$PREFIX/etc/motd"
	log_success "Termux MOTD restored"
}

_detect_shell_config() {
	if [[ -f "$HOME/.zshrc" ]]; then
		echo "$HOME/.zshrc"
	elif [[ -f "$HOME/.bashrc" ]]; then
		echo "$HOME/.bashrc"
	fi
}

_banner_installed() {
	local shell_config="$1"
	[[ -n "$shell_config" ]] || return 1
	grep -qF "$CORE_BANNER_MARKER" "$shell_config" 2>/dev/null ||
		grep -qF "$CORE_BANNER_MARKER_LEGACY" "$shell_config" 2>/dev/null
}

_find_banner_marker_line() {
	local shell_config="$1"
	grep -nF -e "$CORE_BANNER_MARKER" -e "$CORE_BANNER_MARKER_LEGACY" "$shell_config" 2>/dev/null |
		head -1 | cut -d: -f1
}

_migrate_banner_marker() {
	local shell_config="$1"
	if grep -qF "$CORE_BANNER_MARKER_LEGACY" "$shell_config" 2>/dev/null &&
		! grep -qF "$CORE_BANNER_MARKER" "$shell_config" 2>/dev/null; then
		sed -i "s|$CORE_BANNER_MARKER_LEGACY|$CORE_BANNER_MARKER|" "$shell_config"
		log_info "Migrated banner marker to Jax"
	fi
}

_repair_banner_source() {
	local shell_config="$1"
	local expected="$CORE_UTILS/banner.sh"
	[[ -n "$shell_config" && -f "$shell_config" ]] || return 1
	[[ -f "$expected" ]] || return 1

	local marker_line
	marker_line="$(_find_banner_marker_line "$shell_config")"
	[[ -n "$marker_line" ]] || return 1

	local source_line_num=$((marker_line + 1))
	local source_line
	source_line="$(sed -n "${source_line_num}p" "$shell_config" 2>/dev/null)"

	if [[ "$source_line" == "source \"$expected\"" ]]; then
		return 0
	fi

	if [[ "$source_line" =~ ^(source|\.)\  ]] || [[ "$source_line" =~ banner\.sh ]]; then
		sed -i "${source_line_num}s|.*|source \"$expected\"|" "$shell_config"
	else
		sed -i "${marker_line}a\\source \"$expected\"" "$shell_config"
	fi
	log_info "Repaired banner source path"
	return 0
}

_install_banner_impl() {
	local shell_config
	shell_config="$(_detect_shell_config)"

	if [[ -z "$shell_config" ]]; then
		log_warn "No shell config file found (.zshrc or .bashrc)"
		return 1
	fi

	if _banner_installed "$shell_config"; then
		_migrate_banner_marker "$shell_config"
		_repair_banner_source "$shell_config"
		log_info "Jax Banner already installed"
		return 0
	fi

	local banner_script="$CORE_UTILS/banner.sh"
	if [[ ! -f "$banner_script" ]]; then
		log_error "Banner script not found: $banner_script"
		return 1
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	# Insert banner BEFORE the Powerlevel10k instant-prompt block if present.
	# Appending after that block causes p10k's "console output during zsh
	# initialization" warning, because the banner prints to stdout.
	local p10k_marker="# Enable Powerlevel10k instant prompt."
	if grep -qF "$p10k_marker" "$shell_config" 2>/dev/null; then
		local tmp_config="${shell_config}.core_tmp"
		awk \
			-v p10k="$p10k_marker" \
			-v marker="$CORE_BANNER_MARKER" \
			-v script="$banner_script" \
			'!inserted && index($0, p10k) == 1 {
				print marker
				print "source \"" script "\""
				inserted = 1
			}
			{ print }' \
			"$shell_config" >"$tmp_config" && mv "$tmp_config" "$shell_config"
	else
		cat >>"$shell_config" <<EOF

$CORE_BANNER_MARKER
source "$banner_script"
EOF
	fi

	log_success "Jax Banner installed"

	_backup_motd

	log_warn "Restart Termux or run: source $shell_config"
	return 0
}

install_banner() {
	if _banner_installed "$(_detect_shell_config)"; then
		_migrate_banner_marker "$(_detect_shell_config)"
		_repair_banner_source "$(_detect_shell_config)"
		log_info "Jax Banner already installed"
		return 0
	fi
	log_info "Installing Jax Banner..."
	mkdir -p "$(dirname "$LOG_FILE")"
	loading "Installing Banner" _install_banner_impl
}

_uninstall_banner_impl() {
	local shell_config
	shell_config="$(_detect_shell_config)"

	if [[ -z "$shell_config" ]]; then
		log_warn "No shell config file found"
		return 1
	fi

	if ! _banner_installed "$shell_config"; then
		log_warn "Jax Banner not installed"
		return 0
	fi

	local marker_line
	marker_line="$(_find_banner_marker_line "$shell_config")"

	if [[ -n "$marker_line" ]]; then
		local prev_line=$((marker_line - 1))
		if sed -n "${prev_line}p" "$shell_config" 2>/dev/null | grep -q '^$'; then
			sed -i "$((prev_line)),$((marker_line + 1))d" "$shell_config"
		else
			sed -i "$marker_line,$((marker_line + 1))d" "$shell_config"
		fi
		log_success "Jax Banner uninstalled"
	else
		log_warn "Could not locate banner marker for removal"
		return 1
	fi

	_restore_motd

	return 0
}

uninstall_banner() {
	if ! _banner_installed "$(_detect_shell_config)"; then
		log_warn "Jax Banner not installed"
		return 0
	fi
	log_info "Uninstalling Jax Banner..."
	loading "Uninstalling Banner" _uninstall_banner_impl
}

update_banner() {
	log_info "Updating Jax Banner..."
	uninstall_banner
	install_banner
}

reinstall_banner() {
	uninstall_banner
	install_banner
}
