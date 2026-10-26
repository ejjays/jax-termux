# OpenCode V2

Open-source AI coding agent (v2 line) that runs in your terminal, desktop, or web app

**Package:** opencode2  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core-termux  
**Official:** https://github.com/anomalyco/opencode  
**Type:** AI coding agent (Binary + glibc bootstrapper)  
**License:** MIT

## Description

OpenCode V2 is the next generation of the anomalyco coding agent. It runs as TUI, desktop, or web clients against one shared background server that owns sessions and tools. Core-Termux installs it side-by-side with V1 as `opencode2`, so both lines can coexist.

## Dependencies

- **Native mode:** glibc-repo, glibc, git, ripgrep, jq, nodejs-lts, curl, tar
- **Native + proot mode:** proot
- **Proot mode:** proot-distro, curl, ca-certificates

## Install

```bash
jax install ai --opencode-v2
```

You will be prompted to choose:

1. **Native + proot (recommended)** — Runs the V2 build under proot so the background server it spawns also finds the glibc loader; also bypasses "bad system call" errors on some Android kernels
2. **Native** — Downloads the latest V2 `linux-arm64` build from the npm registry and runs it through the glibc loader, but the background server it spawns cannot start (no `/lib` on Android)
3. **Proot-distro (alternative)** — Runs OpenCode V2 inside an Ubuntu proot-distro container

## Uninstall

```bash
jax uninstall ai --opencode-v2
```

## Update

```bash
jax update ai --opencode-v2
```

## Notes

- The V2 binary is stored in `~/.local/share/core-termux-data/opencode-v2/`
- A small shell wrapper (`opencode2.native`) runs it via the glibc dynamic linker
- V1 (`opencode`) and V2 (`opencode2`) share `~/.config/opencode`, so uninstalling V2 keeps configs
- **Proot mode** downloads the V2 build inside an Ubuntu proot-distro container
- Data directory: `~/.local/share/core-termux-data/opencode-v2/`
