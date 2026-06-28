#!/usr/bin/env python3
"""MengFlix server with fuzzy search API."""

import http.server
import json
import os
import mimetypes
import urllib.parse
import difflib
import re

ROOT = os.path.dirname(os.path.abspath(__file__))

SEARCH_INDEX = []
try:
    with open(os.path.join(ROOT, 'assets', 'search_index.json'), encoding='utf-8') as f:
        SEARCH_INDEX = json.load(f)
except Exception:
    pass

FULL_LOOKUP = {}
try:
    with open(os.path.join(ROOT, 'assets', 'full_data.json'), encoding='utf-8') as f:
        fd = json.load(f)
        for cat in ('movies', 'tvs'):
            for item in fd.get(cat, []):
                title = (item.get('title') or '').strip().lower()
                if title:
                    FULL_LOOKUP[title] = item
except Exception:
    pass


def fuzzy_search(query: str, limit: int = 20):
    q = query.strip().lower()
    if not q or len(q) < 1:
        return []
    results = []
    seen_titles = set()
    for item in SEARCH_INDEX:
        title = (item.get('title') or '').strip()
        title_lower = title.lower()
        genre = (item.get('genre') or '').lower()
        year = str(item.get('year') or '')
        if title_lower in seen_titles:
            continue
        score = 0.0
        if title_lower == q:
            score = 1000.0
        elif title_lower.startswith(q):
            score = 800.0 - (len(title_lower) - len(q)) * 0.5
        elif any(word.startswith(q) for word in title_lower.split()):
            score = 600.0
        elif q in title_lower:
            score = 400.0 - title_lower.index(q) * 0.3
        else:
            ratio = difflib.SequenceMatcher(None, q, title_lower).ratio()
            if ratio > 0.35:
                score = ratio * 300.0
            else:
                words = re.split(r'[\s:;,./\-()]+', title_lower)
                best_partial = max(
                    (difflib.SequenceMatcher(None, q, w).ratio() for w in words if w),
                    default=0.0
                )
                if best_partial > 0.4:
                    score = best_partial * 250.0
                elif q in genre:
                    score = 200.0
                elif q in year:
                    score = 150.0
                else:
                    continue
        seen_titles.add(title_lower)
        enriched = dict(item)
        if title_lower in FULL_LOOKUP:
            enriched.update(FULL_LOOKUP[title_lower])
        results.append((score, enriched))
    results.sort(key=lambda x: -x[0])
    return [r[1] for r in results[:limit]]


class MengFlixHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path
        params = urllib.parse.parse_qs(parsed.query)
        if path == '/api/search':
            q = params.get('q', [''])[0]
            results = fuzzy_search(q)
            self.send_response(200)
            self.send_header('Content-Type', 'application/json; charset=utf-8')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.send_header('Cache-Control', 'no-cache')
            self.end_headers()
            self.wfile.write(json.dumps(results, ensure_ascii=False).encode('utf-8'))
            return
        file_path = os.path.join(ROOT, path.lstrip('/') if path != '/' else 'index.html')
        file_path = file_path.split('?')[0]
        if not os.path.isfile(file_path):
            self.send_response(404)
            self.send_header('Content-Type', 'text/plain')
            self.end_headers()
            self.wfile.write(b'404 Not Found')
            return
        ext = os.path.splitext(file_path)[1].lower()
        mime_map = {
            '.js': 'text/javascript',
            '.css': 'text/css',
            '.json': 'application/json',
            '.svg': 'image/svg+xml',
            '.png': 'image/png',
            '.jpg': 'image/jpeg',
            '.jpeg': 'image/jpeg',
            '.webp': 'image/webp',
            '.ico': 'image/x-icon',
            '.html': 'text/html',
        }
        mime_type = mime_map.get(ext, 'application/octet-stream')
        try:
            with open(file_path, 'rb') as f:
                data = f.read()
            self.send_response(200)
            ct = f'{mime_type}; charset=utf-8' if mime_type.startswith('text/') else mime_type
            self.send_header('Content-Type', ct)
            self.send_header('Permissions-Policy', 'popups=(),fullscreen=*,clipboard-write=(),window-management=()')
            self.send_header('Cache-Control', 'no-cache')
            self.end_headers()
            self.wfile.write(data)
        except Exception as e:
            self.send_response(500)
            self.send_header('Content-Type', 'text/plain')
            self.end_headers()
            self.wfile.write(f'500 {e}'.encode())


if __name__ == '__main__':
    PORT = 8081
    print(f'MengFlix server at http://localhost:{PORT}')
    http.server.HTTPServer(('', PORT), MengFlixHandler).serve_forever()
