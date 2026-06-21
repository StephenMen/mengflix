# Scrape yFlix welcome page movie detail pages and produce details.json + poster-map.json
$ErrorActionPreference = "Stop"

$urls = @(
  "https://yflix.ws/movie/watch-015h35-the-devil-wears-prada-2-2026-hd",
  "https://yflix.ws/movie/watch-2syjd5-michael-2026-hd",
  "https://yflix.ws/movie/watch-cc2qm9-swapped-2026-hd",
  "https://yflix.ws/movie/watch-sdris3-apex-2026-hd",
  "https://yflix.ws/movie/watch-93wdkn-the-gates-2026-hd",
  "https://yflix.ws/movie/watch-gdszla-scream-7-2026-hd",
  "https://yflix.ws/movie/watch-b0ej7t-send-help-2026-hd",
  "https://yflix.ws/movie/watch-bm1n3c-bad-men-must-bleed-2026-hd",
  "https://yflix.ws/movie/watch-50qz7l-thrash-2026-hd",
  "https://yflix.ws/movie/watch-sqow5e-breaking-boundaries-2024-hd",
  "https://yflix.ws/movie/watch-l0m1jf-bangalore-days-2014-hd",
  "https://yflix.ws/movie/watch-a3th90-21-up-1977-hd",
  "https://yflix.ws/movie/watch-db8sla-baraka-1992-hd",
  "https://yflix.ws/movie/watch-ck9r80-gintama-the-final-chapter-be-forever-yorozuya-2013-hd",
  "https://yflix.ws/movie/watch-nd5sjc-grand-illusion-1937-hd",
  "https://yflix.ws/movie/watch-akqmzf-gustaakh-ishq-2025-hd",
  "https://yflix.ws/movie/watch-nqstf6-hasan-minhaj-homecoming-king-2017-hd",
  "https://yflix.ws/movie/watch-hymzcg-aliens-expanded-2024-hd",
  "https://yflix.ws/movie/watch-hv5abn-the-three-deaths-of-marisela-escobedo-2020-hd",
  "https://yflix.ws/movie/watch-b10wye-momentum-generation-2018-hd",
  "https://yflix.ws/movie/watch-taf8r2-blossoms-back-to-stockport-2020-hd",
  "https://yflix.ws/movie/watch-c2h769-the-lunatic-farmer-2025-hd",
  "https://yflix.ws/movie/watch-0ojfah-rivers-end-californias-latest-water-war-2021-hd",
  "https://yflix.ws/movie/watch-1kv6fg-racionais-mcs-from-the-streets-of-sao-paulo-2022-hd",
  "https://yflix.ws/movie/watch-ian4kz-rammstein-in-amerika-2015-hd",
  "https://yflix.ws/movie/watch-j91fzm-space-moms-2019-hd",
  "https://yflix.ws/movie/watch-ki6dbu-seaspiracy-2021-hd",
  "https://yflix.ws/movie/watch-gt19ke-chak-de-india-2007-hd",
  "https://yflix.ws/movie/watch-pky5ru-unicorn-town-2022-hd",
  "https://yflix.ws/movie/watch-t42u07-the-big-city-1963-hd"
)

function Slug($s){ ($s.ToLower() -replace "[^a-z0-9]+","-" -replace "^-|-$","") }

function Extract($content){
  $title = ([regex]::Match($content, '<h1 class="detail-title"[^>]*>([^<]+)</h1>')).Groups[1].Value.Trim()
  $imdb  = ([regex]::Match($content, '<span class="badge badge-imdb"[^>]*>([^<]+)</span>')).Groups[1].Value.Trim()
  $desc  = ([regex]::Match($content, '<p class="detail-desc"[^>]*>([^<]+)</p>')).Groups[1].Value.Trim()
  $country = ([regex]::Match($content, '(?s)Country:</span>\s*<span class="detail-meta-value">\s*<a[^>]+>([^<]+)</a>')).Groups[1].Value.Trim()
  $released = ([regex]::Match($content, 'Released:</span>\s*<span class="detail-meta-value">([^<]+)</span>')).Groups[1].Value.Trim()
  $director = ([regex]::Match($content, '(?s)Director:</span>\s*<span class="detail-meta-value">\s*<a[^>]+>([^<]+)</a>')).Groups[1].Value.Trim()
  $castsRaw = ([regex]::Match($content, '(?s)Casts:</span>\s*<span class="detail-meta-value">(.*?)</span>')).Groups[1].Value
  $casts = (([regex]::Matches($castsRaw, '<a[^>]+>([^<]+)</a>') | ForEach-Object { $_.Groups[1].Value.Trim() }) -join ", ")
  $genresRaw = ([regex]::Match($content, '(?s)Genres:</span>\s*<span class="detail-meta-value">(.*?)</span>')).Groups[1].Value
  $genres = (([regex]::Matches($genresRaw, '<a[^>]+>([^<]+)</a>') | ForEach-Object { $_.Groups[1].Value.Trim() }) -join ", ")
  $trailer = ([regex]::Match($content, 'data-trailer="([^"]+)"')).Groups[1].Value
  $runtime = ([regex]::Match($content, '<span class="badge badge-genre"[^>]*>(\d+h \d+m)</span>')).Groups[1].Value
  $stars = [regex]::Matches($content, 'fill:#f5c518').Count
  $backdrop = ([regex]::Match($content, 'detail-backdrop-img[\s\S]*?<img src="([^"]+)"')).Groups[1].Value
  $poster   = ([regex]::Match($content, 'detail-poster[\s\S]*?<img src="([^"]+)"')).Groups[1].Value

  return [PSCustomObject]@{
    title = $title
    imdb = $imdb
    desc = $desc
    country = $country
    released = $released
    director = $director
    casts = $casts
    genres = $genres
    trailer = $trailer
    runtime = $runtime
    stars = $stars
    backdrop = $backdrop
    poster = $poster
  }
}

$details = [ordered]@{}
$posterMap = [ordered]@{}

foreach ($u in $urls) {
  try {
    $r = Invoke-WebRequest -Uri $u -Headers @{"User-Agent"="Mozilla/5.0"} -UseBasicParsing -TimeoutSec 25
    $d = Extract $r.Content
    if ($d.title) {
      $key = $d.title
      $details[$key] = $d
      $slug = Slug $key
      $posterMap[$slug] = $d.poster
      Write-Output ("OK  " + $key)
    } else { Write-Output ("NO  no title  " + $u) }
  } catch { Write-Output ("ERR " + $_.Exception.Message + "  " + $u) }
}

$details | ConvertTo-Json -Depth 6 | Set-Content "assets/details.json" -Encoding utf8
$posterMap | ConvertTo-Json -Depth 5 | Set-Content "assets/poster_map.json" -Encoding utf8
Write-Output ("---")
Write-Output ("details: " + $details.Count + "  posterMap: " + $posterMap.Count)
