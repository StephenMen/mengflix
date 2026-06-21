# MengFlix

A white + 3D-textured movie website that mirrors the layout of `yflix.ws/welcome`,
re-skinned in porcelain white with neumorphic, embossed, and soft-glass 3D details.

Click any card (or the hero "Play Now" button) to open a full details panel with
poster, backdrop, IMDb rating, runtime, year, genres, director, cast, description,
and a link to the trailer.

From the details panel (or the hero "Play Now" button), choose **Play** to launch the in-site
**player tab**: a full-viewport overlay with all available yFlix embed servers, so you can
watch the movie without leaving the site.

## Run

It''s a static site. Open `index.html` directly, or serve the folder:

```
cd C:\Users\mengxiang\Documents\MengFlix
python -m http.server 8765
```

Then visit `http://127.0.0.1:8765/`.

Tips:
- Append `?open=Swapped` to deep-link into a specific title''s details panel.
- Append `?theme=black` (or `white`, `orange`, `green`, `purple`, `blue`) to preview a theme.
- Append `?play=Grand%20Illusion` (or any title) to open the player tab directly on load.

## Structure

- `index.html` — single-page markup (header, hero carousel, 6 content sliders, footer, search overlay, details panel)
- `assets/css/styles.css` — white + 3D theme + details panel styles (neumorphic shadows, embossed controls, soft glass)
- `assets/js/main.js` — hero carousel, slider nav, search overlay, mobile menu, details panel open/close + render
- `assets/details.json` — per-title metadata scraped from yFlix (IMDb, runtime, country, director, cast, trailer, embed sources, etc.)
  - Each entry with `sources` carries 19 embed `[{name, url}]` pairs scraped from the yFlix watch page; the first is auto-selected when the player opens.
- `assets/poster_map.json` — slug → yFlix poster URL map
- `assets/posters/*.svg` — 65 locally generated SVG posters (genre-tinted gradients) used as fallbacks
- `assets/backdrops/*.svg` — 6 hero backdrop SVGs
- `assets/img/favicon.svg` — branded favicon
- `build_site.ps1` / `build_posters.ps1` / `scrape_details.ps1` — PowerShell generators

## Theme notes

- Soft white surface with low-contrast 3D-blob background and a subtle dot grid
- Double-shadow (light top-left, dark bottom-right) for the embossed 3D effect
- Gradient red/orange accent for primary actions and active states
- Hero carousel auto-rotates (paused under `prefers-reduced-motion`)

## Details panel

Triggered by clicking any `.content-card` or the hero "Play Now" / info button.
On open it:

- Looks up the title in `assets/details.json` (yFlix metadata) and falls back to a curated set
- Decodes any HTML entities (e.g. `&apos;`) in scraped strings
- Renders poster, blurred backdrop, title, breadcrumbs, IMDb / runtime / year / genre badges, full description, country / released / genres / director / casts / type meta-grid, stars, and trailer link
- Closes on the X button, ESC key, backdrop click, or any of the breadcrumb links
- Uses `prefers-reduced-motion` to skip panel entrance animation


## Player tab

Clicking **Play Now** in the hero or the details panel opens an in-site **player tab**:

- **Server picker** at the top of the player lists every available yFlix embed (e.g. `Haze`, `Kappa`, `Mist`, `Lumen`, `Beta`, etc.) with the host name underneath. The first server is auto-selected so playback usually starts immediately.
- Click a different server pill to swap the embed URL — useful when one provider is geo-blocked, slow, or missing the title.
- The embed is rendered in a 16:9 iframe with `autoplay; fullscreen; picture-in-picture` permissions.
- Close via the **X** button, any breadcrumb link, or the **Esc** key. Closing releases the iframe so playback stops.
- An **Open on yFlix →** link in the hint line takes you to the original yFlix watch page for that title.
- The first server in the source list is pre-selected. Order is whatever yFlix returned in `data-sources` (typically the most reliable hosts first).

### How sources are populated

yFlix watch pages (e.g. `https://yflix.ws/movie/watch-nd5sjc-grand-illusion-1937-hd`) expose a `data-sources="[{name,url}, ...]` attribute on the player wrap. `scrape_sources.py` fetches each watch URL listed in `scrape_details.ps1`, parses the JSON, and stores it in `details.json` under each title''s `sources` and `watch_url` keys. Re-run it whenever you add new titles:

```bash
python scrape_sources.py
```

The player overlay code lives in `assets/js/main.js` (functions `openPlayer`, `selectServer`, `closePlayer`) and its styles are at the bottom of `assets/css/styles.css` under `/* Player Overlay */`. The `?play=<Title>` URL helper deep-links into a movie.

## Theme switcher

The site ships with 6 themes: **Light** (default), **Dark**, **Orange**, **Green**, **Purple**, and **Blue**.

- Open the switcher via the palette button in the top-right of the header.
- Selection is persisted in `localStorage` under the `mengflix-theme` key.
- A fresh visitor with no saved preference follows `prefers-color-scheme: dark` (Dark) or defaults to Light.
- The URL `?theme=<name>` parameter takes precedence over both the saved and system preferences — useful for previews and screenshots.
- The active theme is applied as `data-theme="<name>"` on the `<html>` element; every color reads from CSS custom properties so the entire UI re-skins instantly.

Each theme defines the same token set (`--bg`, `--ink`, `--surface`, `--accent`, `--shadow-color`, `--highlight-color`, `--hero-fade`, etc.) so the white/3D embossed look stays consistent across color choices. Derived tokens (`--shadow-soft`, `--shadow-soft-sm`, `--shadow-pop`, `--shadow-inset`, `--surface-glass`) compose from the per-theme shadow + highlight colors.
