#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"
import "@/utils/telemetry"

reinstall_main() {

  if [[ $# -eq 0 ]]; then
    echo
    box "Jax Reinstall"
    echo
    log_info "Usage: jax reinstall <target>"
    log_info "Usage: jax reinstall <target> --tool1 --tool2"
    echo
    log_info "Available targets:"
    echo
    list_item "lang       - Reinstall language packages"
    list_item "db         - Reinstall databases"
    list_item "ai         - Reinstall AI tools"
    list_item "editor     - Reinstall code editor"
    list_item "dev        - Reinstall development tools"
    list_item "npm        - Reinstall Node.js global modules"
    list_item "shell      - Reinstall ZSH + Oh My Zsh"
    list_item "ui         - Reinstall Termux UI"
    list_item "auto       - Reinstall automation tools"
    echo
    log_info "Reinstall specific tools with flags:"
    echo
    list_item "jax reinstall ai --qwen-code --ollama"
    list_item "jax reinstall db --postgresql --sqlite"
    list_item "Run ${D_CYAN}jax list <target>${D_NC} to see all available tools"
    echo
    log_warn "This will uninstall and then install the selected components!"
    echo
    return
  fi

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

  if [[ -z "$module_target" ]]; then
    log_error "No target specified"
    echo "Run 'jax reinstall' to see available targets"
    return 1
  fi

  if [[ ${#tool_flags[@]} -eq 0 ]]; then
    _reinstall_full_module "$module_target"
  else
    _reinstall_specific_tools "$module_target" "${tool_flags[@]}"
  fi
}

_reinstall_full_module() {
  local target="$1"

  case "$target" in
  lang)
    import "@/modules/lang"
    reinstall_lang
    ;;
  db)
    import "@/modules/db"
    reinstall_db
    ;;
  ai)
    import "@/modules/ai"
    reinstall_ai
    ;;
  editor)
    import "@/modules/editor"
    reinstall_editor
    ;;
  dev)
    import "@/modules/dev"
    reinstall_dev
    ;;
  npm)
    import "@/modules/npm"
    reinstall_npm
    ;;
  shell)
    import "@/modules/shell"
    reinstall_shell
    ;;
  ui)
    import "@/modules/ui"
    reinstall_ui
    ;;
  auto)
    import "@/modules/auto"
    reinstall_auto
    ;;
  *)
    log_warn "Unknown reinstall target: $target"
    echo "Run 'jax reinstall' to see available targets"
    ;;
  esac
}

_reinstall_specific_tools() {
  local module="$1"
  shift
  local -a tools=("$@")

  case "$module" in
  ai)
    import "@/tools/ai/all"
    local reinstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      qwen-code)
        reinstall_qwen_code
        _tool_result reinstall ai qwen-code $? reinstalled_count failed_count
        ;;
      gemini-cli)
        reinstall_gemini_cli
        _tool_result reinstall ai gemini-cli $? reinstalled_count failed_count
        ;;
      claude-code)
        reinstall_claude_code
        _tool_result reinstall ai claude-code $? reinstalled_count failed_count
        ;;
      mistral-vibe)
        reinstall_mistral_vibe
        _tool_result reinstall ai mistral-vibe $? reinstalled_count failed_count
        ;;
      openclaude)
        reinstall_openclaude
        _tool_result reinstall ai openclaude $? reinstalled_count failed_count
        ;;
      openclaw)
        reinstall_openclaw
        _tool_result reinstall ai openclaw $? reinstalled_count failed_count
        ;;
      ollama)
        reinstall_ollama
        _tool_result reinstall ai ollama $? reinstalled_count failed_count
        ;;
      codex)
        reinstall_codex
        _tool_result reinstall ai codex $? reinstalled_count failed_count
        ;;
      opencode)
        reinstall_opencode
        _tool_result reinstall ai opencode $? reinstalled_count failed_count
        ;;
      qoder)
        reinstall_qoder
        _tool_result reinstall ai qoder $? reinstalled_count failed_count
        ;;
      kilocode-cli)
        reinstall_kilocode_cli
        _tool_result reinstall ai kilocode-cli $? reinstalled_count failed_count
        ;;
      cactus-needle)
        reinstall_cactus_needle
        _tool_result reinstall ai cactus-needle $? reinstalled_count failed_count
        ;;
      cactus)
        reinstall_cactus_cli
        _tool_result reinstall ai cactus $? reinstalled_count failed_count
        ;;
      keelcode)
        reinstall_keelcode
        _tool_result reinstall ai keelcode $? reinstalled_count failed_count
        ;;
      cursor-cli)
        reinstall_cursor_cli
        _tool_result reinstall ai cursor-cli $? reinstalled_count failed_count
        ;;
      kimchi)
        reinstall_kimchi
        _tool_result reinstall ai kimchi $? reinstalled_count failed_count
        ;;
      mimocode)
        reinstall_mimocode
        _tool_result reinstall ai mimocode $? reinstalled_count failed_count
        ;;
      engram)
        reinstall_engram
        _tool_result reinstall ai engram $? reinstalled_count failed_count
        ;;
      codegraph)
        reinstall_codegraph
        _tool_result reinstall ai codegraph $? reinstalled_count failed_count
        ;;
      pi)
        reinstall_pi
        _tool_result reinstall ai pi $? reinstalled_count failed_count
        ;;
      oh-my-pi)
        reinstall_oh_my_pi
        _tool_result reinstall ai oh-my-pi $? reinstalled_count failed_count
        ;;
      antigravity-cli)
        reinstall_antigravity_cli
        _tool_result reinstall ai antigravity-cli $? reinstalled_count failed_count
        ;;
      minimax-cli)
        reinstall_minimax_cli
        _tool_result reinstall ai minimax-cli $? reinstalled_count failed_count
        ;;
      gentle-ai)
        reinstall_gentle_ai
        _tool_result reinstall ai gentle-ai $? reinstalled_count failed_count
        ;;
      gga)
        reinstall_gga
        _tool_result reinstall ai gga $? reinstalled_count failed_count
        ;;
      hermes-agent)
        reinstall_hermes_agent
        _tool_result reinstall ai hermes-agent $? reinstalled_count failed_count
        ;;
      kimi-code)
        reinstall_kimi_code
        _tool_result reinstall ai kimi-code $? reinstalled_count failed_count
        ;;
      command-code)
        reinstall_command_code
        _tool_result reinstall ai command-code $? reinstalled_count failed_count
        ;;
      freebuff)
        reinstall_freebuff
        _tool_result reinstall ai freebuff $? reinstalled_count failed_count
        ;;
      ctx7)
        reinstall_ctx7
        _tool_result reinstall ai ctx7 $? reinstalled_count failed_count
        ;;
      openspec)
        reinstall_openspec
        _tool_result reinstall ai openspec $? reinstalled_count failed_count
        ;;
      supercode)
        reinstall_supercode
        _tool_result reinstall ai supercode $? reinstalled_count failed_count
        ;;
      cline)
        reinstall_cline
        _tool_result reinstall ai cline $? reinstalled_count failed_count
        ;;
      ampcode)
        reinstall_amp_code_cli
        _tool_result reinstall ai ampcode $? reinstalled_count failed_count
        ;;
      droid-factory)
        reinstall_droid_factory
        _tool_result reinstall ai droid-factory $? reinstalled_count failed_count
        ;;
      hugging-face)
        reinstall_hugging_face
        _tool_result reinstall ai hugging-face $? reinstalled_count failed_count
        ;;
      goose)
        reinstall_goose
        _tool_result reinstall ai goose $? reinstalled_count failed_count
        ;;
      walkie)
        reinstall_walkie
        _tool_result reinstall ai walkie $? reinstalled_count failed_count
        ;;
      *)
        log_warn "Unknown AI tool: --$tool"
        ;;
      esac
    done

    echo
    if [[ $reinstalled_count -gt 0 ]]; then
      log_success "$reinstalled_count AI tool(s) reinstalled"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count tool(s) failed to reinstall"
    fi
    echo
    ;;
  db)
    import "@/tools/db/all"
    local reinstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      postgresql)
        reinstall_postgresql
        _tool_result reinstall db postgresql $? reinstalled_count failed_count
        ;;
      mariadb)
        reinstall_mariadb
        _tool_result reinstall db mariadb $? reinstalled_count failed_count
        ;;
      sqlite)
        reinstall_sqlite
        _tool_result reinstall db sqlite $? reinstalled_count failed_count
        ;;
      mongodb)
        reinstall_mongodb
        _tool_result reinstall db mongodb $? reinstalled_count failed_count
        ;;
      redis)
        reinstall_redis
        _tool_result reinstall db redis $? reinstalled_count failed_count
        ;;
      supabase)
        reinstall_supabase
        _tool_result reinstall db supabase $? reinstalled_count failed_count
        ;;
      *)
        log_warn "Unknown database: --$tool"
        ;;
      esac
    done

    echo
    if [[ $reinstalled_count -gt 0 ]]; then
      log_success "$reinstalled_count database(s) reinstalled"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count database(s) failed to reinstall"
    fi
    echo
    ;;
  dev)
    import "@/tools/dev/all"
    local reinstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      gh)
        reinstall_gh
        _tool_result reinstall dev gh $? reinstalled_count failed_count
        ;;
      wget)
        reinstall_wget
        _tool_result reinstall dev wget $? reinstalled_count failed_count
        ;;
      curl)
        reinstall_curl
        _tool_result reinstall dev curl $? reinstalled_count failed_count
        ;;
      lsd)
        reinstall_lsd
        _tool_result reinstall dev lsd $? reinstalled_count failed_count
        ;;
      bat)
        reinstall_bat
        _tool_result reinstall dev bat $? reinstalled_count failed_count
        ;;
      proot)
        reinstall_proot
        _tool_result reinstall dev proot $? reinstalled_count failed_count
        ;;
      ncurses)
        reinstall_ncurses
        _tool_result reinstall dev ncurses $? reinstalled_count failed_count
        ;;
      tmate)
        reinstall_tmate
        _tool_result reinstall dev tmate $? reinstalled_count failed_count
        ;;
      tmux)
        reinstall_tmux
        _tool_result reinstall dev tmux $? reinstalled_count failed_count
        ;;
      openssh)
        reinstall_openssh
        _tool_result reinstall dev openssh $? reinstalled_count failed_count
        ;;
      cloudflared)
        reinstall_cloudflared
        _tool_result reinstall dev cloudflared $? reinstalled_count failed_count
        ;;
      translate)
        reinstall_translate
        _tool_result reinstall dev translate $? reinstalled_count failed_count
        ;;
      html2text)
        reinstall_html2text
        _tool_result reinstall dev html2text $? reinstalled_count failed_count
        ;;
      jq)
        reinstall_jq
        _tool_result reinstall dev jq $? reinstalled_count failed_count
        ;;
      bc)
        reinstall_bc
        _tool_result reinstall dev bc $? reinstalled_count failed_count
        ;;
      tree)
        reinstall_tree
        _tool_result reinstall dev tree $? reinstalled_count failed_count
        ;;
      fzf)
        reinstall_fzf
        _tool_result reinstall dev fzf $? reinstalled_count failed_count
        ;;
      imagemagick)
        reinstall_imagemagick
        _tool_result reinstall dev imagemagick $? reinstalled_count failed_count
        ;;
      shfmt)
        reinstall_shfmt
        _tool_result reinstall dev shfmt $? reinstalled_count failed_count
        ;;
      make)
        reinstall_make
        _tool_result reinstall dev make $? reinstalled_count failed_count
        ;;
      udocker)
        reinstall_udocker
        _tool_result reinstall dev udocker $? reinstalled_count failed_count
        ;;
      superfile)
        reinstall_superfile
        _tool_result reinstall dev superfile $? reinstalled_count failed_count
        ;;
      gcloud)
        reinstall_gcloud
        _tool_result reinstall dev gcloud $? reinstalled_count failed_count
        ;;
      *)
        log_warn "Unknown tool: --$tool"
        ;;
      esac
    done

    echo
    if [[ $reinstalled_count -gt 0 ]]; then
      log_success "$reinstalled_count tool(s) reinstalled"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count tool(s) failed to reinstall"
    fi
    echo
    ;;
  npm)
    import "@/tools/npm/all"
    local reinstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      typescript)
        reinstall_typescript
        _tool_result reinstall npm typescript $? reinstalled_count failed_count
        ;;
      nestjs)
        reinstall_nestjs
        _tool_result reinstall npm nestjs $? reinstalled_count failed_count
        ;;
      prettier)
        reinstall_prettier
        _tool_result reinstall npm prettier $? reinstalled_count failed_count
        ;;
      live-server)
        reinstall_live_server
        _tool_result reinstall npm live-server $? reinstalled_count failed_count
        ;;
      localtunnel)
        reinstall_localtunnel
        _tool_result reinstall npm localtunnel $? reinstalled_count failed_count
        ;;
      vercel)
        reinstall_vercel
        _tool_result reinstall npm vercel $? reinstalled_count failed_count
        ;;
      wrangler)
        reinstall_wrangler
        _tool_result reinstall npm wrangler $? reinstalled_count failed_count
        ;;
      firebase)
        reinstall_firebase
        _tool_result reinstall npm firebase $? reinstalled_count failed_count
        ;;
      markserv)
        reinstall_markserv
        _tool_result reinstall npm markserv $? reinstalled_count failed_count
        ;;
      psqlformat)
        reinstall_psqlformat
        _tool_result reinstall npm psqlformat $? reinstalled_count failed_count
        ;;
      ncu)
        reinstall_ncu
        _tool_result reinstall npm ncu $? reinstalled_count failed_count
        ;;
      ngrok)
        reinstall_ngrok
        _tool_result reinstall npm ngrok $? reinstalled_count failed_count
        ;;
      turbopack)
        reinstall_turbopack
        _tool_result reinstall npm turbopack $? reinstalled_count failed_count
        ;;
      *)
        log_warn "Unknown node module: --$tool"
        ;;
      esac
    done

    echo
    if [[ $reinstalled_count -gt 0 ]]; then
      log_success "$reinstalled_count Node.js module(s) reinstalled"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count module(s) failed to reinstall"
    fi
    echo
    ;;
  lang)
    import "@/tools/lang/all"
    local reinstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      nodejs)
        reinstall_npmjs
        _tool_result reinstall lang nodejs $? reinstalled_count failed_count
        ;;
      python)
        reinstall_python
        _tool_result reinstall lang python $? reinstalled_count failed_count
        ;;
      perl)
        reinstall_perl
        _tool_result reinstall lang perl $? reinstalled_count failed_count
        ;;
      php)
        reinstall_php
        _tool_result reinstall lang php $? reinstalled_count failed_count
        ;;
      rust)
        reinstall_rust
        _tool_result reinstall lang rust $? reinstalled_count failed_count
        ;;
      clang)
        reinstall_clang
        _tool_result reinstall lang clang $? reinstalled_count failed_count
        ;;
      golang)
        reinstall_golang
        _tool_result reinstall lang golang $? reinstalled_count failed_count
        ;;
      bun)
        reinstall_bun
        _tool_result reinstall lang bun $? reinstalled_count failed_count
        ;;
      *)
        log_warn "Unknown language: --$tool"
        ;;
      esac
    done

    echo
    if [[ $reinstalled_count -gt 0 ]]; then
      log_success "$reinstalled_count language(s) reinstalled"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count language(s) failed to reinstall"
    fi
    echo
    ;;
  shell)
    import "@/tools/shell/all"
    local reinstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      powerlevel10k)
        reinstall_powerlevel10k
        _tool_result reinstall shell powerlevel10k $? reinstalled_count failed_count
        ;;
      zsh-defer)
        reinstall_zsh_defer
        _tool_result reinstall shell zsh-defer $? reinstalled_count failed_count
        ;;
      zsh-autosuggestions)
        reinstall_zsh_autosuggestions
        _tool_result reinstall shell zsh-autosuggestions $? reinstalled_count failed_count
        ;;
      zsh-syntax-highlighting)
        reinstall_zsh_syntax_highlighting
        _tool_result reinstall shell zsh-syntax-highlighting $? reinstalled_count failed_count
        ;;
      history-substring)
        reinstall_history_substring
        _tool_result reinstall shell history-substring $? reinstalled_count failed_count
        ;;
      zsh-completions)
        reinstall_zsh_completions
        _tool_result reinstall shell zsh-completions $? reinstalled_count failed_count
        ;;
      fzf-tab)
        reinstall_fzf_tab
        _tool_result reinstall shell fzf-tab $? reinstalled_count failed_count
        ;;
      you-should-use)
        reinstall_you_should_use
        _tool_result reinstall shell you-should-use $? reinstalled_count failed_count
        ;;
      zsh-autopair)
        reinstall_zsh_autopair
        _tool_result reinstall shell zsh-autopair $? reinstalled_count failed_count
        ;;
      better-npm)
        reinstall_better_npm
        _tool_result reinstall shell better-npm $? reinstalled_count failed_count
        ;;
      *)
        log_warn "Unknown plugin: --$tool"
        ;;
      esac
    done

    echo
    if [[ $reinstalled_count -gt 0 ]]; then
      log_success "$reinstalled_count plugin(s) reinstalled"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count plugin(s) failed to reinstall"
    fi
    echo
    ;;
  editor)
    import "@/tools/editor/all"
    local reinstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      neovim)
        reinstall_neovim
        _tool_result reinstall editor neovim $? reinstalled_count failed_count
        ;;
      nvchad)
        reinstall_nvchad
        _tool_result reinstall editor nvchad $? reinstalled_count failed_count
        ;;
      *)
        log_warn "Unknown editor component: --$tool"
        ;;
      esac
    done

    echo
    if [[ $reinstalled_count -gt 0 ]]; then
      log_success "$reinstalled_count editor component(s) reinstalled"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count component(s) failed to reinstall"
    fi
    echo
    ;;
  ui)
    import "@/tools/ui/all"
    local reinstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      font)
        reinstall_font
        _tool_result reinstall ui font $? reinstalled_count failed_count
        ;;
      extra-keys)
        reinstall_extra_keys
        _tool_result reinstall ui extra-keys $? reinstalled_count failed_count
        ;;
      cursor)
        reinstall_cursor
        _tool_result reinstall ui cursor $? reinstalled_count failed_count
        ;;
      banner)
        reinstall_banner
        _tool_result reinstall ui banner $? reinstalled_count failed_count
        ;;
      *)
        log_warn "Unknown UI component: --$tool"
        ;;
      esac
    done

    echo
    if [[ $reinstalled_count -gt 0 ]]; then
      log_success "$reinstalled_count UI component(s) reinstalled"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count component(s) failed to reinstall"
    fi
    echo
    ;;
  auto)
    import "@/tools/auto/all"
    local reinstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      n8n)
        reinstall_n8n
        _tool_result reinstall auto n8n $? reinstalled_count failed_count
        ;;
      *)
        log_warn "Unknown automation tool: --$tool"
        ;;
      esac
    done

    echo
    if [[ $reinstalled_count -gt 0 ]]; then
      log_success "$reinstalled_count automation tool(s) reinstalled"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count tool(s) failed to reinstall"
    fi
    echo
    ;;
  *)
    log_warn "Unknown reinstall target: $module"
    echo "Run 'jax reinstall' to see available targets"
    ;;
  esac
}
