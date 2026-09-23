#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ui.log"
TERMUX_DIR="$HOME/.termux"

UI_COMPONENTS=(
	"font"
	"extra-keys"
	"cursor"
	"banner"
)

source "$(dirname "$BASH_SOURCE")/font/install.sh"
source "$(dirname "$BASH_SOURCE")/extra-keys/install.sh"
source "$(dirname "$BASH_SOURCE")/cursor/install.sh"
source "$(dirname "$BASH_SOURCE")/banner/install.sh"

_report_ui_result() {
	local action="$1"
	local ok_count="$2"
	local failed_count="$3"

	if ((failed_count > 0)); then
		log_warn "$failed_count component(s) failed during $action ($ok_count succeeded)"
		return 1
	fi
	log_success "$ok_count component(s) ${action}ed"
	return 0
}

install_all_ui_components() {
	local installed_count=0
	local failed_count=0

	for tool in "${UI_COMPONENTS[@]}"; do
		case "$tool" in
		font)
			loading "Installing Meslo Nerd Font" install_font
			case $? in 0) ((installed_count++)) ;; 1) ((failed_count++)) ;; esac
			;;
		extra-keys)
			loading "Installing Extra Keys" install_extra_keys
			case $? in 0) ((installed_count++)) ;; 1) ((failed_count++)) ;; esac
			;;
		cursor)
			loading "Installing Cursor Color" install_cursor
			case $? in 0) ((installed_count++)) ;; 1) ((failed_count++)) ;; esac
			;;
		banner)
			loading "Installing Jax Banner" install_banner
			case $? in 0) ((installed_count++)) ;; 1) ((failed_count++)) ;; esac
			;;
		esac
	done

	_report_ui_result "installed" "$installed_count" "$failed_count"
}

uninstall_all_ui_components() {
	local uninstalled_count=0
	local failed_count=0

	for tool in "${UI_COMPONENTS[@]}"; do
		case "$tool" in
		font)
			loading "Uninstalling Meslo Nerd Font" uninstall_font
			case $? in 0) ((uninstalled_count++)) ;; 1) ((failed_count++)) ;; esac
			;;
		extra-keys)
			loading "Uninstalling Extra Keys" uninstall_extra_keys
			case $? in 0) ((uninstalled_count++)) ;; 1) ((failed_count++)) ;; esac
			;;
		cursor)
			loading "Uninstalling Cursor Color" uninstall_cursor
			case $? in 0) ((uninstalled_count++)) ;; 1) ((failed_count++)) ;; esac
			;;
		banner)
			loading "Uninstalling Jax Banner" uninstall_banner
			case $? in 0) ((uninstalled_count++)) ;; 1) ((failed_count++)) ;; esac
			;;
		esac
	done

	_report_ui_result "uninstalled" "$uninstalled_count" "$failed_count"
}

update_all_ui_components() {
	for tool in "${UI_COMPONENTS[@]}"; do
		case "$tool" in
		font)
			update_font
			;;
		extra-keys)
			update_extra_keys
			;;
		cursor)
			update_cursor
			;;
		banner)
			update_banner
			;;
		esac
	done
	echo
}

reinstall_all_ui_components() {
	local reinstalled_count=0
	local failed_count=0

	for tool in "${UI_COMPONENTS[@]}"; do
		case "$tool" in
		font)
			loading "Reinstalling Meslo Nerd Font" reinstall_font
			case $? in 0) ((reinstalled_count++)) ;; 1) ((failed_count++)) ;; esac
			;;
		extra-keys)
			loading "Reinstalling Extra Keys" reinstall_extra_keys
			case $? in 0) ((reinstalled_count++)) ;; 1) ((failed_count++)) ;; esac
			;;
		cursor)
			loading "Reinstalling Cursor Color" reinstall_cursor
			case $? in 0) ((reinstalled_count++)) ;; 1) ((failed_count++)) ;; esac
			;;
		banner)
			loading "Reinstalling Jax Banner" reinstall_banner
			case $? in 0) ((reinstalled_count++)) ;; 1) ((failed_count++)) ;; esac
			;;
		esac
	done

	_report_ui_result "reinstalled" "$reinstalled_count" "$failed_count"
}
