# Cursor Color

Customize Termux terminal cursor color

**Package:** core-termux (cursor config)  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core-termux  
**Type:** Termux UI customization  
**License:** MIT

## Description

Configures the Termux terminal cursor color to a custom value (default: soft green #1CF289). This provides better cursor visibility and personalization of the Termux terminal appearance. Other settings in `colors.properties` are preserved.

## Dependencies

- Termux (base installation)

## Install

```bash
jax install ui --cursor
```

## Uninstall

```bash
jax uninstall ui --cursor
```

## Update

```bash
jax update ui --cursor
```

## Notes

- Config file: `~/.termux/colors.properties`
- Default cursor color: soft green (#1CF289)
- Preserves other color settings on install/uninstall
- Restart Termux to apply changes

