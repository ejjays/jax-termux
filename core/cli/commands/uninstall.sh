#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"
import "@/utils/telemetry"

uninstall_main() {

  if [[ $# -eq 0 ]]; then
    echo
    box "Jax Uninstall"
    echo
    log_info "Usage: jax uninstall <target>"
    log_info "Usage: jax uninstall <target> --tool1 --tool2"
    echo
    log_info "Available targets:"
    echo
    list_item "lang       - Remove language packages"
    list_item "db         - Remove databases"
    list_item "ai         - Remove AI tools"
    list_item "editor     - Remove code editor"
    list_item "dev        - Remove development tools"
    list_item "npm        - Remove Node.js global modules"
    list_item "shell      - Remove ZSH + Oh My Zsh"
    list_item "ui         - Restore Termux UI to default"
    list_item "auto       - Remove automation tools"
    echo
    log_info "Uninstall specific tools with flags:"
    echo
    list_item "jax uninstall ai --qwen-code --ollama"
    list_item "jax uninstall db --postgresql --sqlite"
    list_item "Run ${D_CYAN}jax list <target>${D_NC} to see all available tools"
    echo
    log_warn "Warning: This will remove installed packages and configurations!"
    echo
    return
  fi

  # Separate module target from tool flags
  local module_target=""
  local -a tool_flags=()

  for arg in "$@"; do
    if [[ "$arg" == --* ]]; then
      local flag="${arg#--}"
      tool_flags+=("$flag")
    elif [[ -z "$module_target" ]]; then
      module_target="$arg"
    fi
  done

  # If no module target specified, show error
  if [[ -z "$module_target" ]]; then
    log_error "No target specified"
    echo "Run 'jax uninstall' to see available targets"
    return 1
  fi

  # If no tool flags, uninstall entire module (original behavior)
  if [[ ${#tool_flags[@]} -eq 0 ]]; then
    _uninstall_full_module "$module_target"
  else
    # Uninstall specific tools
    _uninstall_specific_tools "$module_target" "${tool_flags[@]}"
  fi
}

# Uninstall entire module (original behavior)
_uninstall_full_module() {
  local target="$1"

  case "$target" in
  lang)
    import "@/modules/lang"
    uninstall_lang
    ;;
  db)
    import "@/modules/db"
    uninstall_db
    ;;
  ai)
    import "@/modules/ai"
    uninstall_ai
    ;;
  editor)
    import "@/modules/editor"
    uninstall_editor
    ;;
  dev)
    import "@/modules/dev"
    uninstall_dev
    ;;
  npm)
    import "@/modules/npm"
    uninstall_npm
    ;;
  shell)
    import "@/modules/shell"
    uninstall_shell
    ;;
  ui)
    import "@/modules/ui"
    uninstall_ui
    ;;
  auto)
    import "@/modules/auto"
    uninstall_auto
    ;;
  *)
    log_warn "Unknown uninstall target: $target"
    echo "Run 'jax uninstall' to see available targets"
    ;;
  esac
}

# Uninstall specific tools within a module
_uninstall_specific_tools() {
  local module="$1"
  shift
  local -a tools=("$@")

  case "$module" in
  ai)
    import "@/tools/ai/all"
    local uninstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      qwen-code)
        uninstall_qwen_code
        _tool_result uninstall ai qwen-code $? uninstalled_count failed_count
        ;;
      gemini-cli)
        uninstall_gemini_cli
        _tool_result uninstall ai gemini-cli $? uninstalled_count failed_count
        ;;
      claude-code)
        uninstall_claude_code
        _tool_result uninstall ai claude-code $? uninstalled_count failed_count
        ;;
      mistral-vibe)
        uninstall_mistral_vibe
        _tool_result uninstall ai mistral-vibe $? uninstalled_count failed_count
        ;;
      openclaude)
        uninstall_openclaude
        _tool_result uninstall ai openclaude $? uninstalled_count failed_count
        ;;
      openclaw)
        uninstall_openclaw
        _tool_result uninstall ai openclaw $? uninstalled_count failed_count
        ;;
      ollama)
        uninstall_ollama
        _tool_result uninstall ai ollama $? uninstalled_count failed_count
        ;;
      codex)
        uninstall_codex
        _tool_result uninstall ai codex $? uninstalled_count failed_count
        ;;
      opencode)
        uninstall_opencode
        _tool_result uninstall ai opencode $? uninstalled_count failed_count
        ;;
      qoder)
        uninstall_qoder
        _tool_result uninstall ai qoder $? uninstalled_count failed_count
        ;;
      kilocode-cli)
        uninstall_kilocode_cli
        _tool_result uninstall ai kilocode-cli $? uninstalled_count failed_count
        ;;
      cactus-needle)
        uninstall_cactus_needle
        _tool_result uninstall ai cactus-needle $? uninstalled_count failed_count
        ;;
      cactus)
        uninstall_cactus_cli
        _tool_result uninstall ai cactus $? uninstalled_count failed_count
        ;;
      keelcode)
        uninstall_keelcode
        _tool_result uninstall ai keelcode $? uninstalled_count failed_count
        ;;
      cursor-cli)
        uninstall_cursor_cli
        _tool_result uninstall ai cursor-cli $? uninstalled_count failed_count
        ;;
      kimchi)
        uninstall_kimchi
        _tool_result uninstall ai kimchi $? uninstalled_count failed_count
        ;;
      mimocode)
        uninstall_mimocode
        _tool_result uninstall ai mimocode $? uninstalled_count failed_count
        ;;
      engram)
        uninstall_engram
        _tool_result uninstall ai engram $? uninstalled_count failed_count
        ;;
      codegraph)
        uninstall_codegraph
        _tool_result uninstall ai codegraph $? uninstalled_count failed_count
        ;;
      pi)
        uninstall_pi
        _tool_result uninstall ai pi $? uninstalled_count failed_count
        ;;
      oh-my-pi)
        uninstall_oh_my_pi
        _tool_result uninstall ai oh-my-pi $? uninstalled_count failed_count
        ;;
      antigravity-cli)
        uninstall_antigravity_cli
        _tool_result uninstall ai antigravity-cli $? uninstalled_count failed_count
        ;;
      minimax-cli)
        uninstall_minimax_cli
        _tool_result uninstall ai minimax-cli $? uninstalled_count failed_count
        ;;
      gentle-ai)
        uninstall_gentle_ai
        _tool_result uninstall ai gentle-ai $? uninstalled_count failed_count
        ;;
      gga)
        uninstall_gga
        _tool_result uninstall ai gga $? uninstalled_count failed_count
        ;;
      hermes-agent)
        uninstall_hermes_agent
        _tool_result uninstall ai hermes-agent $? uninstalled_count failed_count
        ;;
      kimi-code)
        uninstall_kimi_code
        _tool_result uninstall ai kimi-code $? uninstalled_count failed_count
        ;;
      command-code)
        uninstall_command_code
        _tool_result uninstall ai command-code $? uninstalled_count failed_count
        ;;
      freebuff)
        uninstall_freebuff
        _tool_result uninstall ai freebuff $? uninstalled_count failed_count
        ;;
      ctx7)
        uninstall_ctx7
        _tool_result uninstall ai ctx7 $? uninstalled_count failed_count
        ;;
      openspec)
        uninstall_openspec
        _tool_result uninstall ai openspec $? uninstalled_count failed_count
        ;;
      supercode)
        uninstall_supercode
        _tool_result uninstall ai supercode $? uninstalled_count failed_count
        ;;
      cline)
        uninstall_cline
        _tool_result uninstall ai cline $? uninstalled_count failed_count
        ;;
      ampcode)
        uninstall_amp_code_cli
        _tool_result uninstall ai ampcode $? uninstalled_count failed_count
        ;;
      droid-factory)
        uninstall_droid_factory
        _tool_result uninstall ai droid-factory $? uninstalled_count failed_count
        ;;
      hugging-face)
        uninstall_hugging_face
        _tool_result uninstall ai hugging-face $? uninstalled_count failed_count
        ;;
      goose)
        uninstall_goose
        _tool_result uninstall ai goose $? uninstalled_count failed_count
        ;;
      walkie)
        uninstall_walkie
        _tool_result uninstall ai walkie $? uninstalled_count failed_count
        ;;
      *)
        log_warn "Unknown AI tool: --$tool"
        ;;
      esac
    done

    echo
    if [[ $uninstalled_count -gt 0 ]]; then
      log_success "$uninstalled_count AI tool(s) uninstalled"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count tool(s) failed to uninstall"
    fi
    echo
    ;;
  db)
    import "@/tools/db/all"
    local uninstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      postgresql)
        uninstall_postgresql
        _tool_result uninstall db postgresql $? uninstalled_count failed_count
        ;;
      mariadb)
        uninstall_mariadb
        _tool_result uninstall db mariadb $? uninstalled_count failed_count
        ;;
      sqlite)
        uninstall_sqlite
        _tool_result uninstall db sqlite $? uninstalled_count failed_count
        ;;
      mongodb)
        uninstall_mongodb
        _tool_result uninstall db mongodb $? uninstalled_count failed_count
        ;;
      redis)
        uninstall_redis
        _tool_result uninstall db redis $? uninstalled_count failed_count
        ;;
      supabase)
        uninstall_supabase
        _tool_result uninstall db supabase $? uninstalled_count failed_count
        ;;
      *)
        log_warn "Unknown database: --$tool"
        ;;
      esac
    done

    echo
    if [[ $uninstalled_count -gt 0 ]]; then
      log_success "$uninstalled_count database(s) uninstalled"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count database(s) failed to uninstall"
    fi
    echo
    ;;
  dev)
    import "@/tools/dev/all"
    local uninstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      gh)
        uninstall_gh
        _tool_result uninstall dev gh $? uninstalled_count failed_count
        ;;
      wget)
        uninstall_wget
        _tool_result uninstall dev wget $? uninstalled_count failed_count
        ;;
      curl)
        uninstall_curl
        _tool_result uninstall dev curl $? uninstalled_count failed_count
        ;;
      lsd)
        uninstall_lsd
        _tool_result uninstall dev lsd $? uninstalled_count failed_count
        ;;
      bat)
        uninstall_bat
        _tool_result uninstall dev bat $? uninstalled_count failed_count
        ;;
      proot)
        uninstall_proot
        _tool_result uninstall dev proot $? uninstalled_count failed_count
        ;;
      ncurses)
        uninstall_ncurses
        _tool_result uninstall dev ncurses $? uninstalled_count failed_count
        ;;
      tmate)
        uninstall_tmate
        _tool_result uninstall dev tmate $? uninstalled_count failed_count
        ;;
      tmux)
        uninstall_tmux
        _tool_result uninstall dev tmux $? uninstalled_count failed_count
        ;;
      openssh)
        uninstall_openssh
        _tool_result uninstall dev openssh $? uninstalled_count failed_count
        ;;
      cloudflared)
        uninstall_cloudflared
        _tool_result uninstall dev cloudflared $? uninstalled_count failed_count
        ;;
      translate)
        uninstall_translate
        _tool_result uninstall dev translate $? uninstalled_count failed_count
        ;;
      html2text)
        uninstall_html2text
        _tool_result uninstall dev html2text $? uninstalled_count failed_count
        ;;
      jq)
        uninstall_jq
        _tool_result uninstall dev jq $? uninstalled_count failed_count
        ;;
      bc)
        uninstall_bc
        _tool_result uninstall dev bc $? uninstalled_count failed_count
        ;;
      tree)
        uninstall_tree
        _tool_result uninstall dev tree $? uninstalled_count failed_count
        ;;
      fzf)
        uninstall_fzf
        _tool_result uninstall dev fzf $? uninstalled_count failed_count
        ;;
      imagemagick)
        uninstall_imagemagick
        _tool_result uninstall dev imagemagick $? uninstalled_count failed_count
        ;;
      shfmt)
        uninstall_shfmt
        _tool_result uninstall dev shfmt $? uninstalled_count failed_count
        ;;
      make)
        uninstall_make
        _tool_result uninstall dev make $? uninstalled_count failed_count
        ;;
      udocker)
        uninstall_udocker
        _tool_result uninstall dev udocker $? uninstalled_count failed_count
        ;;
      superfile)
        uninstall_superfile
        _tool_result uninstall dev superfile $? uninstalled_count failed_count
        ;;
      gcloud)
        uninstall_gcloud
        _tool_result uninstall dev gcloud $? uninstalled_count failed_count
        ;;
      *)
        log_warn "Unknown tool: --$tool"
        ;;
      esac
    done

    echo
    if [[ $uninstalled_count -gt 0 ]]; then
      log_success "$uninstalled_count tool(s) uninstalled"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count tool(s) failed to uninstall"
    fi
    echo
    ;;
  npm)
    import "@/tools/npm/all"
    local uninstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      typescript)
        uninstall_typescript
        _tool_result uninstall npm typescript $? uninstalled_count failed_count
        ;;
      nestjs)
        uninstall_nestjs
        _tool_result uninstall npm nestjs $? uninstalled_count failed_count
        ;;
      prettier)
        uninstall_prettier
        _tool_result uninstall npm prettier $? uninstalled_count failed_count
        ;;
      live-server)
        uninstall_live_server
        _tool_result uninstall npm live-server $? uninstalled_count failed_count
        ;;
      localtunnel)
        uninstall_localtunnel
        _tool_result uninstall npm localtunnel $? uninstalled_count failed_count
        ;;
      vercel)
        uninstall_vercel
        _tool_result uninstall npm vercel $? uninstalled_count failed_count
        ;;
      wrangler)
        uninstall_wrangler
        _tool_result uninstall npm wrangler $? uninstalled_count failed_count
        ;;
      firebase)
        uninstall_firebase
        _tool_result uninstall npm firebase $? uninstalled_count failed_count
        ;;
      markserv)
        uninstall_markserv
        _tool_result uninstall npm markserv $? uninstalled_count failed_count
        ;;
      psqlformat)
        uninstall_psqlformat
        _tool_result uninstall npm psqlformat $? uninstalled_count failed_count
        ;;
      ncu)
        uninstall_ncu
        _tool_result uninstall npm ncu $? uninstalled_count failed_count
        ;;
      ngrok)
        uninstall_ngrok
        _tool_result uninstall npm ngrok $? uninstalled_count failed_count
        ;;
      turbopack)
        uninstall_turbopack
        _tool_result uninstall npm turbopack $? uninstalled_count failed_count
        ;;
      *)
        log_warn "Unknown node module: --$tool"
        ;;
      esac
    done

    echo
    if [[ $uninstalled_count -gt 0 ]]; then
      log_success "$uninstalled_count Node.js module(s) uninstalled"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count module(s) failed to uninstall"
    fi
    echo
    ;;
  lang)
    import "@/tools/lang/all"
    local uninstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      nodejs)
        uninstall_npmjs
        _tool_result uninstall lang nodejs $? uninstalled_count failed_count
        ;;
      python)
        uninstall_python
        _tool_result uninstall lang python $? uninstalled_count failed_count
        ;;
      perl)
        uninstall_perl
        _tool_result uninstall lang perl $? uninstalled_count failed_count
        ;;
      php)
        uninstall_php
        _tool_result uninstall lang php $? uninstalled_count failed_count
        ;;
      rust)
        uninstall_rust
        _tool_result uninstall lang rust $? uninstalled_count failed_count
        ;;
      clang)
        uninstall_clang
        _tool_result uninstall lang clang $? uninstalled_count failed_count
        ;;
      golang)
        uninstall_golang
        _tool_result uninstall lang golang $? uninstalled_count failed_count
        ;;
      bun)
        uninstall_bun
        _tool_result uninstall lang bun $? uninstalled_count failed_count
        ;;
      *)
        log_warn "Unknown language: --$tool"
        ;;
      esac
    done

    echo
    if [[ $uninstalled_count -gt 0 ]]; then
      log_success "$uninstalled_count language(s) uninstalled"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count language(s) failed to uninstall"
    fi
    echo
    ;;
  shell)
    import "@/tools/shell/all"
    local uninstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      powerlevel10k)
        uninstall_powerlevel10k
        _tool_result uninstall shell powerlevel10k $? uninstalled_count failed_count
        ;;
      zsh-defer)
        uninstall_zsh_defer
        _tool_result uninstall shell zsh-defer $? uninstalled_count failed_count
        ;;
      zsh-autosuggestions)
        uninstall_zsh_autosuggestions
        _tool_result uninstall shell zsh-autosuggestions $? uninstalled_count failed_count
        ;;
      zsh-syntax-highlighting)
        uninstall_zsh_syntax_highlighting
        _tool_result uninstall shell zsh-syntax-highlighting $? uninstalled_count failed_count
        ;;
      history-substring)
        uninstall_history_substring
        _tool_result uninstall shell history-substring $? uninstalled_count failed_count
        ;;
      zsh-completions)
        uninstall_zsh_completions
        _tool_result uninstall shell zsh-completions $? uninstalled_count failed_count
        ;;
      fzf-tab)
        uninstall_fzf_tab
        _tool_result uninstall shell fzf-tab $? uninstalled_count failed_count
        ;;
      you-should-use)
        uninstall_you_should_use
        _tool_result uninstall shell you-should-use $? uninstalled_count failed_count
        ;;
      zsh-autopair)
        uninstall_zsh_autopair
        _tool_result uninstall shell zsh-autopair $? uninstalled_count failed_count
        ;;
      better-npm)
        uninstall_better_npm
        _tool_result uninstall shell better-npm $? uninstalled_count failed_count
        ;;
      *)
        log_warn "Unknown plugin: --$tool"
        ;;
      esac
    done

    echo
    if [[ $uninstalled_count -gt 0 ]]; then
      log_success "$uninstalled_count plugin(s) uninstalled"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count plugin(s) failed to uninstall"
    fi
    echo
    ;;
  editor)
    import "@/tools/editor/all"
    local uninstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      neovim)
        uninstall_neovim
        _tool_result uninstall editor neovim $? uninstalled_count failed_count
        ;;
      nvchad)
        uninstall_nvchad
        _tool_result uninstall editor nvchad $? uninstalled_count failed_count
        ;;
      *)
        log_warn "Unknown editor component: --$tool"
        ;;
      esac
    done

    echo
    if [[ $uninstalled_count -gt 0 ]]; then
      log_success "$uninstalled_count editor component(s) uninstalled"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count component(s) failed to uninstall"
    fi
    echo
    ;;
  ui)
    import "@/tools/ui/all"
    local uninstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      font)
        uninstall_font
        _tool_result uninstall ui font $? uninstalled_count failed_count
        ;;
      extra-keys)
        uninstall_extra_keys
        _tool_result uninstall ui extra-keys $? uninstalled_count failed_count
        ;;
      cursor)
        uninstall_cursor
        _tool_result uninstall ui cursor $? uninstalled_count failed_count
        ;;
      banner)
        uninstall_banner
        _tool_result uninstall ui banner $? uninstalled_count failed_count
        ;;
      *)
        log_warn "Unknown UI component: --$tool"
        ;;
      esac
    done

    echo
    if [[ $uninstalled_count -gt 0 ]]; then
      log_success "$uninstalled_count UI component(s) uninstalled"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count component(s) failed to uninstall"
    fi
    echo
    ;;
  auto)
    import "@/tools/auto/all"
    local uninstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      n8n)
        uninstall_n8n
        _tool_result uninstall auto n8n $? uninstalled_count failed_count
        ;;
      *)
        log_warn "Unknown automation tool: --$tool"
        ;;
      esac
    done

    echo
    if [[ $uninstalled_count -gt 0 ]]; then
      log_success "$uninstalled_count automation tool(s) uninstalled"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count tool(s) failed to uninstall"
    fi
    echo
    ;;
  *)
    log_warn "Unknown uninstall target: $module"
    echo "Run 'jax uninstall' to see available targets"
    ;;
  esac
}
