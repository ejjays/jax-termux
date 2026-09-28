#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"
import "@/utils/telemetry"

update_main() {

  if [[ $# -eq 0 ]]; then
    echo
    box "Jax Update"
    echo
    log_info "Usage: jax update <target>"
    log_info "Usage: jax update <target> --tool1 --tool2"
    echo
    log_info "Available targets:"
    echo
    list_item "jax       - Update only Core-Termux framework"
    list_item "lang       - Update language packages (pkg upgrade)"
    list_item "db         - Update databases"
    list_item "ai         - Update AI tools (npm/pip/pkg)"
    list_item "editor     - Update Neovim configuration"
    list_item "dev        - Update development tools"
    list_item "npm        - Update Node.js global modules"
    list_item "shell      - Update ZSH plugins"
    list_item "ui         - Update Termux UI"
    list_item "auto       - Update Automation Tools"
    echo
    log_info "Update specific tools with flags:"
    echo
    list_item "jax update ai --qwen-code --ollama"
    list_item "jax update db --postgresql --sqlite"
    list_item "Run ${D_CYAN}jax list <target>${D_NC} to see all available tools"
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
    echo "Run 'jax update' to see available targets"
    return 1
  fi

  # If no tool flags, update entire module (original behavior)
  if [[ ${#tool_flags[@]} -eq 0 ]]; then
    _update_full_module "$module_target"
  else
    # Update specific tools
    _update_specific_tools "$module_target" "${tool_flags[@]}"
  fi
}

# Update entire module (original behavior)
_update_full_module() {
  local target="$1"

  case "$target" in
  jax)
    update_core
    ;;
  lang)
    import "@/modules/lang"
    update_lang
    ;;
  db)
    import "@/modules/db"
    update_db
    ;;
  ai)
    import "@/modules/ai"
    update_ai
    ;;
  editor)
    import "@/modules/editor"
    update_editor
    ;;
  dev)
    import "@/modules/dev"
    update_dev
    ;;
  npm)
    import "@/modules/npm"
    update_npm
    ;;
  shell)
    import "@/modules/shell"
    update_shell
    ;;
  ui)
    import "@/modules/ui"
    update_ui
    ;;
  auto)
    import "@/modules/auto"
    update_auto
    ;;
  *)
    log_warn "Unknown update target: $target"
    echo "Run 'jax update' to see available targets"
    ;;
  esac
}

# Update specific tools within a module
_update_specific_tools() {
  local module="$1"
  shift
  local -a tools=("$@")

  case "$module" in
  ai)
    import "@/tools/ai/all"
    local updated_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      qwen-code)
        update_qwen_code
        _tool_result update ai qwen-code $? updated_count failed_count
        ;;
      gemini-cli)
        update_gemini_cli
        _tool_result update ai gemini-cli $? updated_count failed_count
        ;;
      claude-code)
        update_claude_code
        _tool_result update ai claude-code $? updated_count failed_count
        ;;
      mistral-vibe)
        update_mistral_vibe
        _tool_result update ai mistral-vibe $? updated_count failed_count
        ;;
      openclaude)
        update_openclaude
        _tool_result update ai openclaude $? updated_count failed_count
        ;;
      openclaw)
        update_openclaw
        _tool_result update ai openclaw $? updated_count failed_count
        ;;
      ollama)
        update_ollama
        _tool_result update ai ollama $? updated_count failed_count
        ;;
      codex)
        update_codex
        _tool_result update ai codex $? updated_count failed_count
        ;;
      opencode)
        update_opencode
        _tool_result update ai opencode $? updated_count failed_count
        ;;
      qoder)
        update_qoder
        _tool_result update ai qoder $? updated_count failed_count
        ;;
      kilocode-cli)
        update_kilocode_cli
        _tool_result update ai kilocode-cli $? updated_count failed_count
        ;;
      cactus-needle)
        update_cactus_needle
        _tool_result update ai cactus-needle $? updated_count failed_count
        ;;
      cactus)
        update_cactus_cli
        _tool_result update ai cactus $? updated_count failed_count
        ;;
      keelcode)
        update_keelcode
        _tool_result update ai keelcode $? updated_count failed_count
        ;;
      cursor-cli)
        update_cursor_cli
        _tool_result update ai cursor-cli $? updated_count failed_count
        ;;
      kimchi)
        update_kimchi
        _tool_result update ai kimchi $? updated_count failed_count
        ;;
      mimocode)
        update_mimocode
        _tool_result update ai mimocode $? updated_count failed_count
        ;;
      engram)
        update_engram
        _tool_result update ai engram $? updated_count failed_count
        ;;
      codegraph)
        update_codegraph
        _tool_result update ai codegraph $? updated_count failed_count
        ;;
      pi)
        update_pi
        _tool_result update ai pi $? updated_count failed_count
        ;;
      oh-my-pi)
        update_oh_my_pi
        _tool_result update ai oh-my-pi $? updated_count failed_count
        ;;
      antigravity-cli)
        update_antigravity_cli
        _tool_result update ai antigravity-cli $? updated_count failed_count
        ;;
      minimax-cli)
        update_minimax_cli
        _tool_result update ai minimax-cli $? updated_count failed_count
        ;;
      gentle-ai)
        update_gentle_ai
        _tool_result update ai gentle-ai $? updated_count failed_count
        ;;
      gga)
        update_gga
        _tool_result update ai gga $? updated_count failed_count
        ;;
      hermes-agent)
        update_hermes_agent
        _tool_result update ai hermes-agent $? updated_count failed_count
        ;;
      kimi-code)
        update_kimi_code
        _tool_result update ai kimi-code $? updated_count failed_count
        ;;
      command-code)
        update_command_code
        _tool_result update ai command-code $? updated_count failed_count
        ;;
      freebuff)
        update_freebuff
        _tool_result update ai freebuff $? updated_count failed_count
        ;;
      ctx7)
        update_ctx7
        _tool_result update ai ctx7 $? updated_count failed_count
        ;;
      openspec)
        update_openspec
        _tool_result update ai openspec $? updated_count failed_count
        ;;
      supercode)
        update_supercode
        _tool_result update ai supercode $? updated_count failed_count
        ;;
      cline)
        update_cline
        _tool_result update ai cline $? updated_count failed_count
        ;;
      ampcode)
        update_amp_code_cli
        _tool_result update ai ampcode $? updated_count failed_count
        ;;
      droid-factory)
        update_droid_factory
        _tool_result update ai droid-factory $? updated_count failed_count
        ;;
      hugging-face)
        update_hugging_face
        _tool_result update ai hugging-face $? updated_count failed_count
        ;;
      goose)
        update_goose
        _tool_result update ai goose $? updated_count failed_count
        ;;
      walkie)
        update_walkie
        _tool_result update ai walkie $? updated_count failed_count
        ;;
      *)
        log_warn "Unknown AI tool: --$tool"
        ;;
      esac
    done

    echo
    if [[ $updated_count -gt 0 ]]; then
      log_success "$updated_count AI tool(s) updated"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count tool(s) failed to update"
    fi
    echo
    ;;
  db)
    import "@/tools/db/all"
    local updated_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      postgresql)
        update_postgresql
        _tool_result update db postgresql $? updated_count failed_count
        ;;
      mariadb)
        update_mariadb
        _tool_result update db mariadb $? updated_count failed_count
        ;;
      sqlite)
        update_sqlite
        _tool_result update db sqlite $? updated_count failed_count
        ;;
      mongodb)
        update_mongodb
        _tool_result update db mongodb $? updated_count failed_count
        ;;
      redis)
        update_redis
        _tool_result update db redis $? updated_count failed_count
        ;;
      supabase)
        update_supabase
        _tool_result update db supabase $? updated_count failed_count
        ;;
      *)
        log_warn "Unknown database: --$tool"
        ;;
      esac
    done

    echo
    if [[ $updated_count -gt 0 ]]; then
      log_success "$updated_count database(s) updated"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count database(s) failed to update"
    fi
    echo
    ;;
  dev)
    import "@/tools/dev/all"
    local updated_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      gh)
        update_gh
        _tool_result update dev gh $? updated_count failed_count
        ;;
      wget)
        update_wget
        _tool_result update dev wget $? updated_count failed_count
        ;;
      curl)
        update_curl
        _tool_result update dev curl $? updated_count failed_count
        ;;
      lsd)
        update_lsd
        _tool_result update dev lsd $? updated_count failed_count
        ;;
      bat)
        update_bat
        _tool_result update dev bat $? updated_count failed_count
        ;;
      proot)
        update_proot
        _tool_result update dev proot $? updated_count failed_count
        ;;
      ncurses)
        update_ncurses
        _tool_result update dev ncurses $? updated_count failed_count
        ;;
      tmate)
        update_tmate
        _tool_result update dev tmate $? updated_count failed_count
        ;;
      tmux)
        update_tmux
        _tool_result update dev tmux $? updated_count failed_count
        ;;
      openssh)
        update_openssh
        _tool_result update dev openssh $? updated_count failed_count
        ;;
      cloudflared)
        update_cloudflared
        _tool_result update dev cloudflared $? updated_count failed_count
        ;;
      translate)
        update_translate
        _tool_result update dev translate $? updated_count failed_count
        ;;
      html2text)
        update_html2text
        _tool_result update dev html2text $? updated_count failed_count
        ;;
      jq)
        update_jq
        _tool_result update dev jq $? updated_count failed_count
        ;;
      bc)
        update_bc
        _tool_result update dev bc $? updated_count failed_count
        ;;
      tree)
        update_tree
        _tool_result update dev tree $? updated_count failed_count
        ;;
      fzf)
        update_fzf
        _tool_result update dev fzf $? updated_count failed_count
        ;;
      imagemagick)
        update_imagemagick
        _tool_result update dev imagemagick $? updated_count failed_count
        ;;
      shfmt)
        update_shfmt
        _tool_result update dev shfmt $? updated_count failed_count
        ;;
      make)
        update_make
        _tool_result update dev make $? updated_count failed_count
        ;;
      udocker)
        update_udocker
        _tool_result update dev udocker $? updated_count failed_count
        ;;
      superfile)
        update_superfile
        _tool_result update dev superfile $? updated_count failed_count
        ;;
      gcloud)
        update_gcloud
        _tool_result update dev gcloud $? updated_count failed_count
        ;;
      *)
        log_warn "Unknown tool: --$tool"
        ;;
      esac
    done

    echo
    if [[ $updated_count -gt 0 ]]; then
      log_success "$updated_count tool(s) updated"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count tool(s) failed to update"
    fi
    echo
    ;;
  npm)
    import "@/tools/npm/all"
    local updated_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      typescript)
        update_typescript
        _tool_result update npm typescript $? updated_count failed_count
        ;;
      nestjs)
        update_nestjs
        _tool_result update npm nestjs $? updated_count failed_count
        ;;
      prettier)
        update_prettier
        _tool_result update npm prettier $? updated_count failed_count
        ;;
      live-server)
        update_live_server
        _tool_result update npm live-server $? updated_count failed_count
        ;;
      localtunnel)
        update_localtunnel
        _tool_result update npm localtunnel $? updated_count failed_count
        ;;
      vercel)
        update_vercel
        _tool_result update npm vercel $? updated_count failed_count
        ;;
      wrangler)
        update_wrangler
        _tool_result update npm wrangler $? updated_count failed_count
        ;;
      firebase)
        update_firebase
        _tool_result update npm firebase $? updated_count failed_count
        ;;
      markserv)
        update_markserv
        _tool_result update npm markserv $? updated_count failed_count
        ;;
      psqlformat)
        update_psqlformat
        _tool_result update npm psqlformat $? updated_count failed_count
        ;;
      ncu)
        update_ncu
        _tool_result update npm ncu $? updated_count failed_count
        ;;
      ngrok)
        update_ngrok
        _tool_result update npm ngrok $? updated_count failed_count
        ;;
      turbopack)
        update_turbopack
        _tool_result update npm turbopack $? updated_count failed_count
        ;;
      *)
        log_warn "Unknown node module: --$tool"
        ;;
      esac
    done

    echo
    if [[ $updated_count -gt 0 ]]; then
      log_success "$updated_count Node.js module(s) updated"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count module(s) failed to update"
    fi
    echo
    ;;
  lang)
    import "@/tools/lang/all"
    local updated_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      nodejs)
        update_npmjs
        _tool_result update lang nodejs $? updated_count failed_count
        ;;
      python)
        update_python
        _tool_result update lang python $? updated_count failed_count
        ;;
      perl)
        update_perl
        _tool_result update lang perl $? updated_count failed_count
        ;;
      php)
        update_php
        _tool_result update lang php $? updated_count failed_count
        ;;
      rust)
        update_rust
        _tool_result update lang rust $? updated_count failed_count
        ;;
      clang)
        update_clang
        _tool_result update lang clang $? updated_count failed_count
        ;;
      golang)
        update_golang
        _tool_result update lang golang $? updated_count failed_count
        ;;
      bun)
        update_bun
        _tool_result update lang bun $? updated_count failed_count
        ;;
      *)
        log_warn "Unknown language: --$tool"
        ;;
      esac
    done

    echo
    if [[ $updated_count -gt 0 ]]; then
      log_success "$updated_count language(s) updated"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count language(s) failed to update"
    fi
    echo
    ;;
  shell)
    import "@/tools/shell/all"
    local updated_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      powerlevel10k)
        update_powerlevel10k
        _tool_result update shell powerlevel10k $? updated_count failed_count
        ;;
      zsh-defer)
        update_zsh_defer
        _tool_result update shell zsh-defer $? updated_count failed_count
        ;;
      zsh-autosuggestions)
        update_zsh_autosuggestions
        _tool_result update shell zsh-autosuggestions $? updated_count failed_count
        ;;
      zsh-syntax-highlighting)
        update_zsh_syntax_highlighting
        _tool_result update shell zsh-syntax-highlighting $? updated_count failed_count
        ;;
      history-substring)
        update_history_substring
        _tool_result update shell history-substring $? updated_count failed_count
        ;;
      zsh-completions)
        update_zsh_completions
        _tool_result update shell zsh-completions $? updated_count failed_count
        ;;
      fzf-tab)
        update_fzf_tab
        _tool_result update shell fzf-tab $? updated_count failed_count
        ;;
      you-should-use)
        update_you_should_use
        _tool_result update shell you-should-use $? updated_count failed_count
        ;;
      zsh-autopair)
        update_zsh_autopair
        _tool_result update shell zsh-autopair $? updated_count failed_count
        ;;
      better-npm)
        update_better_npm
        _tool_result update shell better-npm $? updated_count failed_count
        ;;
      *)
        log_warn "Unknown plugin: --$tool"
        ;;
      esac
    done

    echo
    if [[ $updated_count -gt 0 ]]; then
      log_success "$updated_count plugin(s) updated"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count plugin(s) failed to update"
    fi
    echo
    ;;
  editor)
    import "@/tools/editor/all"
    local updated_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      neovim)
        update_neovim
        _tool_result update editor neovim $? updated_count failed_count
        ;;
      nvchad)
        update_nvchad
        _tool_result update editor nvchad $? updated_count failed_count
        ;;
      *)
        log_warn "Unknown editor component: --$tool"
        ;;
      esac
    done

    echo
    if [[ $updated_count -gt 0 ]]; then
      log_success "$updated_count editor component(s) updated"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count component(s) failed to update"
    fi
    echo
    ;;
  ui)
    import "@/tools/ui/all"
    local updated_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      font)
        update_font
        _tool_result update ui font $? updated_count failed_count
        ;;
      extra-keys)
        update_extra_keys
        _tool_result update ui extra-keys $? updated_count failed_count
        ;;
      cursor)
        update_cursor
        _tool_result update ui cursor $? updated_count failed_count
        ;;
      banner)
        update_banner
        _tool_result update ui banner $? updated_count failed_count
        ;;
      *)
        log_warn "Unknown UI component: --$tool"
        ;;
      esac
    done

    echo
    if [[ $updated_count -gt 0 ]]; then
      log_success "$updated_count UI component(s) updated"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count component(s) failed to update"
    fi
    echo
    ;;
  auto)
    import "@/tools/auto/all"
    local updated_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      n8n)
        update_n8n
        _tool_result update auto n8n $? updated_count failed_count
        ;;
      *)
        log_warn "Unknown automation tool: --$tool"
        ;;
      esac
    done

    echo
    if [[ $updated_count -gt 0 ]]; then
      log_success "$updated_count automation tool(s) updated"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count tool(s) failed to update"
    fi
    echo
    ;;
  *)
    log_warn "Unknown update target: $module"
    echo "Run 'jax update' to see available targets"
    ;;
  esac
}

# Actualizar Core-Termux
update_core() {
  separator
  box "◈ UPDATING JAX ◈"
  separator
  echo

  if [[ -d "$CORE_PATH/../.git" ]]; then
    loading "Updating Core-Termux" _update_core_repo
    local rc=$?

    echo
    if [[ $rc -eq 0 ]]; then
      log_success "Core-Termux updated"
    elif [[ $rc -eq 2 ]]; then
      log_success "Core-Termux is already up to date"
    else
      log_error "Failed to update Core-Termux"
      log_info "Check your internet connection or run git pull manually"
    fi

    rm -f "$CORE_CACHE/new_version" "$CORE_CACHE/last_version_check"
  else
    log_warn "Not a git repository, cannot update"
    log_info "If you installed via curl, reinstall with:"
    echo "  curl -fsSL https://raw.githubusercontent.com/ejjays/jax-termux/main/install.sh | bash"
  fi

  echo
}

_update_core_repo() {
  local repo_dir="$CORE_PATH/.."
  local old_head

  old_head=$(git -C "$repo_dir" rev-parse HEAD 2>/dev/null)

  if ! git -C "$repo_dir" pull --ff-only &>/dev/null; then
    return 1
  fi

  if [[ "$(git -C "$repo_dir" rev-parse HEAD 2>/dev/null)" == "$old_head" ]]; then
    return 2
  fi

  git -C "$repo_dir" log --oneline --no-decorate "$old_head..HEAD" 2>/dev/null | while IFS= read -r line; do
    printf "    ${CYAN}▸${NC} %s\n" "$line"
  done

  return 0
}
