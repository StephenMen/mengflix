# MengFlix Development Plans

Comprehensive strategy for evolving MengFlix from a static demo into a full-featured streaming portal with real backend, user engagement, scalability, and operational maturity.

## Status

Last updated: 2026-06-28

Current state after Phase 1 execution:

| Area | Status | Notes |
|------|--------|-------|
| Donghua in search | Done | Donghua entries added to search index at runtime |
| Favorite button | Done | Heart button persists to localStorage, survives reloads |
| PWA manifest | Done | manifest.json with standalone display, theme color |
| LCP preload | Done | First hero slide image preloaded |
| OG/Twitter meta | Done | Social preview tags in head |
| Zoom/fullscreen | Done | Button on video, hover-to-show, 3s auto-hide |
| Donghua sources | Done | 40 entries with Dailymotion, 12 with animecube fallback |
| Episode grid | Done | Horizontal wrapping, no scroll |
| Permissions-Policy | Done | Fullscreen API unblocked |

---

## Overview

MengFlix is a single-page static streaming portal UI with ~150 titles (movies, TV series, donghua), 6 themes, hero carousel, live search, details panel, player overlay with embed servers, and Google OAuth sign-in. Architecture is static-first with JS dynamic enhancement.

These plans are organized across eight strategic pillars with updated priorities based on current progress.

---

## 1. Backend & API Layer

Goal: Move from static JSON files to a real backend with persistent data, authentication, and dynamic queries.

### Phase 1 - Lightweight API (backend-lite)

| Pri | Task | Effort | Notes |
|-----|------|--------|-------|
| P0 | Node.js (Express) or Python (FastAPI) REST endpoints | 2-3 days | Serve all JSON data via API |
| P0 | Serve cards/search/details/donghua JSON via API | 0.5 day | Backward compat with t= cache busting |
| P1 | PostgreSQL/SQLite for persistent metadata | 1-2 days | Dynamic CRUD without rebuilds |
| P1 | Migrate build_site.ps1 into API seed scripts | 1 day | API-driven content management |

### Phase 2 - User Authentication

| Pri | Task | Effort | Notes |
|-----|------|--------|-------|
| P0 | Wire Google OAuth server-side (JWT sessions) | 1 day | Replace client-only OAuth |
| P1 | Email/password via Supabase or Firebase Auth | 1 day | Sign-in modal already built |
| P2 | Password reset, email verification | 1 day | Auth UX completeness |

### Phase 3 - Admin API

| Pri | Task | Effort | Notes |
|-----|------|--------|-------|
| P1 | Admin CRUD for titles, genres, cast | 1-2 days | Role-based access |
| P2 | Content approval workflow | 2 days | Community submissions |
| P2 | Analytics endpoints | 1 day | Popular titles, search trends |

Dependencies: Node.js/Express or FastAPI service, PostgreSQL/Supabase instance.

---

## 2. User Profiles & Social Features

Goal: Make MengFlix a personalized, social experience beyond anonymous browsing.

### Phase 1 - Core Profile

| Pri | Task | Effort | Notes |
|-----|------|--------|-------|
| P0 | User profile page (avatar, name, join date, stats) | 1 day | Uses Google OAuth profile data |
| P0 | Watchlist - add/remove titles per user | 1.5 days | Persisted via API |
| P0 | Continue Watching - track playback progress | 1.5 days | Store last-watched server + timestamp |
| P1 | Recently Viewed history (last 20) | 0.5 day | Auto-tracked on play/detail view |

### Phase 2 - Favorites & Ratings

| Pri | Task | Effort | Notes |
|-----|------|--------|-------|
| P0 | Favorite toggle (localStorage works, needs API) | 0.5 day | Heart button already wired to localStorage |
| P1 | Star rating (1-5) per title | 1 day | Aggregate to average rating |
| P2 | User reviews/comments | 2 days | Moderation queue |
| P2 | Like/dislike on reviews | 1 day | Community engagement |

### Phase 3 - Social

| Pri | Task | Effort | Notes |
|-----|------|--------|-------|
| P2 | Share buttons (copy link, X/Twitter, Facebook) | 0.5 day | Uses navigator.share on mobile |
| P2 | Friend/follow system | 2 days | Activity feed |
| P2 | User-generated lists | 2 days | Curated collections |

Dependencies: Backend API with user data storage, auth middleware.

---

## 3. Content & Data Strategy

Goal: Expand the content library, improve metadata richness, and automate content acquisition.

### Phase 1 - Metadata Enrichment

| Pri | Task | Effort | Notes |
|-----|------|--------|-------|
| P1 | Add director/cast/country/language to all titles | 1 day | Already in details.json for some |
| P1 | YouTube trailer links for every title | 1 day | TMDB/OMDb API |
| P1 | Backdrop images per title (TMDB) | 1 day | High-res backdrops |
| P2 | Content warnings, MPAA ratings | 0.5 day | Parental guidance |

### Phase 2 - Content Expansion

| Pri | Task | Effort | Notes |
|-----|------|--------|-------|
| P1 | Increase library to 500+ titles | Ongoing | Scrape scripts + curation |
| P1 | Run donghua scraper weekly for new episodes | 0.5 day setup | GitHub Actions cron |
| P2 | Add anime section (separate from donghua) | 1-2 days | New scraper |
| P2 | Add documentaries section | 1 day | New category |

### Phase 3 - Content Automation

| Pri | Task | Effort | Notes |
|-----|------|--------|-------|
| P1 | Auto-update donghua episodes via cron | 1 day | Firebase Cloud Functions or GitHub Actions |
| P2 | TMDB/OMDb auto-metadata | 1 day | Seed new titles |
| P2 | Source health checker | 1 day | Verify embed URLs periodically |

Dependencies: TMDB API key, scraper infrastructure.

---

## 4. UI/UX & Frontend Architecture

Goal: Elevate the user experience to feel like a polished streaming service.

### Phase 1 - Core UX Upgrades

| Pri | Task | Effort | Notes |
|-----|------|--------|-------|
| P0 | View All page with grid, sort, filter | 2 days | Separate page, not inline expand |
| P0 | Category/genre filtering on View All | 1 day | Filter by genre, year, rating |
| P1 | Infinite scroll for large categories | 1 day | Virtual scrolling for 500+ titles |
| P1 | Skeleton loading states on all async sections | 0.5 day | CSS already exists |

### Phase 2 - Search Improvements

| Pri | Task | Effort | Notes |
|-----|------|--------|-------|
| P1 | Search filters (type, genre, year) | 1 day | Filter pills in search overlay |
| P1 | Keyboard navigation for search results | 0.5 day | Arrow keys + Enter |
| P2 | Search suggestions/autocomplete | 1 day | Top 5 suggestions on 3+ chars |

### Phase 3 - Player & Video

| Pri | Task | Effort | Notes |
|-----|------|--------|-------|
| P1 | Full-screen via browser API (done for desktop, test mobile) | 0.5 day | requestFullscreen on player-frame-wrap |
| P1 | Picture-in-picture mode | 0.5 day | For browsing while watching |
| P2 | Keyboard shortcuts cheat sheet | 0.5 day | Space=play/pause, F=fullscreen |
| P2 | Drag-to-reorder watchlist | 1 day | Prioritize what to watch |

Dependencies: None - can proceed immediately.

---

## 5. Performance & Architecture

Goal: Sub-2-second first meaningful paint, sub-100 KB critical path, 60fps interactions.

### Phase 1 - Load Performance

| Pri | Task | Effort | Notes |
|-----|------|--------|-------|
| P0 | Service Worker for static asset caching (sw.js) | 1 day | Cache-first for JSON/CSS/JS |
| P1 | WebP/AVIF poster support with picture | 1 day | Many posters are .webp |
| P1 | Font subsetting (Latin/Asian glyphs only) | 0.5 day | Shaves ~50 KB |
| P1 | Defer non-critical JS via dynamic import() | 1 day | Split episodes.js, ripple.js |
| P2 | Brotli compression on Netlify | 0.5 day | ~20% improvement over gzip |

### Phase 2 - Runtime Performance

| Pri | Task | Effort | Notes |
|-----|------|--------|-------|
| P1 | Virtual scrolling for search (500+ items) | 1 day | Currently renders DOM for all matches |
| P1 | Image decode async + loading=lazy audit | 0.5 day | Confirm all images lazy-loaded |
| P2 | CSS containment on sections | 0.5 day | Isolate paint for slider sections |

### Phase 3 - Build Pipeline

| Pri | Task | Effort | Notes |
|-----|------|--------|-------|
| P1 | Move from PowerShell build to Node.js/Python | 1 day | Cross-platform, testable |
| P1 | Sourcemaps for JS/CSS debugging | 0.5 day | Dev builds only |
| P2 | CI/CD with GitHub Actions (lint, test, build, deploy) | 1 day | Add checks to deploy |
| P2 | Asset fingerprinting for cache busting | 1 day | Hash-based filenames |

Dependencies: Netlify config, build pipeline rewrite.

---

## 6. PWA & Mobile Experience

Goal: Feel like a native app on mobile - installable, offline-capable, touch-optimized.

### Phase 1 - PWA Baseline

| Pri | Task | Effort | Notes |
|-----|------|--------|-------|
| P0 | Service Worker registration + install prompt | 1 day | Cache static assets |
| P1 | Offline fallback page | 1 day | You are offline |
| P1 | Add to Home Screen prompt | 0.5 day | Custom beforeinstallprompt UI |

### Phase 2 - Mobile UX

| Pri | Task | Effort | Notes |
|-----|------|--------|-------|
| P0 | Bottom navigation bar on mobile | 1 day | Home, Search, Watchlist, Profile |
| P1 | Swipe gestures on hero/sliders | 1 day | Native touch |
| P1 | Pull-to-refresh for content sections | 0.5 day | Refresh cards.json data |
| P2 | Haptic feedback on interactions | 0.5 day | navigator.vibrate() |

### Phase 3 - Push & Sync

| Pri | Task | Effort | Notes |
|-----|------|--------|-------|
| P2 | Push notifications (new episodes, trending) | 2 days | Firebase Cloud Messaging or Web Push |
| P2 | Background sync for watch progress | 1 day | Sync offline progress |

Dependencies: Service Worker, HTTPS (already on Netlify), manifest icons.

---

## 7. SEO & Discoverability

Goal: Get indexed properly by search engines and rank for relevant queries.

### Phase 1 - Technical SEO

| Pri | Task | Effort | Notes |
|-----|------|--------|-------|
| P0 | Dynamic title and meta per page/title | 1 day | Update via JS on detail open |
| P1 | Structured data (JSON-LD) for all titles | 1 day | Movie/TVSeries schema |
| P1 | XML sitemap generation (build-time) | 0.5 day | Include all titles |
| P2 | robots.txt + canonical URLs | 0.5 day | Prevent duplicate content |

### Phase 2 - Content SEO

| Pri | Task | Effort | Notes |
|-----|------|--------|-------|
| P1 | Dedicated page per title (/movie/gladiator-ii) | 2 days | Server-rendered or static |
| P1 | Category/collection pages (/genre/action) | 1 day | SEO-friendly URLs |
| P2 | Breadcrumb structured data | 0.5 day | Google SERP breadcrumbs |

### Phase 3 - Analytics

| Pri | Task | Effort | Notes |
|-----|------|--------|-------|
| P1 | Plausible or GA4 integration | 0.5 day | Privacy-respecting analytics |
| P1 | Search Console verification | 0.5 day | Track indexed pages |

Dependencies: SSR infrastructure, per-title URL routing.

---

## 8. Operational Maturity

Goal: Run with confidence - monitoring, testing, documentation, and team workflows.

### Phase 1 - Testing

| Pri | Task | Effort | Notes |
|-----|------|--------|-------|
| P0 | Core interaction tests (Playwright) | 1 day | Search, player, details, themes |
| P1 | Visual regression tests for all themes | 2 days | Screenshot comparison |
| P1 | Accessibility audit + WCAG 2.1 AA fixes | 2 days | axe-core |
| P1 | Mobile viewport tests (320px-768px) | 1 day | Responsive regression |
| P2 | Load testing (k6 or artillery) | 1 day | 1000 concurrent users |

### Phase 2 - Monitoring

| Pri | Task | Effort | Notes |
|-----|------|--------|-------|
| P1 | Error tracking (Sentry) | 0.5 day | Catch JS errors in production |
| P1 | Uptime monitoring | 0.5 day | 5-minute check interval |
| P1 | Lighthouse CI performance budgeting | 1 day | Fail CI on perf regressions |

### Phase 3 - Documentation

| Pri | Task | Effort | Notes |
|-----|------|--------|-------|
| P1 | CONTRIBUTING.md | 0.5 day | Setup guide, conventions |
| P1 | OpenAPI/Swagger docs for backend | 1 day | Document all REST endpoints |
| P2 | CHANGELOG.md via semantic commits | 0.5 day | Conventional commits |

Dependencies: Netlify deploy previews (already configured), Playwright setup.

---

## Implementation Roadmap

The work is organized into three horizons. Each horizon builds on the previous one.

### Horizon 1 - Foundation (Weeks 1-4)

1. Backend-lite API (Express/FastAPI serving existing JSON data)
2. Wire Google OAuth server-side with JWT sessions
3. User profile page + watchlist + continue watching
4. Skeleton loading states for all async sections
5. Service Worker + PWA manifest (installable, offline-capable)
6. View All page with genre/year filtering
7. Core E2E Playwright tests (search, player, details, themes)
8. Dynamic title/meta tags per title

Deliverable: Real web app with persisted user state, offline support, and proper test coverage.

### Horizon 2 - Engagement (Weeks 5-8)

1. Expand library to 300+ titles with richer metadata
2. Star ratings + user reviews
3. Bottom navigation bar on mobile
4. More Like This recommendations in details panel
5. Category/collection pages (SEO-friendly URLs)
6. Dedicated per-title pages for SEO
7. Keyboard shortcuts + full-screen player mode
8. Push notifications for new episodes

Deliverable: Users stay longer, come back more often, and find content easily.

### Horizon 3 - Scale (Weeks 9-12)

1. Admin dashboard for content management
2. Automated donghua episode scraper pipeline
3. Analytics dashboard (popular titles, search trends, user growth)
4. Accessibility audit + WCAG 2.1 AA compliance
5. Load testing + performance optimization
6. OpenAPI documentation + CONTRIBUTING.md

Deliverable: Production service with monitoring, automation, and contributor-friendly docs.

---

## Technical Decisions

| Decision | Option | Rationale |
|----------|--------|-----------|
| Backend | Node.js (Express) | Already has server.js; JS across frontend/backend |
| Database | Supabase (PostgreSQL) | Free tier, built-in auth, real-time |
| Auth | Supabase Auth + Google OAuth | Replaces hand-rolled JWT |
| Hosting | Netlify (frontend) + Render/Railway (backend) | Current setup stays |
| PWA | Workbox (service worker) | Simplifies caching strategies |
| Testing | Playwright + axe-core | Already installed; axe for a11y |
| Analytics | Plausible (self-hosted) | Privacy-respecting, no cookie banner |
| CI/CD | GitHub Actions | Already GitHub-hosted |
| SSR | Eleventy (11ty) for static prerender | Lightweight per-title pages |
| Fonts | Inter (body) + Instrument Sans (display) | Established pairing |

---

## Current State vs Target Metrics

| Metric | Current | H1 Target | H2 Target | H3 Target |
|--------|---------|-----------|-----------|-----------|
| Title count | ~150 | 200 | 400 | 500+ |
| Critical path size | ~153 KB | <100 KB | <80 KB | <60 KB |
| Lighthouse Performance | Likely 50-65 | 80+ | 90+ | 95+ |
| SEO-indexed pages | 1 (homepage) | 50+ | 200+ | 500+ |
| Mobile nav | Hamburger menu | Bottom nav bar | Bottom nav + gestures | Bottom nav + gestures |
| Auth | Google OAuth client-only | Google + email/password | Full auth with sessions | SSO + magic link |
| User features | Favorites (localStorage) | Watchlist + continue watching | Ratings + reviews | Lists + friends |
| Offline support | None | Static assets cached | Full offline catalog | Offline-first |
| Tests | None | 20+ E2E tests | 50+ tests + a11y | 100+ tests + load tests |
| Monitoring | None | Error tracking | Uptime + perf budgets | Full dashboard |

---

## Quick Wins (Can Start Today)

### No backend needed

- [ ] **Skeleton loading states** - CSS exists, just show/hide during async loads
- [ ] **Dynamic per-title meta tags** - Update OG tags via JS when details panel opens
- [ ] **Search filters** - Add genre/year/type filter pills to the search overlay
- [ ] **View All page** - Full grid with category/genre filtering
- [ ] **Continue Watching (localStorage)** - Track last-played timestamp per title
- [ ] **Keyboard shortcuts** - F=fullscreen, M=mute, ?=help overlay

### Needs backend

- [ ] **User watchlist** - Persisted cross-device via API
- [ ] **Continue Watching progress** - Server-side tracking
- [ ] **User ratings** - Star ratings with aggregate display
- [ ] **Server-side rendering** - For SEO
- [ ] **Push notifications** - New episodes, trending alerts

---

## Risk & Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Embed sources go offline | High | High | Source health checker; multiple fallback providers |
| Scrapers break on site redesign | Medium | Medium | Modular scraper per source; monitoring |
| Google OAuth credential rotation | Low | High | Use Supabase Auth (handles rotation) |
| Netlify bandwidth costs at scale | Medium | Medium | Image CDN; lazy load; cache via SW |
| DMCA/takedown for embed aggregator | Medium | High | Disclaimer + takedown contact; no direct hosting |
| Browser deprecates third-party iframe embeds | Medium | Medium | Server-to-server proxying; new-tab fallbacks |

---

## How to Use This Document

- Each section is self-contained - pick a pillar and execute in phase order
- **P0** items are critical path for that pillar's goal
- **P1** items are valuable but not blocking
- **P2** items are polish/scale
- The Implementation Roadmap suggests sequencing across all pillars
- Quick Wins are safe to start without any infrastructure changes
- Revisit this document after each horizon to update priorities and metrics