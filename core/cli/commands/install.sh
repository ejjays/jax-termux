#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"
import "@/utils/telemetry"

install_main() {

  if [[ $# -eq 0 ]]; then
    echo
    box "Jax Install"
    echo
    log_info "Usage: jax install <target>"
    log_info "Usage: jax install <target> --tool1 --tool2"
    echo
    log_info "Available targets:"
    echo
    list_item "lang       - Language packages (Node.js, Python, Perl, PHP, Rust, C, C++, Go)"
    list_item "db         - Databases (PostgreSQL, MariaDB, SQLite, MongoDB, Redis, Supabase)"
    list_item "ai         - AI tools (OpenCode, Gentle AI, Claude Code, etc.)"
    list_item "editor     - Code editor (Neovim + NvChad)"
    list_item "dev        - Development tools"
    list_item "npm        - Node.js global modules (npm packages)"
    list_item "shell      - ZSH + Oh My Zsh + plugins"
    list_item "ui         - Termux UI (font, cursor, extra-keys, banner)"
    list_item "auto       - Automation Tools (n8n)"

    echo
    log_info "Install specific tools with flags:"
    echo
    list_item "jax install ai --qwen-code --ollama"
    list_item "jax install db --postgresql --sqlite"
    list_item "jax install dev --gh --fzf --jq"
    list_item "Run ${D_CYAN}jax list <target>${D_NC} to see all available tools"
    echo
    return
  fi

  # Separate module target from tool flags
  local module_target=""
  local -a tool_flags=()

  for arg in "$@"; do
    if [[ "$arg" == --* ]]; then
      # Remove -- prefix and convert to lowercase
      local flag="${arg#--}"
      tool_flags+=("$flag")
    elif [[ -z "$module_target" ]]; then
      module_target="$arg"
    fi
  done

  # If no module target specified, show error
  if [[ -z "$module_target" ]]; then
    log_error "No target specified"
    echo "Run 'jax install' to see available targets"
    return 1
  fi

  # If no tool flags, install entire module (original behavior)
  if [[ ${#tool_flags[@]} -eq 0 ]]; then
    _install_full_module "$module_target"
  else
    # Install specific tools
    _install_specific_tools "$module_target" "${tool_flags[@]}"
  fi
}

# Install entire module (original behavior)
_install_full_module() {
  local target="$1"

  case "$target" in
  db)
    import "@/modules/db"
    install_db
    ;;
  ai)
    import "@/modules/ai"
    install_ai
    ;;
  editor)
    import "@/modules/editor"
    install_editor
    ;;
  lang)
    import "@/modules/lang"
    install_lang
    ;;
  dev)
    import "@/modules/dev"
    install_dev
    ;;
  npm)
    import "@/modules/npm"
    install_npm
    ;;
  shell)
    import "@/modules/shell"
    install_shell
    ;;
  ui)
    import "@/modules/ui"
    setup_ui
    ;;
  auto)
    import "@/modules/auto"
    install_auto
    ;;
  *)
    log_warn "Unknown install target: $target"
    echo "Run 'jax install' to see available targets"
    ;;
  esac
}

# Install specific tools within a module
_install_specific_tools() {
  local module="$1"
  shift
  local -a tools=("$@")

  case "$module" in
  ai)
    import "@/tools/ai/all"
    local installed_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      qwen-code)
        install_qwen_code
        _tool_result install ai qwen-code $? installed_count failed_count
        ;;
      gemini-cli)
        install_gemini_cli
        _tool_result install ai gemini-cli $? installed_count failed_count
        ;;
      claude-code)
        install_claude_code
        _tool_result install ai claude-code $? installed_count failed_count
        ;;
      mistral-vibe)
        install_mistral_vibe
        _tool_result install ai mistral-vibe $? installed_count failed_count
        ;;
      openclaude)
        install_openclaude
        _tool_result install ai openclaude $? installed_count failed_count
        ;;
      openclaw)
        install_openclaw
        _tool_result install ai openclaw $? installed_count failed_count
        ;;
      ollama)
        install_ollama
        _tool_result install ai ollama $? installed_count failed_count
        ;;
      codex)
        install_codex
        _tool_result install ai codex $? installed_count failed_count
        ;;
      opencode)
        install_opencode
        _tool_result install ai opencode $? installed_count failed_count
        ;;
      qoder)
        install_qoder
        _tool_result install ai qoder $? installed_count failed_count
        ;;
      kilocode-cli)
        install_kilocode_cli
        _tool_result install ai kilocode-cli $? installed_count failed_count
        ;;
      cactus-needle)
        install_cactus_needle
        _tool_result install ai cactus-needle $? installed_count failed_count
        ;;
      cactus)
        install_cactus_cli
        _tool_result install ai cactus $? installed_count failed_count
        ;;
      keelcode)
        install_keelcode
        _tool_result install ai keelcode $? installed_count failed_count
        ;;
      cursor-cli)
        install_cursor_cli
        _tool_result install ai cursor-cli $? installed_count failed_count
        ;;
      kimchi)
        install_kimchi
        _tool_result install ai kimchi $? installed_count failed_count
        ;;
      mimocode)
        install_mimocode
        _tool_result install ai mimocode $? installed_count failed_count
        ;;
      engram)
        install_engram
        _tool_result install ai engram $? installed_count failed_count
        ;;
      codegraph)
        install_codegraph
        _tool_result install ai codegraph $? installed_count failed_count
        ;;
      pi)
        install_pi
        _tool_result install ai pi $? installed_count failed_count
        ;;
      oh-my-pi)
        install_oh_my_pi
        _tool_result install ai oh-my-pi $? installed_count failed_count
        ;;
      antigravity-cli)
        install_antigravity_cli
        _tool_result install ai antigravity-cli $? installed_count failed_count
        ;;
      minimax-cli)
        install_minimax_cli
        _tool_result install ai minimax-cli $? installed_count failed_count
        ;;
      gentle-ai)
        install_gentle_ai
        _tool_result install ai gentle-ai $? installed_count failed_count
        ;;
      gga)
        install_gga
        _tool_result install ai gga $? installed_count failed_count
        ;;
      hermes-agent)
        install_hermes_agent
        _tool_result install ai hermes-agent $? installed_count failed_count
        ;;
      kimi-code)
        install_kimi_code
        _tool_result install ai kimi-code $? installed_count failed_count
        ;;
      command-code)
        install_command_code
        _tool_result install ai command-code $? installed_count failed_count
        ;;
      freebuff)
        install_freebuff
        _tool_result install ai freebuff $? installed_count failed_count
        ;;
      ctx7)
        install_ctx7
        _tool_result install ai ctx7 $? installed_count failed_count
        ;;
      openspec)
        install_openspec
        _tool_result install ai openspec $? installed_count failed_count
        ;;
      supercode)
        install_supercode
        _tool_result install ai supercode $? installed_count failed_count
        ;;
      cline)
        install_cline
        _tool_result install ai cline $? installed_count failed_count
        ;;
      ampcode)
        install_amp_code_cli
        _tool_result install ai ampcode $? installed_count failed_count
        ;;
      droid-factory)
        install_droid_factory
        _tool_result install ai droid-factory $? installed_count failed_count
        ;;
      hugging-face)
        install_hugging_face
        _tool_result install ai hugging-face $? installed_count failed_count
        ;;
      goose)
        install_goose
        _tool_result install ai goose $? installed_count failed_count
        ;;
      walkie)
        install_walkie
        _tool_result install ai walkie $? installed_count failed_count
        ;;
      *)
        log_warn "Unknown AI tool: --$tool"
        ;;
      esac
    done

    echo
    if [[ $installed_count -gt 0 ]]; then
      log_success "$installed_count AI tool(s) installed"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count tool(s) failed to install"
    fi
    echo
    ;;
  db)
    import "@/tools/db/all"
    local installed_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      postgresql)
        install_postgresql
        _tool_result install db postgresql $? installed_count failed_count
        ;;
      mariadb)
        install_mariadb
        _tool_result install db mariadb $? installed_count failed_count
        ;;
      sqlite)
        install_sqlite
        _tool_result install db sqlite $? installed_count failed_count
        ;;
      mongodb)
        install_mongodb
        _tool_result install db mongodb $? installed_count failed_count
        ;;
      redis)
        install_redis
        _tool_result install db redis $? installed_count failed_count
        ;;
      supabase)
        install_supabase
        _tool_result install db supabase $? installed_count failed_count
        ;;
      *)
        log_warn "Unknown database: --$tool"
        ;;
      esac
    done

    echo
    if [[ $installed_count -gt 0 ]]; then
      log_success "$installed_count database(s) installed"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count database(s) failed to install"
    fi
    echo
    ;;
  dev)
    import "@/tools/dev/all"
    local installed_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      gh)
        install_gh
        _tool_result install dev gh $? installed_count failed_count
        ;;
      wget)
        install_wget
        _tool_result install dev wget $? installed_count failed_count
        ;;
      curl)
        install_curl
        _tool_result install dev curl $? installed_count failed_count
        ;;
      lsd)
        install_lsd
        _tool_result install dev lsd $? installed_count failed_count
        ;;
      bat)
        install_bat
        _tool_result install dev bat $? installed_count failed_count
        ;;
      proot)
        install_proot
        _tool_result install dev proot $? installed_count failed_count
        ;;
      ncurses)
        install_ncurses
        _tool_result install dev ncurses $? installed_count failed_count
        ;;
      tmate)
        install_tmate
        _tool_result install dev tmate $? installed_count failed_count
        ;;
      tmux)
        install_tmux
        _tool_result install dev tmux $? installed_count failed_count
        ;;
      openssh)
        install_openssh
        _tool_result install dev openssh $? installed_count failed_count
        ;;
      cloudflared)
        install_cloudflared
        _tool_result install dev cloudflared $? installed_count failed_count
        ;;
      translate)
        install_translate
        _tool_result install dev translate $? installed_count failed_count
        ;;
      html2text)
        install_html2text
        _tool_result install dev html2text $? installed_count failed_count
        ;;
      jq)
        install_jq
        _tool_result install dev jq $? installed_count failed_count
        ;;
      bc)
        install_bc
        _tool_result install dev bc $? installed_count failed_count
        ;;
      tree)
        install_tree
        _tool_result install dev tree $? installed_count failed_count
        ;;
      fzf)
        install_fzf
        _tool_result install dev fzf $? installed_count failed_count
        ;;
      imagemagick)
        install_imagemagick
        _tool_result install dev imagemagick $? installed_count failed_count
        ;;
      shfmt)
        install_shfmt
        _tool_result install dev shfmt $? installed_count failed_count
        ;;
      make)
        install_make
        _tool_result install dev make $? installed_count failed_count
        ;;
      udocker)
        install_udocker
        _tool_result install dev udocker $? installed_count failed_count
        ;;
      superfile)
        install_superfile
        _tool_result install dev superfile $? installed_count failed_count
        ;;
      gcloud)
        install_gcloud
        _tool_result install dev gcloud $? installed_count failed_count
        ;;
      *)
        log_warn "Unknown tool: --$tool"
        ;;
      esac
    done

    echo
    if [[ $installed_count -gt 0 ]]; then
      log_success "$installed_count tool(s) installed"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count tool(s) failed to install"
    fi
    echo
    ;;
  npm)
    import "@/tools/npm/all"
    local installed_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      typescript)
        install_typescript
        _tool_result install npm typescript $? installed_count failed_count
        ;;
      nestjs)
        install_nestjs
        _tool_result install npm nestjs $? installed_count failed_count
        ;;
      prettier)
        install_prettier
        _tool_result install npm prettier $? installed_count failed_count
        ;;
      live-server)
        install_live_server
        _tool_result install npm live-server $? installed_count failed_count
        ;;
      localtunnel)
        install_localtunnel
        _tool_result install npm localtunnel $? installed_count failed_count
        ;;
      vercel)
        install_vercel
        _tool_result install npm vercel $? installed_count failed_count
        ;;
      wrangler)
        install_wrangler
        _tool_result install npm wrangler $? installed_count failed_count
        ;;
      firebase)
        install_firebase
        _tool_result install npm firebase $? installed_count failed_count
        ;;
      markserv)
        install_markserv
        _tool_result install npm markserv $? installed_count failed_count
        ;;
      psqlformat)
        install_psqlformat
        _tool_result install npm psqlformat $? installed_count failed_count
        ;;
      ncu)
        install_ncu
        _tool_result install npm ncu $? installed_count failed_count
        ;;
      ngrok)
        install_ngrok
        _tool_result install npm ngrok $? installed_count failed_count
        ;;
      turbopack)
        install_turbopack
        _tool_result install npm turbopack $? installed_count failed_count
        ;;
      *)
        log_warn "Unknown node module: --$tool"
        ;;
      esac
    done

    echo
    if [[ $installed_count -gt 0 ]]; then
      log_success "$installed_count Node.js module(s) installed"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count module(s) failed to install"
    fi
    echo
    ;;
  lang)
    import "@/tools/lang/all"
    local installed_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      nodejs)
        install_npmjs
        _tool_result install lang nodejs $? installed_count failed_count
        ;;
      python)
        install_python
        _tool_result install lang python $? installed_count failed_count
        ;;
      perl)
        install_perl
        _tool_result install lang perl $? installed_count failed_count
        ;;
      php)
        install_php
        _tool_result install lang php $? installed_count failed_count
        ;;
      rust)
        install_rust
        _tool_result install lang rust $? installed_count failed_count
        ;;
      clang)
        install_clang
        _tool_result install lang clang $? installed_count failed_count
        ;;
      golang)
        install_golang
        _tool_result install lang golang $? installed_count failed_count
        ;;
      bun)
        install_bun
        _tool_result install lang bun $? installed_count failed_count
        ;;
      *)
        log_warn "Unknown language: --$tool"
        ;;
      esac
    done

    echo
    if [[ $installed_count -gt 0 ]]; then
      log_success "$installed_count language(s) installed"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count language(s) failed to install"
    fi
    echo
    ;;
  shell)
    import "@/tools/shell/all"
    local installed_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      powerlevel10k)
        install_powerlevel10k
        _tool_result install shell powerlevel10k $? installed_count failed_count
        ;;
      zsh-defer)
        install_zsh_defer
        _tool_result install shell zsh-defer $? installed_count failed_count
        ;;
      zsh-autosuggestions)
        install_zsh_autosuggestions
        _tool_result install shell zsh-autosuggestions $? installed_count failed_count
        ;;
      zsh-syntax-highlighting)
        install_zsh_syntax_highlighting
        _tool_result install shell zsh-syntax-highlighting $? installed_count failed_count
        ;;
      history-substring)
        install_history_substring
        _tool_result install shell history-substring $? installed_count failed_count
        ;;
      zsh-completions)
        install_zsh_completions
        _tool_result install shell zsh-completions $? installed_count failed_count
        ;;
      fzf-tab)
        install_fzf_tab
        _tool_result install shell fzf-tab $? installed_count failed_count
        ;;
      you-should-use)
        install_you_should_use
        _tool_result install shell you-should-use $? installed_count failed_count
        ;;
      zsh-autopair)
        install_zsh_autopair
        _tool_result install shell zsh-autopair $? installed_count failed_count
        ;;
      better-npm)
        install_better_npm
        _tool_result install shell better-npm $? installed_count failed_count
        ;;
      *)
        log_warn "Unknown plugin: --$tool"
        ;;
      esac
    done

    echo
    if [[ $installed_count -gt 0 ]]; then
      log_success "$installed_count plugin(s) installed"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count plugin(s) failed to install"
    fi
    echo
    ;;
  editor)
    import "@/tools/editor/all"
    local installed_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      neovim)
        install_neovim
        _tool_result install editor neovim $? installed_count failed_count
        ;;
      nvchad)
        install_nvchad
        _tool_result install editor nvchad $? installed_count failed_count
        ;;
      *)
        log_warn "Unknown editor component: --$tool"
        ;;
      esac
    done

    echo
    if [[ $installed_count -gt 0 ]]; then
      log_success "$installed_count editor component(s) installed"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count component(s) failed to install"
    fi
    echo
    ;;
  ui)
    import "@/tools/ui/all"
    local installed_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      font)
        install_font
        _tool_result install ui font $? installed_count failed_count
        ;;
      extra-keys)
        install_extra_keys
        _tool_result install ui extra-keys $? installed_count failed_count
        ;;
      cursor)
        install_cursor
        _tool_result install ui cursor $? installed_count failed_count
        ;;
      banner)
        install_banner
        _tool_result install ui banner $? installed_count failed_count
        ;;
      *)
        log_warn "Unknown UI component: --$tool"
        ;;
      esac
    done

    echo
    if [[ $installed_count -gt 0 ]]; then
      log_success "$installed_count UI component(s) installed"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count component(s) failed to install"
    fi
    echo
    ;;
  auto)
    import "@/tools/auto/all"
    local installed_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      n8n)
        install_n8n
        _tool_result install auto n8n $? installed_count failed_count
        ;;
      *)
        log_warn "Unknown automation tool: --$tool"
        ;;
      esac
    done

    echo
    if [[ $installed_count -gt 0 ]]; then
      log_success "$installed_count automation tool(s) installed"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count tool(s) failed to install"
    fi
    echo
    ;;
  *)
    log_warn "Unknown install target: $module"
    echo "Run 'jax install' to see available targets"
    ;;
  esac
}
