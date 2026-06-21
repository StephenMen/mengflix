import json, re, sys, time, os, html as htmlmod, urllib.request, urllib.error

UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36"

base = r"C:\Users\mengxiang\Documents\MengFlix"
with open(os.path.join(base, "assets", "details.json"), "r", encoding="utf-8-sig") as f:
    details = json.load(f)

urls = [
  ("https://yflix.ws/movie/watch-015h35-the-devil-wears-prada-2-2026-hd", "The Devil Wears Prada 2"),
  ("https://yflix.ws/movie/watch-2syjd5-michael-2026-hd", "Michael"),
  ("https://yflix.ws/movie/watch-cc2qm9-swapped-2026-hd", "Swapped"),
  ("https://yflix.ws/movie/watch-sdris3-apex-2026-hd", "Apex"),
  ("https://yflix.ws/movie/watch-93wdkn-the-gates-2026-hd", "The Gates"),
  ("https://yflix.ws/movie/watch-gdszla-scream-7-2026-hd", "Scream 7"),
  ("https://yflix.ws/movie/watch-b0ej7t-send-help-2026-hd", "Send Help"),
  ("https://yflix.ws/movie/watch-bm1n3c-bad-men-must-bleed-2026-hd", "Bad Men Must Bleed"),
  ("https://yflix.ws/movie/watch-50qz7l-thrash-2026-hd", "Thrash"),
  ("https://yflix.ws/movie/watch-sqow5e-breaking-boundaries-2024-hd", "Breaking Boundaries"),
  ("https://yflix.ws/movie/watch-l0m1jf-bangalore-days-2014-hd", "Bangalore Days"),
  ("https://yflix.ws/movie/watch-a3th90-21-up-1977-hd", "21 Up"),
  ("https://yflix.ws/movie/watch-db8sla-baraka-1992-hd", "Baraka"),
  ("https://yflix.ws/movie/watch-ck9r80-gintama-the-final-chapter-be-forever-yorozuya-2013-hd", "Gintama: The Final Chapter: Be Forever Yorozuya"),
  ("https://yflix.ws/movie/watch-nd5sjc-grand-illusion-1937-hd", "Grand Illusion"),
  ("https://yflix.ws/movie/watch-akqmzf-gustaakh-ishq-2025-hd", "Gustaakh Ishq"),
  ("https://yflix.ws/movie/watch-nqstf6-hasan-minhaj-homecoming-king-2017-hd", "Hasan Minhaj: Homecoming King"),
  ("https://yflix.ws/movie/watch-hymzcg-aliens-expanded-2024-hd", "Aliens Expanded"),
  ("https://yflix.ws/movie/watch-hv5abn-the-three-deaths-of-marisela-escobedo-2020-hd", "The Three Deaths of Marisela Escobedo"),
  ("https://yflix.ws/movie/watch-b10wye-momentum-generation-2018-hd", "Momentum Generation"),
  ("https://yflix.ws/movie/watch-taf8r2-blossoms-back-to-stockport-2020-hd", "Blossoms: Back to Stockport"),
  ("https://yflix.ws/movie/watch-c2h769-the-lunatic-farmer-2025-hd", "The Lunatic Farmer"),
  ("https://yflix.ws/movie/watch-0ojfah-rivers-end-californias-latest-water-war-2021-hd", "River''s End: California''s Latest Water War"),
  ("https://yflix.ws/movie/watch-1kv6fg-racionais-mcs-from-the-streets-of-sao-paulo-2022-hd", "Racionais MC''s: From the Streets of Sao Paulo"),
  ("https://yflix.ws/movie/watch-ian4kz-rammstein-in-amerika-2015-hd", "Rammstein in Amerika"),
  ("https://yflix.ws/movie/watch-j91fzm-space-moms-2019-hd", "Space Moms"),
  ("https://yflix.ws/movie/watch-ki6dbu-seaspiracy-2021-hd", "Seaspiracy"),
  ("https://yflix.ws/movie/watch-gt19ke-chak-de-india-2007-hd", "Chak De! India"),
  ("https://yflix.ws/movie/watch-pky5ru-unicorn-town-2022-hd", "Unicorn Town"),
  ("https://yflix.ws/movie/watch-t42u07-the-big-city-1963-hd", "The Big City"),
]

def extract_sources(content):
    m = re.search(r'data-sources="([^"]+)"', content)
    if not m: return None
    raw = htmlmod.unescape(m.group(1))
    try:
        srcs = json.loads(raw)
        out = []
        for s in srcs:
            if isinstance(s, dict) and s.get("url"):
                out.append({"name": s.get("name", "Server"), "url": s["url"]})
        return out
    except Exception:
        return None

count_added = 0
for url, expected_title in urls:
    if expected_title not in details:
        print("SKIP", expected_title, "not in details.json")
        continue
    if details[expected_title].get("sources"):
        continue
    try:
        req = urllib.request.Request(url, headers={"User-Agent": UA})
        with urllib.request.urlopen(req, timeout=25) as r:
            content = r.read().decode("utf-8", errors="replace")
        sources = extract_sources(content)
        if sources:
            details[expected_title]["sources"] = sources
            details[expected_title]["watch_url"] = url
            count_added += 1
            print("OK ", expected_title, "->", len(sources), "servers")
        else:
            print("NO ", expected_title)
    except Exception as e:
        print("ERR", expected_title, e)
    time.sleep(0.3)

with open(os.path.join(base, "assets", "details.json"), "w", encoding="utf-8") as f:
    json.dump(details, f, ensure_ascii=False, indent=2)
print("---")
print("updated", count_added, "titles")
