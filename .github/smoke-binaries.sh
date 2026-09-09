#!/usr/bin/env bash
set -u

PASS=0
FAIL=0
NL=$'\n'
SUMMARY_ROWS=""

gh_tag() {
	curl -fsSL "https://api.github.com/repos/$1/releases/latest" | jq -r '.tag_name // empty'
}

smoke() {
	local name="$1" url="$2" bin="$3"
	echo "==> $name"

	if [ -z "$url" ]; then
		echo "FAIL $name: empty download url"
		SUMMARY_ROWS+="| $name | FAIL | empty download url |$NL"
		FAIL=$((FAIL + 1))
		return
	fi

	if [ "${DRY_RUN:-0}" = "1" ]; then
		echo "$name -> $url"
		SUMMARY_ROWS+="| $name | pass | $url |$NL"
		PASS=$((PASS + 1))
		return
	fi

	local work
	work=$(mktemp -d)
	if ! curl -fsSL "$url" -o "$work/pkg" 2>"$work/err.log"; then
		echo "FAIL $name: download failed"
		cat "$work/err.log"
		SUMMARY_ROWS+="| $name | FAIL | download failed |$NL"
		FAIL=$((FAIL + 1))
		rm -rf "$work"
		return
	fi

	case "$url" in
	*.tar.gz | *.tgz) tar -xzf "$work/pkg" -C "$work" ;;
	*.tar.bz2) tar -xjf "$work/pkg" -C "$work" ;;
	*.zip) unzip -q "$work/pkg" -d "$work" ;;
	*) cp "$work/pkg" "$work/$bin" ;;
	esac

	local bin_path
	bin_path=$(find "$work" -name "$bin" -type f | head -1)
	if [ -z "$bin_path" ]; then
		echo "FAIL $name: binary '$bin' not in package, contains:"
		find "$work" -type f | head -10
		SUMMARY_ROWS+="| $name | FAIL | binary '$bin' not in package |$NL"
		FAIL=$((FAIL + 1))
		rm -rf "$work"
		return
	fi

	chmod +x "$bin_path"
	local detail rc
	detail=$("$bin_path" --version 2>&1 | head -1)
	rc=${PIPESTATUS[0]}
	if [ "$rc" -eq 0 ]; then
		echo "OK $name: $detail"
		SUMMARY_ROWS+="| $name | pass | $detail |$NL"
		PASS=$((PASS + 1))
	else
		echo "FAIL $name: --version failed"
		SUMMARY_ROWS+="| $name | FAIL | --version failed |$NL"
		FAIL=$((FAIL + 1))
	fi
	rm -rf "$work"
}

url_claude() {
	local tag
	tag=$(gh_tag anthropics/claude-code)
	[ -n "$tag" ] && echo "https://github.com/anthropics/claude-code/releases/download/$tag/claude-linux-arm64.tar.gz"
}

url_kilocode() {
	local tag
	tag=$(curl -fsSL "https://api.github.com/repos/Kilo-Org/kilocode/releases?per_page=10" | jq -r '.[].tag_name' | grep -v '^jetbrains/' | head -1)
	[ -n "$tag" ] && [ "$tag" != "null" ] && echo "https://github.com/Kilo-Org/kilocode/releases/download/$tag/kilo-linux-arm64.tar.gz"
}

url_kimchi() {
	local tag
	tag=$(gh_tag getkimchi/kimchi)
	[ -n "$tag" ] && echo "https://github.com/getkimchi/kimchi/releases/download/$tag/kimchi_linux_arm64.tar.gz"
}

url_mimocode() {
	local tag
	tag=$(gh_tag XiaomiMiMo/MiMo-Code)
	[ -n "$tag" ] && echo "https://github.com/XiaomiMiMo/MiMo-Code/releases/download/$tag/mimocode-linux-arm64.tar.gz"
}

url_opencode() {
	local tag
	tag=$(gh_tag anomalyco/opencode)
	[ -n "$tag" ] && echo "https://github.com/anomalyco/opencode/releases/download/$tag/opencode-linux-arm64.tar.gz"
}

url_goose() {
	local tag
	tag=$(curl -fsSL "https://api.github.com/repos/aaif-goose/goose/releases/latest" | jq -r '.tag_name')
	[ -n "$tag" ] && [ "$tag" != "null" ] && echo "https://github.com/aaif-goose/goose/releases/download/$tag/goose-aarch64-unknown-linux-gnu.tar.bz2"
}

url_omp() {
	local tag
	tag=$(curl -fsSL "https://api.github.com/repos/can1357/oh-my-pi/releases?per_page=5" | jq -r '[.[] | select(.tag_name | startswith("v"))][0].tag_name')
	[ -n "$tag" ] && [ "$tag" != "null" ] && echo "https://github.com/can1357/oh-my-pi/releases/download/$tag/omp-linux-arm64"
}

url_ampcode() {
	local ver
	ver=$(curl -fsSL "https://registry.npmjs.org/@ampcode/cli-linux-arm64/latest" | jq -r '.version')
	[ -n "$ver" ] && [ "$ver" != "null" ] && echo "https://registry.npmjs.org/@ampcode%2fcli-linux-arm64/-/cli-linux-arm64-$ver.tgz"
}

url_keelcode() {
	local ver
	ver=$(curl -fsSL "https://registry.npmjs.org/-/package/@keelcode-ai/keelcode/dist-tags" | jq -r '.["native-linux-arm64"]')
	[ -n "$ver" ] && [ "$ver" != "null" ] && echo "https://registry.npmjs.org/@keelcode-ai/keelcode/-/keelcode-$ver.tgz"
}

url_freebuff() {
	local ver
	ver=$(curl -fsSL https://api.github.com/repos/CodebuffAI/codebuff-community/releases/latest | jq -r '.tag_name // empty' | sed -E 's/^freebuff-v//')
	[ -n "$ver" ] && echo "https://codebuff.com/api/releases/download/$ver/freebuff-linux-arm64.tar.gz"
}

url_qoder() {
	local manifest
	manifest="$(curl -fsSL https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/channels/manifest.json)"
	printf '%s' "$manifest" | tr -d '\n\r\t ' | sed 's/},{/}\n{/g' |
		grep -F '"os":"linux"' | grep -F '"arch":"arm64"' | head -n1 |
		sed -n 's/.*"url"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p'
}

url_antigravity() {
	curl -fsSL https://antigravity-cli-auto-updater-974169037036.us-central1.run.app/manifests/linux_arm64.json | jq -r '.url'
}

url_droid() {
	local ver
	ver=$(curl -fsSL https://app.factory.ai/cli | grep -oE 'VER="[^"]+"' | head -1 | cut -d'"' -f2)
	[ -n "$ver" ] && echo "https://downloads.factory.ai/factory-cli/releases/$ver/linux/arm64/droid"
}

url_supabase() {
	curl -fsSL https://api.github.com/repos/supabase/cli/releases/latest | jq -r '.assets[].browser_download_url' |
		grep 'linux.*arm64.*\.tar\.gz' | grep -v -e '\.apk' -e '\.deb' -e '\.rpm' | head -1
}

smoke claude "$(url_claude)" claude
smoke kilocode "$(url_kilocode)" kilo
smoke kimchi "$(url_kimchi)" kimchi
smoke mimocode "$(url_mimocode)" mimo
smoke opencode "$(url_opencode)" opencode
smoke goose "$(url_goose)" goose
smoke oh-my-pi "$(url_omp)" omp
smoke ampcode "$(url_ampcode)" amp
smoke keelcode "$(url_keelcode)" keelcode
smoke freebuff "$(url_freebuff)" freebuff
smoke qoder "$(url_qoder)" qodercli
smoke antigravity "$(url_antigravity)" antigravity
smoke droid "$(url_droid)" droid
smoke supabase "$(url_supabase)" supabase

echo
echo "pass: $PASS fail: $FAIL"
if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
	{
		echo "## binaries smoke"
		echo
		echo "| tool | result | detail |"
		echo "|---|---|---|"
		printf '%s' "$SUMMARY_ROWS"
		echo
		echo "pass: $PASS fail: $FAIL"
	} >>"$GITHUB_STEP_SUMMARY"
fi
[ "$FAIL" -eq 0 ]
