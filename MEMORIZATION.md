# MengFlix Codebase Memorization

This file is a concise summary of the entire MengFlix project. Read this first in a new chat to understand the codebase without re-reading all source files.

---

## What Is MengFlix

MengFlix is a single-page static streaming portal UI. It is a **portfolio/demo** project -- it does not host any media. It displays a library of movies, TV series, and donghua (Chinese animation) with curated metadata, posters, and external embed sources. Users click a card, see details, then pick a server to stream from (via iframe embeds or new-tab redirects).

- Source: https://github.com/StephenMen/mengflix
- Hosted on: Netlify (auto-deploys from main branch)
- Dev server: node server.js on port 8080

---

## Project Structure

`
MengFlix/
  index.html                  # Main single-page app (built by build_site.ps1)
  server.js                   # Simple Node.js HTTP dev server (port 8080)
  build_site.ps1              # PowerShell build script (generates index.html + JSON data)
  build_posters.ps1           # Generates SVG posters + backdrops from color palettes
  deploy.ps1                  # Git add/commit/push to main (Netlify auto-deploys)
  scrape_sources.py           # Scrapes yFlix embed sources into details.json
  scrape_ramoflix.py          # Scrapes RamoFlix embed sources into details.json
  scrape_donghua_sources.py   # Scrapes animecube.live Dailymotion sources for donghua
  scrape_animecube.py         # Scrapes donghua metadata from animecube.live
  fix_search.py               # Fixes search index JSON
  minify.py                   # Minifies HTML/CSS/JS after build
  package.json                # Node dep: playwright (for testing)

  assets/
    css/
      styles.css              # Main stylesheet (~900 lines, one CSS file)
      theme-*.css             # Theme overrides (black/blue/green/orange/purple)
    js/
      main.js                 # Core app logic (IIFE ~600 LOC minified)
      episodes.js             # Donghua episode picker UI (~200 LOC)
      ripple.js               # Animation helpers (close animations, press effects)
    img/ favicon.svg
    posters/                  # Per-title poster images (SVG + webp/jpg)
    backdrops/                # Per-title SVG backdrop images
    cards.json                # Generated: section -> card array for dynamic loading
    search_index.json         # Generated: flat array of all cards for search
    full_data.json            # Generated: full movies + tvs arrays for View All
    details.json              # Curated + scraped metadata per title
    donghua.json              # Donghua metadata + episodes + sources
    donghua_poster_map.json   # Slug -> poster URL map from animecube
    donghua_section.html      # Pre-rendered donghua section HTML snippet
`

---

## Key Architecture Decisions

### 1. Static-First, Dynamic Enhancement

The HTML is fully pre-built (by build_site.ps1) with skeleton sections. JavaScript dynamically loads card data from cards.json on DOM ready, renders content cards into each section slider-track, and loads search index, detail metadata, and donghua data from the respective JSON files.

### 2. Single CSS File

All styles are in one file (assets/css/styles.css) with CSS custom properties for theming. Theme files override :root variables.

### 3. All JavaScript in IIFEs

main.js is one large minified IIFE (~600 LOC in readable form). All state and DOM refs are local. Exposes window.__mfOpenPlayer, __mfClosePlayer, __mfCloseDetails, __mfAnimateClose for interop.

### 4. No Framework, No Router

Everything is vanilla JS. Overlays (detail, player, search, sign-in) are toggled via hidden attribute + aria-hidden.

---

## Build Pipeline

- build_posters.ps1 generates SVG posters and backdrops
- build_site.ps1 generates index.html + cards.json + search_index.json + full_data.json, then runs minify.py
- scrape_sources.py scrapes yFlix for embed sources into details.json
- scrape_ramoflix.py scrapes RamoFlix for embed sources into details.json (replaces yFlix)
- scrape_animecube.py scrapes animecube.live donghua metadata
- scrape_donghua_sources.py scrapes animecube Dailymotion embeds

Normal workflow: Run build_site.ps1 to rebuild assets. Run deploy.ps1 to push to GitHub.

---

## index.html Structure

### Sections (top to bottom)
1. Site Header -- sticky glassmorphism with logo, nav, search, sign in, mobile hamburger
2. Hero -- 6 featured slides, auto-rotates every 6.5s, arrow keys navigate
3. Intro Card -- Welcome message
4. Latest Movies / Trending Now / Top Rated / Latest TV Series -- horizontal slider sections
5. Donghua -- horizontal slider (if data exists)
6. Footer

### Overlays (hidden by default)
1. Search Overlay -- full-screen live search, keyboard nav, 80ms debounce
2. Detail Overlay -- slide-up panel with metadata, badges, actions
3. Player Overlay -- iframe, server selector, episode grid (donghua), fullscreen
4. Sign In Overlay -- LocalStorage-based mock auth

---

## JavaScript Modules

### main.js (Core)
Functions: loadAndRenderCards(), openPlayer(), closePlayer(), selectServer(), openDetails(), closeDetails(), renderSearchResults(), setupSlider(), sign-in forms, theme system, View All

Data flow for opening a player:
1. Card clicked -> openPlayer(card)
2. Looks up title in details.json
3. If no sources and type is Donghua, falls back to donghua.json
4. Renders server buttons, auto-selects first
5. If watch_url exists and server is yFlix/RamoFlix, intercepts to open in new tab

Popup/focus-steal guards: window.open replaced with no-op, blur listener refocuses, yFlix/RamoFlix use real DOM click

### episodes.js (Donghua Player)
Functions: openDonghuaPicker(), buildEpisodeGrid(), playEpisode()
Donghua cards bypass detail overlay and go straight to player with episode grid.

### ripple.js (Animations)
Overrides __mfAnimateClose for iOS-like close animation. Press effects (scale 0.96 on mousedown).

---

## CSS Architecture

Design tokens in :root: --bg, --ink, --accent, --surface, --radius (12/18/28px), --container (1440px).

6 themes (white/black/orange/green/purple/blue), dynamic link swapping, persisted to localStorage.

Key patterns: Cards (2:3 ratio, 18px radius, scale-up hover), Sliders (CSS grid auto-flow, scroll-snap, drag), Overlays (fixed, backdrop blur, iOS close), Hero (slideshow, zoom, gradient fade), Glassmorphism header.

---

## Data Files

details.json -- per-title metadata with sources[], watch_url, backdrop, poster, desc, etc.
cards.json -- generated, section-id -> card array
donghua.json -- per-donghua with episodes[] and sources[]
search_index.json -- flat card array for search
full_data.json -- { movies: [...], tvs: [...] } for View All

---

## Scraping Pipeline

RamoFlix (current primary): Uses RamoFlix suggestion API, extracts var Servers/Episodes from page HTML, maps server IDs to friendly names.
animecube.live: Donghua metadata + Dailymotion embeds via Firecrawl API.

---

## Deployment

build_site.ps1 to rebuild. deploy.ps1 to commit and push.
Netlify auto-deploys from main. Dev server: node server.js on port 8080.

## Known Behaviors

- yFlix/RamoFlix servers open in new tab (block iframe embedding)
- Donghua cards bypass detail overlay
- View All hides other sections
- Theme override via ?theme=black URL param
- Search debounced 80ms, scored, max 18 results
- Sign in is cosmetic mock only
- Close animations toward trigger element, respects prefers-reduced-motion
- Middle-click/drag prevention on sliders
