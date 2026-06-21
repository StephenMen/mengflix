"""
scrape_ramoflix.py

For each MengFlix title, look it up on ramoflix.net, fetch the post page,
extract the player Servers/Episodes JSON, and merge the result into
assets/details.json as a fresh set of `sources` + `watch_url` (replacing any
existing yflix sources/watch_url).

Output:
  - updates assets/details.json in place (preserves existing metadata)
  - writes _ramoflix_scrape.json with full results for debugging
"""
import json
import os
import re
import sys
import time
import gzip
import zlib
import ssl
import socket
import urllib.request
import urllib.parse
import html as htmlmod

UA = (
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/126.0 Safari/537.36"
)

BASE = r"C:\Users\mengxiang\Documents\MengFlix"
DETAILS_PATH = os.path.join(BASE, "assets", "details.json")
SCRAPE_DUMP  = os.path.join(BASE, "_ramoflix_scrape.json")

socket.setdefaulttimeout(30)
CTX = ssl._create_unverified_context()
SUGGESTIONS_NONCE = "3f1fc9c1e7"  # exposed in every page's Suggestions object

# Title list scraped from index.html. Format: (Title, Type, Year)
# Alternate search terms for titles that the simple search does not match.
ALIASES = {
    "Beetlejuice B.":  ["beetlejuice beetlejuice", "beetlejuice"],
    "Joker: Folie 2":  ["joker folie a deux", "joker folie", "joker"],
    "Morning Show":    ["the morning show"],
    "Furiosa":         ["furiosa a mad max saga"],
    "Reacher":         ["reacher", "reacher tv"],
    "Andor":           ["andor", "andor star wars"],
    "Society of Snow": ["society of the snow", "society of snow"],
    "The Boys":        ["the boys", "boys"],
    "Fargo":           ["fargo tv", "fargo"],
}

# Hardcoded direct page URLs for titles whose search fails for any reason.
# (title, year, type, url) -- only consulted if all searches come back empty.
HARDCODE = {
    "The Boys":         (2019, "TVSeries", "https://ramoflix.net/the-boys/"),
}

# Titles that are simply not on ramoflix.net. Skipped during scrape.
SKIP_TITLES = {
    "Breaking Boundaries",  # 2024 documentary, not on ramoflix
    "Bangalore Days",       # 2014 Malayalam film, not on ramoflix
}

TITLES = [
    ("The Devil Wears Prada 2", "Movie", 2026),
    ("Swapped", "Movie", 2026),
    ("Michael", "Movie", 2026),
    ("Apex", "Movie", 2026),
    ("Scream 7", "Movie", 2026),
    ("Breaking Boundaries", "Movie", 2024),
    ("Bangalore Days", "Movie", 2014),
    ("Baraka", "Movie", 1992),
    ("Chak De! India", "Movie", 2007),
    ("Seaspiracy", "Movie", 2021),
    ("Dune: Part Two", "Movie", 2024),
    ("Oppenheimer", "Movie", 2023),
    ("Poor Things", "Movie", 2023),
    ("The Substance", "Movie", 2024),
    ("Wicked", "Movie", 2024),
    ("Conclave", "Movie", 2024),
    ("Nosferatu", "Movie", 2024),
    ("A Real Pain", "Movie", 2024),
    ("Gladiator II", "Movie", 2024),
    ("Heretic", "Movie", 2024),
    ("The Wild Robot", "Movie", 2024),
    ("Civil War", "Movie", 2024),
    ("Hit Man", "Movie", 2024),
    ("Love Lies Bleeding", "Movie", 2024),
    ("Furiosa", "Movie", 2024),
    ("Alien: Romulus", "Movie", 2024),
    ("It Ends With Us", "Movie", 2024),
    ("Beetlejuice B.", "Movie", 2024),
    ("Joker: Folie 2", "Movie", 2024),
    ("Smile 2", "Movie", 2024),
    ("Terrifier 3", "Movie", 2024),
    ("Society of Snow", "Movie", 2023),
    ("Shogun", "TVSeries", 2024),
    ("The Penguin", "TVSeries", 2024),
    ("Severance", "TVSeries", 2022),
    ("The Bear", "TVSeries", 2022),
    ("House of the Dragon", "TVSeries", 2022),
    ("Andor", "TVSeries", 2022),
    ("The Last of Us", "TVSeries", 2023),
    ("Succession", "TVSeries", 2018),
    ("The White Lotus", "TVSeries", 2021),
    ("Reacher", "TVSeries", 2022),
    ("Slow Horses", "TVSeries", 2022),
    ("Morning Show", "TVSeries", 2019),
    ("Beef", "TVSeries", 2023),
    ("Wednesday", "TVSeries", 2022),
    ("Stranger Things", "TVSeries", 2016),
    ("The Crown", "TVSeries", 2016),
    ("Peaky Blinders", "TVSeries", 2013),
    ("Better Call Saul", "TVSeries", 2015),
    ("Breaking Bad", "TVSeries", 2008),
    ("The Boys", "TVSeries", 2019),
    ("Invincible", "TVSeries", 2021),
    ("Arcane", "TVSeries", 2021),
    ("One Piece", "TVSeries", 2023),
    ("Fallout", "TVSeries", 2024),
    ("True Detective", "TVSeries", 2014),
    ("Fargo", "TVSeries", 2014),
]

# Server labels shown in the UI (matches the visible names in the Servers block)
SERVER_LABELS = {
    # movies
    "embedru":    "Vidsrc",
    "vidlink":    "Videasy",
    "superembed": "VidFast",
    "vidsrc":     "111movies",
    "vidsrc2":    "Vidzee",
    "movieclub":  "Vidwtf",
    "svetacdn":   "Svetacdn",
    "openvids":   "Openvid",
    "premium":    "RamoFlix",
    # shows (different host keys in the JS-built URL)
    "Vidfast":    "Vidsrc",
    "vidlink_tv": "Videasy",
    "Openvid":    "111movies",
    "movieclub_tv": "Vidwtf",
}

# Provider labels for the player UI
PROVIDER_FROM_HOST = {
    "soap2night.site":       "Soap2Night",
    "player.videasy.net":    "Videasy",
    "vidfast.pro":           "VidFast",
    "111movies.com":         "111Movies",
    "player.vidzee.wtf":     "Vidzee",
    "vidsrc.wtf":            "VidSrc",
    "vidsrc.to":             "VidSrc",
    "svetacdn":              "Svetacdn",
    "ramoflix.net":          "RamoFlix",
}


def _decode(data, ce):
    if ce == "gzip":
        return gzip.decompress(data)
    if ce == "deflate":
        try:
            return zlib.decompress(data)
        except zlib.error:
            return zlib.decompress(data, -zlib.MAX_WBITS)
    return data


def fetch(url, retries=3, accept="*/*"):
    """GET url with a real browser UA. Returns text."""
    last = None
    for i in range(retries):
        try:
            req = urllib.request.Request(
                url,
                headers={
                    "User-Agent": UA,
                    "Accept": accept,
                    "Accept-Language": "en-US,en;q=0.5",
                    "Accept-Encoding": "gzip, deflate",
                },
            )
            with urllib.request.urlopen(req, timeout=30, context=CTX) as r:
                raw = r.read()
                ce = r.headers.get("Content-Encoding", "")
                return _decode(raw, ce).decode("utf-8", errors="replace")
        except Exception as e:
            last = e
            time.sleep(1.0 + i * 0.5)
    raise last


def search(title):
    """Hit the suggestions endpoint and return the dict {tmdb_id: {...}}.

    Returns None for throttled/HTML responses or error payloads
    (e.g. {"error": "no_posts"}).
    """
    q = urllib.parse.quote(title)
    url = f"https://ramoflix.net/wp-json/fmovie/suggestions/?keyword={q}&nonce={SUGGESTIONS_NONCE}"
    text = fetch(url, accept="application/json")
    if not text or text.lstrip().startswith("<"):
        # Server returned an HTML page (challenge / throttle / 404)
        return None
    try:
        data = json.loads(text)
    except Exception:
        return None
    if not isinstance(data, dict):
        return None
    if "error" in data:
        # {"error": "no_posts", "title": "No results"}
        return None
    return data


def pick_best(suggestions, title, typ, year):
    """Pick the best suggestion for the requested (title, type, year)."""
    if not isinstance(suggestions, dict):
        return None
    expected_type = "Movie" if typ == "Movie" else "TV"
    exact, fuzzy, looser = None, None, None
    for tmdb_id, entry in suggestions.items():
        if not isinstance(entry, dict):
            continue
        if entry.get("type") != expected_type:
            continue
        cyear = (entry.get("extra", {}).get("release_date", "") or "")[:4]
        if cyear == str(year) and entry["title"].strip().lower() == title.strip().lower():
            exact = (tmdb_id, entry)
        elif cyear == str(year):
            fuzzy = (tmdb_id, entry)
        else:
            looser = (tmdb_id, entry)
    return exact or fuzzy or looser


def parse_servers_block(body):
    """Find the var Servers = {...} JSON on a movie page."""
    m = re.search(r"var\s+Servers\s*=\s*(\{[^}]+\})", body)
    if not m:
        return None
    raw = m.group(1)
    # Unescape the JS literal
    raw = raw.replace('\\"', '"').replace("\\/", "/")
    try:
        return json.loads(raw)
    except Exception:
        return None


def parse_episodes_object(body):
    """Find the var Episodes = {...} JSON on a TV show page."""
    m = re.search(r"var\s+Episodes\s*=\s*(\{[^}]+\})", body)
    if not m:
        return None
    raw = m.group(1).replace('\\"', '"').replace("\\/", "/")
    try:
        return json.loads(raw)
    except Exception:
        return None


def parse_servers_list(body):
    """Find the <ul class="servers"> block on a TV show page and extract
    the data-load-embed-host values (server IDs)."""
    m = re.search(r'<ul[^>]*class="[^"]*servers[^"]*"[^>]*>(.*?)</ul>', body, re.S)
    if not m:
        return []
    block = m.group(1)
    return re.findall(r'data-load-embed-host="([^"]+)"', block)


def provider_for(url):
    """Best-effort provider name from a host."""
    for host, name in PROVIDER_FROM_HOST.items():
        if host in url:
            return name
    try:
        host = urllib.parse.urlparse(url).hostname or ""
    except Exception:
        return "Server"
    return host.replace("www.", "") or "Server"


def build_movie_sources(servers, page_url):
    """Take the Servers object and produce our sources[] + watch_url."""
    if not servers:
        return None
    # Build a stable ordering. We prefer providers known to work without auth.
    preferred = [
        "vidsrc", "vidlink", "superembed", "movieclub",
        "embedru", "vidsrc2", "svetacdn", "openvids", "premium",
    ]
    sources = []
    rank = 0
    seen_urls = set()
    for key in preferred:
        url = servers.get(key)
        if not url:
            continue
        if not url.startswith("http"):
            continue
        # add autoPlay for providers that benefit from it
        if "111movies" in url and "autoPlay" not in url:
            url += "&autoPlay=true" if "?" in url else "?autoPlay=true"
        if url in seen_urls:
            continue
        seen_urls.add(url)
        sources.append({
            "name":     SERVER_LABELS.get(key, key.title()),
            "url":      url,
            "provider": provider_for(url),
            "rank":     rank,
        })
        rank += 1
    return sources or None


def build_tv_sources(episodes, server_ids, page_url):
    """Build sources[] for a TV show. Each entry links to
    https://ramoflix.net/?player_tv={post_id}&s=1&e=1&sv={host}&tv=true
    (season 1, episode 1 - the user can navigate inside the player)."""
    if not episodes or not server_ids:
        return None
    post_id = episodes.get("post_id")
    tvid    = episodes.get("tvid")
    if not post_id or not tvid:
        return None
    # Stable ordering
    preferred_show = ["Vidfast", "vidlink", "Openvid", "movieclub"]
    ordered = [s for s in preferred_show if s in server_ids] + \
              [s for s in server_ids if s not in preferred_show]
    sources = []
    rank = 0
    for host in ordered:
        url = f"https://ramoflix.net/?player_tv={post_id}&s=1&e=1&sv={host}&tv=true"
        sources.append({
            "name":     SERVER_LABELS.get(host, host.title()),
            "url":      url,
            "provider": "RamoFlix",
            "tvid":     tvid,
            "post_id":  post_id,
            "rank":     rank,
        })
        rank += 1
    return sources or None


def scrape_title(title, typ, year):
    """Resolve a MengFlix title on ramoflix and return a (sources, watch_url) tuple or None."""
    print(f"  search: {title} ({typ} {year})")
    # The site occasionally returns an HTML challenge/throttle page instead of JSON.
    # Retry a few times with backoff before giving up.
    queries = [title]
    if title in ALIASES:
        aliases = ALIASES[title]
        if isinstance(aliases, str):
            queries.append(aliases)
        else:
            queries.extend(aliases)
    suggestions = None
    for q in queries:
        for attempt in range(4):
            try:
                suggestions = search(q)
            except Exception as e:
                print(f"    ERR search (attempt {attempt + 1}): {e}")
                suggestions = None
            if suggestions:
                break
            # Back off more aggressively on throttled responses
            time.sleep(2.5 + attempt * 2.0)
        if suggestions:
            break
        time.sleep(1.0)
    if not suggestions:
        # Last-ditch: wait longer and try the first query once more
        time.sleep(6.0)
        for q in queries:
            try:
                suggestions = search(q)
            except Exception as e:
                suggestions = None
            if suggestions:
                break
    if not suggestions and title in HARDCODE:
        hc_year, hc_type, hc_url = HARDCODE[title]
        if hc_type == typ and hc_year == year:
            print(f"    using hardcoded URL: {hc_url}")
            tmdb_id = ""
            entry = {"url": hc_url, "title": title, "type": "TV" if typ == "TVSeries" else "Movie", "extra": {"release_date": str(year)}}
            page_url = hc_url
            body = None
            for page_attempt in range(4):
                try:
                    body = fetch(page_url, accept="text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
                except Exception as e:
                    print(f"    ERR page (attempt {page_attempt + 1}): {e}")
                    body = None
                if not body:
                    time.sleep(2.0 + page_attempt)
                    continue
                if typ == "Movie" and re.search(r"var\s+Servers\s*=", body):
                    break
                if typ == "TVSeries" and re.search(r"var\s+Episodes\s*=", body):
                    break
                time.sleep(2.0 + page_attempt)
                body = None
            if not body:
                print(f"    could not get a usable page after retries")
                return None
            if typ == "Movie":
                servers = parse_servers_block(body)
                if not servers:
                    return None
                sources = build_movie_sources(servers, page_url)
                if not sources:
                    return None
                for s in sources:
                    s["tmdb"] = tmdb_id
                return sources, page_url, tmdb_id
            else:
                episodes = parse_episodes_object(body)
                server_ids = parse_servers_list(body)
                if not episodes or not server_ids:
                    return None
                sources = build_tv_sources(episodes, server_ids, page_url)
                if not sources:
                    return None
                return sources, page_url, tmdb_id
    if not suggestions:
        print(f"    NO suggestions")
        return None
    best = pick_best(suggestions, title, typ, year)
    if not best:
        print(f"    NO matching suggestion")
        return None
    tmdb_id, entry = best
    page_url = entry["url"]
    match_type = "EXACT" if (entry.get("extra", {}).get("release_date", "")[:4] == str(year)
                              and entry["title"].strip().lower() == title.strip().lower()) else "fuzzy"
    print(f"    -> {match_type:6s} tmdb={tmdb_id} {page_url}")
    time.sleep(0.4)
    # Fetch the post page, retrying if we get a sinkhole/challenge page
    # that is missing the expected Servers/Episodes block.
    body = None
    for page_attempt in range(4):
        try:
            body = fetch(page_url, accept="text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
        except Exception as e:
            print(f"    ERR page (attempt {page_attempt + 1}): {e}")
            body = None
        if not body:
            time.sleep(2.0 + page_attempt)
            continue
        if typ == "Movie" and re.search(r"var\s+Servers\s*=", body):
            break
        if typ == "TVSeries" and re.search(r"var\s+Episodes\s*=", body):
            break
        time.sleep(2.0 + page_attempt)
        body = None
    if not body:
        print(f"    could not get a usable page after retries")
        return None
    if typ == "Movie":
        servers = parse_servers_block(body)
        if not servers:
            print(f"    NO Servers JSON on page")
            return None
        sources = build_movie_sources(servers, page_url)
        if not sources:
            print(f"    no usable sources in Servers object")
            return None
        # Store the TMDB id too so we can fix mistakes later
        for s in sources:
            s["tmdb"] = tmdb_id
        return sources, page_url, tmdb_id
    else:
        episodes = parse_episodes_object(body)
        server_ids = parse_servers_list(body)
        if not episodes or not server_ids:
            print(f"    NO Episodes/servers on page")
            return None
        sources = build_tv_sources(episodes, server_ids, page_url)
        if not sources:
            return None
        return sources, page_url, tmdb_id


def main():
    with open(DETAILS_PATH, "r", encoding="utf-8-sig") as f:
        details = json.load(f)

    # Normalise title keys for matching (details.json uses display titles).
    title_keys = set(details.keys())

    results = {}
    for title, typ, year in TITLES:
        if title in SKIP_TITLES:
            print(f"  SKIP {title} (known absent on ramoflix)")
            results[title] = {"status": "skipped"}
            continue
        # Try several possible keys in details.json for this MengFlix title
        candidates = [title]
        # If the title in details.json uses an apostrophe entity, try the entity form
        if "'" in title:
            candidates.append(title.replace("'", "&apos;"))
        if "&apos;" in title:
            candidates.append(title.replace("&apos;", "'"))
        # Find which key is actually in details.json
        target_key = None
        for c in candidates:
            if c in details:
                target_key = c
                break
        # target_key is None means the title is not yet in details.json.
        # We'll create a minimal entry below, but only if the scrape succeeds.
        try:
            res = scrape_title(title, typ, year)
        except Exception as e:
            print(f"  ERR {title}: {e}")
            res = None
        if not res:
            if target_key:
                results[target_key] = {"status": "missing"}
            else:
                results[title] = {"status": "missing (not in details.json)"}
            continue
        # On success, ensure we have a details entry to write into.
        if not target_key:
            details[title] = {
                "title":    title,
                "year":     year,
                "imdb":     "",
                "desc":     "",
                "country":  "",
                "released": "",
                "director": "",
                "casts":    "",
                "genres":   "",
                "trailer":  "",
                "runtime":  "",
                "stars":    0,
                "backdrop": "",
                "poster":   "",
            }
            target_key = title
        sources, watch_url, tmdb = res
        # Replace the existing yflix sources/watch_url with ramoflix data.
        # Keep all other metadata (poster, backdrop, desc, etc.) intact.
        details[target_key]["sources"]   = sources
        details[target_key]["watch_url"] = watch_url
        details[target_key]["tmdb"]      = tmdb
        details[target_key]["source"]    = "ramoflix"
        results[target_key] = {
            "status":    "ok",
            "watch_url": watch_url,
            "tmdb":      tmdb,
            "n_sources": len(sources),
        }
        print(f"    -> wrote {len(sources)} sources")
        time.sleep(0.4)

    with open(DETAILS_PATH, "w", encoding="utf-8") as f:
        json.dump(details, f, ensure_ascii=False, indent=2)

    with open(SCRAPE_DUMP, "w", encoding="utf-8") as f:
        json.dump(results, f, ensure_ascii=False, indent=2)

    n_ok = sum(1 for v in results.values() if v.get("status") == "ok")
    n_no = sum(1 for v in results.values() if v.get("status") == "missing")
    print("---")
    print(f"ok: {n_ok}   missing: {n_no}   total: {len(results)}")


if __name__ == "__main__":
    main()

