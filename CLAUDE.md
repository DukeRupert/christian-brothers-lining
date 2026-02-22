# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Hugo static site for a California pipe rehabilitation company, served by Caddy, deployed to VPS via Docker and GitHub Actions.

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
Internet → Outer Caddy (HTTPS on VPS) → Docker Container (HTTP:8082)
                                              └── Inner Caddy (:80, static files from /srv)
```

Multi-stage Docker build: `hugomods/hugo:exts` builds the site, then static output is copied to `caddy:2-alpine`.

## Template Structure

- `layouts/_default/baseof.html` — Base template with SEO meta, structured data (JSON-LD), Google Fonts (Inter + Montserrat), Alpine.js + Collapse plugin, and Plausible analytics
- `layouts/index.html` — Homepage (hero, municipalities, services grid, advantages, stats, CTA)
- `layouts/services/single.html` — Service detail pages (hero, image, benefits grid, process steps, content, related services, CTA)
- `layouts/_default/careers.html` — Careers page (uses `{{ .Content }}` from markdown)
- `layouts/partials/header.html`, `footer.html` — Shared header/footer

## Service Page Content Pattern

Service pages are data-driven via front matter in `content/services/*.md`. The template renders structured fields — no markdown body needed:

```yaml
title: "Service Name"
description: "SEO description"
intro: "Displayed below the h1"
image: "/images/photo.webp"
benefits_title: "Why Choose X"
benefits:
  - title: "Benefit"
    description: "Details"
process_title: "Our Process"
process:
  - title: "Step"
    description: "Details"
related:
  - "/services/other-service"
```

## Homepage Content Pattern

The homepage (`content/_index.md`) similarly uses front matter for `municipalities`, `services` (with inline SVG icons), and `advantages`. Site-wide stats and company info come from `hugo.toml` params.

## Styling

Single CSS file at `assets/css/main.css` using CSS custom properties. Hugo fingerprints and minifies it via `resources.Get` in baseof. Uses `Inter` for body text and `Montserrat` for headings.

## Client-Side JS

Alpine.js (loaded via CDN in baseof) handles interactive elements like mobile nav and FAQ accordions (via `@alpinejs/collapse` plugin). No build step for JS.

## Deployment

Automated via GitHub Actions (`.github/workflows/deploy.yml`) on push to `main`:
1. Builds Docker image with Hugo + Caddy
2. Pushes to Docker Hub (tagged `latest` + commit SHA)
3. SSH deploys to VPS at `/opt/christian-brothers-lining` via `docker compose pull && up -d`

**Required GitHub Secrets:** `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`, `VPS_HOST`, `VPS_USER`, `VPS_SSH_KEY`

**VPS .env variables:** `DOCKER_IMAGE`, `LISTEN_PORT`
