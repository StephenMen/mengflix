# MengFlix Optimization Plan

## Current Metrics

| Asset | Size | % of critical path |
|-------|------|-------------------|
| `index.html` | 209 KB | 57% |
| `styles.css` | 78 KB | 21% |
| `main.js` | 82 KB | 22% |
| `details.json` (lazy) | 180 KB | — |
| `donghua.json` (lazy) | 27 KB | — |
| **Critical path total** | **~369 KB** | **100%** |

## Optimization Strategy

### 1. Extract cards to JSON + JS‑render
- **Problem**: 136 `<article>` cards baked into HTML at build time (~140 KB bloat).
- **Fix**: Strip card HTML. Build script writes `cards.json`. JS fetches it and renders cards into empty section shells.
- **Estimated savings**: 209 KB → ~65 KB (69% reduction).

### 2. Extract inactive themes to lazy CSS files
- **Problem**: All 6 theme definitions in one `styles.css`; only 1 active at a time. 5 unused themes waste ~45 KB.
- **Fix**: Keep default (white) theme in `styles.css`. Each non‑default theme becomes a separate file. JS lazy‑loads the chosen theme.
- **Estimated savings**: 78 KB → ~30 KB first load (62% reduction).

### 3. Build‑time minification
- **Problem**: No minification on HTML, CSS, or JS. Whitespace and comments bloat all assets.
- **Fix**: Add a PS1 minify step (strip comments, collapse whitespace, compress inline SVGs).
- **Estimated savings**: ~25–30% across all assets.

### 4. Build a static search index
- **Problem**: JS search scans DOM cards; couples search to full render.
- **Fix**: Build script emits `search_index.json`. JS loads it directly.
- **Estimated savings**: Enables step #1; reduces client CPU/memory.

### 5. Poster placeholder strategy
- **Problem**: All 136 posters are external `<img src>` URLs. Viewport‑adjacent images download speculatively.
- **Fix**: Use a tiny inline SVG placeholder; swap to real URL via IntersectionObserver.
- **Estimated savings**: ~100 KB of speculative image downloads.

### 6. Service Worker
- **Problem**: Repeat visits re‑download 369 KB of assets.
- **Fix**: Register `sw.js` to cache all static assets after first fetch.
- **Estimated savings**: ~369 KB saved on every subsequent visit.

### 7. SVG/string deduplication in JS
- **Problem**: `main.js` duplicates inline SVG viewBox strings and HTML templates.
- **Fix**: Move reusable SVGs to `<template>` elements in HTML; reference by ID.
- **Estimated savings**: 82 KB → ~65 KB.

### 8. Module splitting
- **Problem**: Monolithic JS handles hero, sliders, search, overlays, themes.
- **Fix**: Split into logical modules with dynamic `import()` for the player overlay.
- **Estimated savings**: ~20 KB off critical JS path.

## Implementation Priority

1. **Build search index** — enabler, low effort
2. **Extract cards to JSON + JS‑render** — biggest token win
3. **Theme‑split CSS** — second biggest win
4. **Minification** — low effort, good return
5. **Poster lazy‑placeholder** — polish
6. **Service Worker** — repeat‑visit savings
7. **SVG deduplication** — cleanup
8. **Module splitting** — progressive enhancement

## Predicted Result

| Phase | Current | After | Savings |
|-------|---------|-------|---------|
| HTML | 209 KB | ~65 KB | **69%** |
| CSS | 78 KB | ~30 KB | **62%** |
| JS | 82 KB | ~60 KB | **27%** |
| **Critical path** | **~369 KB** | **~155 KB** | **~58%** |

## Actual Results (achieved)

| Asset | Before | After | Savings |
|-------|--------|-------|---------|
| \index.html\ | 209 KB | 29 KB | **86%** |
| \styles.css\ | 78 KB | 51 KB | **35%** |
| \main.js\ | 82 KB | 73 KB | **11%** |
| \cards.json\ (lazy) | � | 10.5 KB | new |
| \search_index.json\ (lazy) | � | 10.5 KB | new |
| Theme CSS files (lazy) | � | ~10 KB | new |
| **Critical path** | **369 KB** | **153 KB** | **~58%** |

### Key achievements
- **HTML reduced 86%** by extracting 136 cards to \cards.json\ (10.5 KB) and rendering via JS
- **CSS reduced 35%** on first load by splitting 5 inactive themes into lazy-loaded files
- **JS reduced 11%** despite adding card rendering code, thanks to minification
- **Search now uses a static index** � no DOM scanning, works even before cards render
- **Build pipeline** now exports JSON data files and auto-minifies all assets
- **Donghua section** rendered by JS from \donghua.json\ instead of baking 71 KB of HTML
