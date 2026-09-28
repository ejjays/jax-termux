# Wrangler CLI

Deploy static sites and Workers to Cloudflare's global edge network

**Package:** wrangler  
**Author:** ejjays  
**Repository:** https://github.com/ejjays/jax-termux  
**Official:** https://developers.cloudflare.com/workers/wrangler/  
**Type:** Node.js global module (npm)  
**License:** MIT

## Description

Wrangler CLI deploys static sites (Workers Static Assets) and Workers to Cloudflare's edge network in 300+ cities. Free tier includes unlimited bandwidth for static assets, which makes it a good fit for landing pages and docs built on Termux.

## Dependencies

- Node.js LTS (nodejs-lts)

## Install

```bash
jax install npm --wrangler
```

## Uninstall

```bash
jax uninstall npm --wrangler
```

## Update

```bash
jax update npm --wrangler
```

## Notes

- Command: `wrangler`
- Headless auth on Termux: `wrangler login` needs a browser, so prefer an API token instead — create one at dash.cloudflare.com (Workers + Pages deploy template) and export `CLOUDFLARE_API_TOKEN`
- Local `wrangler dev` emulation needs the workerd runtime, which is glibc-linked and may not start on Termux; `wrangler deploy` and `wrangler pages deploy` are unaffected
