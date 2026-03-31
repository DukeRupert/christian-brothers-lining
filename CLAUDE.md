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

- `layouts/_default/baseof.html` — Base template with SEO meta, structured data (JSON-LD), Google Fonts (Inter), Alpine.js + Collapse plugin, and Plausible analytics
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

Single CSS file at `assets/css/main.css` using CSS custom properties. Hugo fingerprints and minifies it via `resources.Get` in baseof. Uses `Inter` throughout (body + headings). Brand colors: green primary (`#0A7E42`), orange accent (`#F57C00`) for CTA buttons.

## Client-Side JS

Alpine.js (loaded via CDN in baseof) handles interactive elements like mobile nav and FAQ accordions (via `@alpinejs/collapse` plugin). No build step for JS.

## Deployment

Automated via GitHub Actions (`.github/workflows/deploy.yml`) on push to `main`:
1. Builds Docker image with Hugo + Caddy
2. Pushes to Docker Hub (tagged `latest` + commit SHA)
3. SSH deploys to VPS at `/opt/christian-brothers-lining` via `docker compose pull && up -d`

**Required GitHub Secrets:** `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`, `VPS_HOST`, `VPS_USER`, `VPS_SSH_KEY`

**VPS .env variables:** `DOCKER_IMAGE`, `LISTEN_PORT`

## Design Context

### Users
Municipal decision-makers — city engineers, public works directors, sanitation district managers — evaluating CIPP contractors for pipeline rehabilitation projects. They arrive via search or referral, scan quickly for credibility signals (certifications, municipal client list, project stats), and want to confirm capability before picking up the phone. Secondary audience: general contractors seeking a qualified CIPP subcontractor.

### Brand Personality
**Modern, capable, no-nonsense.** The site should feel like talking to a senior field superintendent who knows every spec, every cert, and every municipality they've worked in. No marketing fluff, no filler words ("innovative," "cutting-edge"), no consumer plumber language. Let the numbers and credentials do the talking.

### Emotional Goal
**Confidence and trust.** The visitor should feel this is a proven, certified, safe-to-award operation within the first viewport. The dark industrial palette and bold typography communicate authority without needing to say it.

### Aesthetic Direction
Dark industrial aesthetic anchored by the mockup and design system (`cblining_homepage_mockup.html`, `cblining-design-system.html`). These are the authoritative visual references.

**Color System (5 colors, 2 accents):**
- Near Black `#0D1117` — primary background, nav, hero, dark sections
- Steel `#1C2B3A` — mid-dark sections, stats bar, alternating dark
- Void `#080C10` — footer only
- Construction Orange `#E8621A` — stats, CTAs, service card borders, phone, interactive elements (the workhorse accent)
- Vivid Green `#2ECC40` — logo mark, cert badges, cert eyebrow only (the credential signal)
- Off White `#F4F2EE` — light section backgrounds, text on dark
- Border `#E2E0DC` — card/component borders

**Color Rules:** Orange and green NEVER appear on the same component or adjacent to each other. Orange is the action color (~80% of accent usage). Green is reserved for trust/credential moments (~20%).

**Typography:**
- Barlow Condensed (400/600/700/800) — all structural text: headlines, stats, nav, buttons, labels. Always uppercase for headings.
- DM Sans (300/400/500/600) — body text, descriptions, UI copy. Normal case.
- No other fonts. No Inter, no system fonts as primary.

**Section Rhythm:** Dark/light alternating bands. Homepage sequence: Nav (#0D1117) → Hero (#0D1117) → Stats (#1C2B3A, 3px orange top border) → Services (#F4F2EE) → Why CB (#1C2B3A) → Municipalities (#F4F2EE) → Certifications (#0D1117) → CTA Strip (#E8621A full bleed) → Footer (#080C10).

**Container:** 960px max-width for content. Section padding: 5rem vertical.

**Component Patterns:**
- Service cards: white bg, 1px border, 4px orange left accent bar
- Stat numbers: Barlow Condensed 800, orange, 44-52px
- Cert cards: subtle dark bg, 1px green border, green badge circles
- Municipality tags: white pills, uppercase Barlow Condensed
- CTA strip: full-bleed orange, large phone number
- Eyebrows: 12px uppercase, wide letter-spacing, orange (or green for cert sections)

### Design Principles

1. **Credentials over claims.** Show certifications, license numbers, municipal client names, and project stats. Never use subjective superlatives. "NASSCO PACP certified" beats "industry-leading quality" every time.

2. **Scan, don't read.** Municipal engineers scan RFQ responses — they'll scan this site the same way. Bold stats, clear section labels, short paragraphs. Every section earns its viewport.

3. **Dark means authority.** The dark palette isn't decorative — it creates contrast that makes orange stats and white text pop. It signals a serious operation, not a consumer service.

4. **Orange acts, green trusts.** Orange drives action (calls, clicks, attention). Green signals trust (certifications, credentials). They never compete for the same space.

5. **No decoration without function.** Every visual element — the orange left-border on service cards, the 3px orange top-border on stats, the green cert badges — carries meaning. No ornamental gradients, no decorative illustrations, no stock photography.

### Accessibility
Target WCAG 2.1 AA compliance. 4.5:1 contrast ratio for normal text, 3:1 for large text. Keyboard navigation support. Screen reader semantic markup. Respect `prefers-reduced-motion`. This audience includes government employees who may use assistive technology or have institutional accessibility requirements.
