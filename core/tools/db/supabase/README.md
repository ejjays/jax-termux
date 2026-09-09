# Supabase CLI

Develop locally and manage Supabase projects from your terminal.

**Package:** supabase
**Author:** ejjays
**Repository:** https://github.com/DevCoreXOfficial/core-termux
**Official:** https://supabase.com/docs/guides/local-development/cli/getting-started
**Type:** Database CLI (Binary + glibc bootstrapper)
**License:** MIT

## Description

The Supabase CLI brings the Supabase platform to your terminal: manage database migrations, deploy Edge Functions, generate types, and automate project workflows. The upstream project ships no Android build, so Core-Termux downloads the official `linux-arm64` release and runs it through the glibc loader (same approach as the Qoder installer).

## Dependencies

- glibc-repo, glibc, clang, curl, tar (installed automatically)

## Install

```bash
core install db --supabase
```

## Uninstall

```bash
core uninstall db --supabase
```

## Update

```bash
core update db --supabase
```

## Usage

```bash
supabase --version        # CLI version
supabase init             # Initialize a local project (works)
supabase link             # Link to a hosted project (works)
supabase db push          # Push migrations to hosted project (works)
supabase gen types        # Generate TypeScript types (works)
```

## Notes

- `supabase start` requires Docker/Podman, which is not available in Termux — local stacked development (`start`, `stop`, `status`) is **not supported**. Use a linked hosted project instead.
- The `npm i supabase` method does **not** work in Termux (`Unsupported platform: android`) — use this installer.
- Binary stored in `~/.local/share/core-termux-data/supabase/`, accessible as `supabase`.
- A small C bootstrapper (`helper/supabase_helper.c`) runs the binary via the glibc dynamic linker.
- Your project `supabase/` directories are never touched by install/update/uninstall.
