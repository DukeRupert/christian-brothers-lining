# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Hugo static site with optional Go API backend, deployed to VPS via Docker and GitHub Actions. See ARCHITECTURE.md for the complete deployment architecture reference.

## Build Commands

```bash
# Hugo development server
hugo server

# Build Hugo site for production
hugo --gc --minify

# Docker build and run locally
docker build -t christian-brothers-lining .
docker compose up
```

## Architecture

```
Internet → Outer Caddy (HTTPS) → Docker Container (HTTP:8082)
                                      └── Inner Caddy (:80, static files)
```

**Key directories:**
- `content/` - Hugo markdown content (homepage + services)
- `layouts/` - Hugo templates (baseof, partials, service pages)
- `assets/css/` - Styles (main.css with CSS variables)
- `static/images/` - Site images

**Key config files:**
- `hugo.toml` - Hugo configuration (site params, menus, stats)
- `Caddyfile` - Caddy static file server config
- `Dockerfile` - Multi-stage build (Hugo → Caddy)
- `docker-compose.yml` - Container orchestration

## Deployment

Automated via GitHub Actions on push to main/master:
1. Builds Docker image (Hugo static site + optional Go API)
2. Pushes to Docker Hub
3. SSH deploys to VPS via `docker compose pull && up -d`

**Required GitHub Secrets:** `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`, `VPS_HOST`, `VPS_USER`, `VPS_SSH_KEY`

**VPS .env variables:** `DOCKER_IMAGE`, `LISTEN_PORT`, `POSTMARK_TOKEN`, `FROM_EMAIL`, `TO_EMAIL`, `ALLOWED_ORIGIN`, `TURNSTILE_SECRET`

## Contact Form Pattern

Uses Cloudflare Turnstile for spam protection + Go API for email sending via Postmark.

**Turnstile test keys (localhost):**
- Site Key: `1x00000000000000000000AA`
- Secret: `1x0000000000000000000000000000000AA`
