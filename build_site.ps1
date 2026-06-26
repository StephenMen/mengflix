# Build MengFlix index.html from data + details.json + poster_map.json
$ErrorActionPreference = "Stop"

function Slug($s){ ($s.ToLower() -replace "[^a-z0-9]+","-" -replace "^-|-$","") }

# Load real poster map (yFlix posters)
$posterMap = @{}
if (Test-Path "assets/poster_map.json") {
  $raw = Get-Content "assets/poster_map.json" -Raw | ConvertFrom-Json
  foreach ($p in $raw.PSObject.Properties) {
    $key = $p.Name.Replace("&apos;","-").Replace("&amp;","&")
    $val = if ($p.Value -like "http*") { $p.Value } else { "https://yflix.ws$($p.Value)" }
    $posterMap[$key] = $val
  }
}
function Poster($t){
  $slug = Slug $t
  if ($posterMap.ContainsKey($slug)) { return $posterMap[$slug] }
  $webp = "assets/posters/$slug.webp"
  if (Test-Path $webp) { return $webp }
  return "assets/posters/$slug.svg"
}

# Backdrop map (mirror of poster for hero/detail panel, fallback to local SVG)
$backdropMap = @{
  "the-devil-wears-prada-2"   = "https://yflix.ws/images/backdrops/movies/the-devil-wears-prada-2-2026.webp"
  "swapped"                   = "https://yflix.ws/images/backdrops/movies/swapped-1-2026.webp"
  "michael"                  = "https://yflix.ws/images/backdrops/movies/michael-1-2026.webp"
  "apex"                      = "https://yflix.ws/images/backdrops/movies/apex-1-2026.webp"
  "the-gates"                 = "https://yflix.ws/images/backdrops/movies/the-gates-2026.webp"
  "scream-7"                  = "https://yflix.ws/images/backdrops/movies/scream-7-2026.webp"
  "send-help"                 = "https://yflix.ws/images/backdrops/movies/send-help-2026.webp"
  "bad-men-must-bleed"        = "https://yflix.ws/images/backdrops/movies/bad-men-must-bleed-2026.webp"
  "thrash"                    = "https://yflix.ws/images/backdrops/movies/thrash-2026.webp"
}
function Backdrop($t){
  $slug = Slug $t
  if ($backdropMap.ContainsKey($slug)) { return $backdropMap[$slug] }
  return "assets/backdrops/$slug.svg"
}

$slides = @(
  @{ title='The Devil Wears Prada 2'; year=2026; type='Movie'; imdb=8.3; minutes=119; genres=@('Drama','Comedy');
     desc='Miranda Priestly contemplates retirement and joins forces with Andy Sachs to confront a new rival: Emily Charlton.' },
  @{ title='Swapped'; year=2026; type='Movie'; imdb=8.8; minutes=102; genres=@('Animation','Adventure','Comedy','Family','Fantasy');
     desc='A tiny woodland creature and a majestic bird switch bodies, forming an unexpected alliance to survive.' },
  @{ title='Michael'; year=2026; type='Movie'; imdb=8.4; minutes=146; genres=@('Music','Drama','Biography');
     desc='A sweeping look at the man behind the sequined glove. The music, the myth, and the moonwalk that defined a generation.' },
  @{ title='Apex'; year=2026; type='Movie'; imdb=6.4; minutes=96; genres=@('Thriller','Action');
     desc='In the untamed Australian wilderness, a grieving woman on a solo expedition finds herself hunted by something not human.' },
  @{ title='The Gates'; year=2026; type='Movie'; imdb=6.4; minutes=110; genres=@('Thriller','Mystery');
     desc='A small town wakes to find its ancient cemetery empty. By sundown, the missing are no longer missing. They are watching.' },
  @{ title='Scream 7'; year=2026; type='Movie'; imdb=6.0; minutes=114; genres=@('Mystery','Crime','Horror');
     desc='A new Ghostface terrorizes a quiet town, targeting Sidney Prescott''s daughter.' }
)

$movies = @(
  @{t='The Devil Wears Prada 2'; y=2026; m=119; g='Drama'},
  @{t='Dune: Part Two'; y=2024; m=166; g='Sci-Fi'},
  @{t='Oppenheimer'; y=2023; m=180; g='Biography'},
  @{t='Poor Things'; y=2023; m=141; g='Comedy'},
  @{t='The Substance'; y=2024; m=141; g='Horror'},
  @{t='Anora'; y=2024; m=139; g='Drama'},
  @{t='Wicked'; y=2024; m=160; g='Fantasy'},
  @{t='Conclave'; y=2024; m=120; g='Thriller'},
  @{t='Nosferatu'; y=2024; m=132; g='Horror'},
  @{t='A Real Pain'; y=2024; m=90; g='Drama'},
  @{t='Gladiator II'; y=2024; m=148; g='Action'},
  @{t='Heretic'; y=2024; m=111; g='Thriller'},
  @{t='The Wild Robot'; y=2024; m=102; g='Animation'},
  @{t='Civil War'; y=2024; m=109; g='Action'},
  @{t='Hit Man'; y=2024; m=115; g='Comedy'},
  @{t='Love Lies Bleeding'; y=2024; m=104; g='Thriller'},
  @{t='Furiosa'; y=2024; m=148; g='Action'},
  @{t='Alien: Romulus'; y=2024; m=119; g='Sci-Fi'},
  @{t='It Ends With Us'; y=2024; m=130; g='Drama'},
  @{t='Beetlejuice B.'; y=2024; m=104; g='Comedy'},
  @{t='Joker: Folie 2'; y=2024; m=138; g='Drama'},
  @{t='Smile 2'; y=2024; m=118; g='Horror'},
  @{t='Terrifier 3'; y=2024; m=125; g='Horror'},
  @{t='Society of Snow'; y=2023; m=144; g='Drama'},
  @{t='The Holdovers'; y=2023; m=133; g='Drama'},
  @{t='Anatomy of a Fall'; y=2023; m=152; g='Drama'},
  @{t='Maestro'; y=2023; m=129; g='Biography'},
  @{t='May December'; y=2023; m=117; g='Drama'},
  @{t='Killers of F.M.'; y=2023; m=206; g='Crime'},
  @{t='Boy and Heron'; y=2023; m=124; g='Animation'},
  @{t='Past Lives'; y=2023; m=105; g='Romance'},
  @{t='Barbie'; y=2023; m=114; g='Comedy'},
  @{t='MI: Dead Reckoning'; y=2023; m=163; g='Action'},
  @{t='Spider-Verse 2'; y=2023; m=140; g='Animation'},
  @{t='GotG Vol. 3'; y=2023; m=150; g='Action'},
  @{t='John Wick 4'; y=2023; m=169; g='Action'},
  @{t='Sisu'; y=2023; m=91; g='Action'}
)

$tvs = @(
  @{t='Shogun'; y=2024; m=60; g='Drama'},
  @{t='The Penguin'; y=2024; m=60; g='Crime'},
  @{t='Severance'; y=2022; m=55; g='Sci-Fi'},
  @{t='The Bear'; y=2022; m=30; g='Drama'},
  @{t='House of the Dragon'; y=2022; m=60; g='Fantasy'},
  @{t='Andor'; y=2022; m=45; g='Sci-Fi'},
  @{t='The Last of Us'; y=2023; m=60; g='Drama'},
  @{t='Succession'; y=2018; m=60; g='Drama'},
  @{t='The White Lotus'; y=2021; m=60; g='Drama'},
  @{t='Reacher'; y=2022; m=60; g='Action'},
  @{t='Slow Horses'; y=2022; m=60; g='Thriller'},
  @{t='Morning Show'; y=2019; m=60; g='Drama'},
  @{t='Beef'; y=2023; m=35; g='Drama'},
  @{t='Wednesday'; y=2022; m=55; g='Comedy'},
  @{t='Stranger Things'; y=2016; m=55; g='Sci-Fi'},
  @{t='The Crown'; y=2016; m=60; g='Biography'},
  @{t='Peaky Blinders'; y=2013; m=60; g='Crime'},
  @{t='Better Call Saul'; y=2015; m=55; g='Crime'},
  @{t='Breaking Bad'; y=2008; m=50; g='Crime'},
  @{t='The Boys'; y=2019; m=60; g='Action'},
  @{t='Invincible'; y=2021; m=45; g='Animation'},
  @{t='Arcane'; y=2021; m=40; g='Animation'},
  @{t='One Piece'; y=2023; m=55; g='Action'},
  @{t='Fallout'; y=2024; m=60; g='Sci-Fi'},
  @{t='True Detective'; y=2014; m=55; g='Crime'},
  @{t='Fargo'; y=2014; m=55; g='Crime'},
  @{t='Fleabag'; y=2016; m=30; g='Comedy'},
  @{t='Chernobyl'; y=2019; m=60; g='Drama'}
)

function Card-HTML($item, $type) {
  $poster = Poster $item['t']
  $kind = if ($type -eq 'Movie') { 'Movie' } else { 'Series' }
@"
  <article class="content-card" itemscope itemtype="https://schema.org/$type" data-title="$($item['t'])" data-type="$type" data-poster="$poster" data-year="$($item['y'])" data-runtime="$($item['m'])" data-genre="$($item['g'])">
    <a href="#$($item['t'])" title="$($item['t'])" data-open>
      <div class="card-poster-wrap">
        <img src="$poster" alt="$($item['t'])" loading="lazy" decoding="async" width="342" height="513" itemprop="image">
        <div class="card-play-overlay" aria-hidden="true">
          <div class="card-play-icon">
            <svg viewBox="0 0 24 24" aria-hidden="true"><polygon points="5 3 19 12 5 21 5 3"/></svg>
          </div>
        </div>
        <div class="card-info-overlay">
          <h3 class="card-title" itemprop="name">$($item['t'])</h3>
          <div class="card-meta">
            <span>$kind</span>
            <span class="sep">&middot;</span>
            <time datetime="$($item['y'])" itemprop="datePublished">$($item['y'])</time>
            <span class="sep">&middot;</span>
            <span>$($item['m']) min</span>
          </div>
        </div>
      </div>
    </a>
  </article>
"@
}

function Slider-Section($id, $title, $items, $type) {
  $cards = ($items | ForEach-Object { Card-HTML $_ $type }) -join "`n"
@"
  <section class="section" id="$id" aria-labelledby="$id-title">
    <div class="container">
      <div class="section-header">
        <h2 class="section-title" id="$id-title">$title</h2>
        <a href="#" class="btn-view-all">View All
          <svg viewBox="0 0 24 24" width="14" height="14" aria-hidden="true"><polyline points="9 18 15 12 9 6" fill="none" stroke="currentColor" stroke-width="2.5"/></svg>
        </a>
      </div>
      <div class="slider-wrap">
        <button type="button" class="slider-btn slider-btn-prev" aria-label="Previous">
          <svg viewBox="0 0 24 24" width="20" height="20" aria-hidden="true"><polyline points="15 18 9 12 15 6" fill="none" stroke="currentColor" stroke-width="2"/></svg>
        </button>
        <div class="slider-track">
$cards
        </div>
        <button type="button" class="slider-btn slider-btn-next" aria-label="Next">
          <svg viewBox="0 0 24 24" width="20" height="20" aria-hidden="true"><polyline points="9 18 15 12 9 6" fill="none" stroke="currentColor" stroke-width="2"/></svg>
        </button>
      </div>
    </div>
  </section>
"@
}

# Slider-Section-Shell - outputs skeleton section with empty slider-track for dynamic loading
function Slider-Section-Shell($id, $title) {
@"
  <section class="section" id="$id" aria-labelledby="$id-title">
    <div class="container">
      <div class="section-header">
        <h2 class="section-title" id="$id-title">$title</h2>
        <a href="#" class="btn-view-all">View All
          <svg viewBox="0 0 24 24" width="14" height="14" aria-hidden="true"><polyline points="9 18 15 12 9 6" fill="none" stroke="currentColor" stroke-width="2.5"/></svg>
        </a>
      </div>
      <div class="slider-wrap">
        <button type="button" class="slider-btn slider-btn-prev" aria-label="Previous">
          <svg viewBox="0 0 24 24" width="20" height="20" aria-hidden="true"><polyline points="15 18 9 12 15 6" fill="none" stroke="currentColor" stroke-width="2"/></svg>
        </button>
        <div class="slider-track">
          <!-- skeleton cards loaded dynamically from cards.json -->
        </div>
        <button type="button" class="slider-btn slider-btn-next" aria-label="Next">
          <svg viewBox="0 0 24 24" width="20" height="20" aria-hidden="true"><polyline points="9 18 15 12 9 6" fill="none" stroke="currentColor" stroke-width="2"/></svg>
        </button>
      </div>
    </div>
  </section>
"@
}

$heroSlides = ($slides | ForEach-Object { $i = $slides.IndexOf($_); $active = if ($i -eq 0) { ' active' } else { '' }
$bg = Backdrop $_.title
$poster = Poster $_.title
@"
        <div class="yf-hero-slide$active" data-idx="$i" style="--bg:url('$bg')">
          <div class="yf-hero-backdrop"></div>
          <div class="yf-hero-content">
            <div class="yf-hero-badges">
              <a class="badge badge-type" href="#">$($_.type)</a>
              $( $_.genres | ForEach-Object { "<a class=`"badge badge-genre`" href=`"#`">$_</a>" } )
              <a class="badge badge-imdb" href="#">&starf; $($_.imdb.ToString('0.0'))</a>
            </div>
            <h2 class="yf-hero-title">$($_.title)</h2>
            <div class="yf-hero-info">
              <span>$($_.year)</span><span class="dot"></span><span>$($_.minutes) min</span><span class="dot"></span><span class="quality">HD</span>
            </div>
            <p class="yf-hero-desc">$($_.desc)</p>
            <div class="yf-hero-actions">
              <a href="#" class="btn-play-circle" aria-label="Play $($_.title)" data-open data-title="$($_.title)" data-type="Movie" data-poster="$poster" data-year="$($_.year)" data-runtime="$($_.minutes)">
                <span class="play-circle-outer"><span class="play-circle-inner">
                  <svg viewBox="0 0 24 24" aria-hidden="true"><polygon points="6 4 20 12 6 20 6 4"/></svg>
                </span></span>
                <span class="play-circle-label"><span>Play Now</span><small>Stream in HD</small></span>
              </a>
              <a href="#" class="btn-secondary-circle" aria-label="More info" data-open data-title="$($_.title)" data-type="Movie" data-poster="$poster" data-year="$($_.year)" data-runtime="$($_.minutes)">
                <svg viewBox="0 0 24 24" width="20" height="20" aria-hidden="true"><circle cx="12" cy="12" r="10" fill="none" stroke="currentColor" stroke-width="2"/><line x1="12" y1="16" x2="12" y2="12" stroke="currentColor" stroke-width="2" stroke-linecap="round"/><line x1="12" y1="8" x2="12.01" y2="8" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>
              </a>
            </div>
          </div>
        </div>
"@ }) -join "`n"

$heroDots = ($slides | ForEach-Object { $i = $slides.IndexOf($_); $active = if ($i -eq 0) { ' active' } else { '' }
"<button class=`"yf-hero-dot$active`" data-go=`"$i`" aria-label=`"Go to slide $($i+1)`"></button>" }) -join "`n"

# ============================================================
# Build JSON data for dynamic card loading (cards.json + search_index.json)
# ============================================================
$sectionData = @{}
$sectionData["latest-movies"] = $movies | Select-Object -First 14 | ForEach-Object {
  @{ title=$_.t; type='Movie'; poster=(Poster $_.t); year=[int]$_.y; runtime=[int]$_.m; genre=$_.g }
}
$sectionData["trending"] = $movies | Select-Object -Skip 6 -First 14 | ForEach-Object {
  @{ title=$_.t; type='Movie'; poster=(Poster $_.t); year=[int]$_.y; runtime=[int]$_.m; genre=$_.g }
}
$sectionData["top-rated"] = $movies | Select-Object -Skip 10 -First 14 | ForEach-Object {
  @{ title=$_.t; type='Movie'; poster=(Poster $_.t); year=[int]$_.y; runtime=[int]$_.m; genre=$_.g }
}
$sectionData["latest-series"] = $tvs | Select-Object -First 14 | ForEach-Object {
  @{ title=$_.t; type='TVSeries'; poster=(Poster $_.t); year=[int]$_.y; runtime=[int]$_.m; genre=$_.g }
}
$sectionData["web-series"] = $tvs | Select-Object -Skip 6 -First 14 | ForEach-Object {
  @{ title=$_.t; type='TVSeries'; poster=(Poster $_.t); year=[int]$_.y; runtime=[int]$_.m; genre=$_.g }
}
$sectionData["binge"] = $tvs | Select-Object -Skip 12 -First 14 | ForEach-Object {
  @{ title=$_.t; type='TVSeries'; poster=(Poster $_.t); year=[int]$_.y; runtime=[int]$_.m; genre=$_.g }
}

# Export cards.json
$cardsJsonPath = (Resolve-Path "assets").Path + '\cards.json'
$cardsJson = $sectionData | ConvertTo-Json -Depth 3 -Compress
[System.IO.File]::WriteAllText($cardsJsonPath, $cardsJson, [System.Text.UTF8Encoding]::new($false))
Write-Output ("cards.json bytes: " + (Get-Item "assets/cards.json").Length)

# Export search_index.json (flat array of all cards)
$searchIndex = @()
$sectionData.Keys | ForEach-Object {
  $sid = $_
  $sectionData[$sid] | ForEach-Object {
    $searchIndex += $_
  }
}
# Add donghua to search index
$donghuaData = @{}
if (Test-Path "assets/donghua.json") {
  try { $donghuaData = Get-Content "assets/donghua.json" -Raw | ConvertFrom-Json } catch {}
}
$donghuaData.PSObject.Properties | ForEach-Object {
  $key = $_.Name
  $d = $_.Value
  $searchIndex += @{
    title = $key
    type = 'Donghua'
    poster = if ($d.poster) { $d.poster } else { "assets/posters/$(Slug $key).svg" }
    year = if ($d.year) { [int]$d.year } else { 0 }
    runtime = 0
    genre = if ($d.genres) { $d.genres } else { '' }
  }
}
$searchJsonPath = (Resolve-Path "assets").Path + '\search_index.json'
$searchJson = $searchIndex | ConvertTo-Json -Depth 3 -Compress
[System.IO.File]::WriteAllText($searchJsonPath, $searchJson, [System.Text.UTF8Encoding]::new($false))
Write-Output ("search_index.json bytes: " + (Get-Item "assets/search_index.json").Length)

# Export full movies + tvs array for View All
$fullData = @{
  movies = $movies | ForEach-Object { @{ title=$_.t; type='Movie'; poster=(Poster $_.t); year=[int]$_.y; runtime=[int]$_.m; genre=$_.g } }
  tvs = $tvs | ForEach-Object { @{ title=$_.t; type='TVSeries'; poster=(Poster $_.t); year=[int]$_.y; runtime=[int]$_.m; genre=$_.g } }
}
$fullJsonPath = (Resolve-Path "assets").Path + '\full_data.json'
$fullJson = $fullData | ConvertTo-Json -Depth 3 -Compress
[System.IO.File]::WriteAllText($fullJsonPath, $fullJson, [System.Text.UTF8Encoding]::new($false))
Write-Output ("full_data.json bytes: " + (Get-Item "assets/full_data.json").Length)

# ============================================================
# Build main HTML template
# ============================================================
$html = @"
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>MengFlix &mdash; Free Movies &amp; TV Series Online HD</title>
<meta name="description" content="MengFlix is your platform for free HD movies and TV series. Discover trending titles, new releases, and binge-worthy shows with smooth streaming.">
<link rel="icon" type="image/svg+xml" href="assets/img/favicon.svg">
<link rel="stylesheet" href="assets/css/styles.css">
</head>
<body class="page-home">
  <div class="bg-3d" aria-hidden="true">
    <div class="bg-blob bg-blob-1"></div>
    <div class="bg-blob bg-blob-2"></div>
    <div class="bg-blob bg-blob-3"></div>
    <div class="bg-grid"></div>
  </div>

  <a href="#main-content" class="skip-link">Skip to main content</a>

  <header class="site-header" id="siteHeader">
    <div class="container header-inner">
      <a href="#" class="site-logo" aria-label="MengFlix">
        <span class="logo-mark" aria-hidden="true">
          <span class="logo-mark-m">M</span><span class="logo-mark-flix">FLIX</span>
        </span>
        <span class="logo-text">MengFlix</span>
      </a>
      <nav class="header-left main-nav-desktop" aria-label="Primary">
        <a href="#" class="nav-home-link active">Home</a>
        <div class="browse-dropdown">
          <button class="btn-browse" aria-haspopup="true" aria-expanded="false">
            <span>Browse</span>
            <svg viewBox="0 0 24 24" width="14" height="14" aria-hidden="true"><polyline points="6 9 12 15 18 9" fill="none" stroke="currentColor" stroke-width="2.4"/></svg>
          </button>
          <div class="browse-dropdown-menu" role="menu">
            <a href="#latest-movies" class="browse-item">Movies</a>
            <a href="#latest-series" class="browse-item">TV Shows</a>
            <a href="#trending" class="browse-item">Trending</a>
            <a href="#top-rated" class="browse-item">Top Rated</a>
          </div>
        </div>
        <a href="#latest-movies">Movies</a>
        <a href="#latest-series">TV Shows</a>
      </nav>
      <div class="header-right">
        <button type="button" class="nav-search-link" id="searchOpenBtn" aria-label="Search">
          <svg viewBox="0 0 24 24" width="20" height="20" aria-hidden="true"><circle cx="11" cy="11" r="7" fill="none" stroke="currentColor" stroke-width="2"/><line x1="21" y1="21" x2="16.65" y2="16.65" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>
        </button>
        <a href="#" class="btn-signin">Sign In</a>
        <button type="button" class="mobile-menu-toggle" id="mobileMenuBtn" aria-label="Toggle navigation" aria-expanded="false" aria-controls="mobileMenu">
          <span></span><span></span><span></span>
        </button>
      </div>
    </div>
    <div class="mobile-menu" id="mobileMenu" hidden>
      <nav class="mobile-menu-nav" aria-label="Mobile">
        <a href="#" class="mobile-menu-link">Home</a>
        <a href="#latest-movies" class="mobile-menu-link">Movies</a>
        <a href="#latest-series" class="mobile-menu-link">TV Shows</a>
        <a href="#trending" class="mobile-menu-link">Trending</a>
        <a href="#top-rated" class="mobile-menu-link">Top Rated</a>
      </nav>
      <form class="mobile-search" role="search" onsubmit="event.preventDefault();">
        <input type="search" placeholder="Search movies, shows&hellip;">
        <button type="submit" aria-label="Search">
          <svg viewBox="0 0 24 24" width="18" height="18" aria-hidden="true"><circle cx="11" cy="11" r="7" fill="none" stroke="currentColor" stroke-width="2"/><line x1="21" y1="21" x2="16.65" y2="16.65" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>
        </button>
      </form>
    </div>
  </header>

  <main id="main-content">

  <section class="yf-hero" aria-label="Featured content">
    <div class="yf-hero-slides" id="heroSlides">
$heroSlides
    </div>
    <button type="button" id="heroPrev" class="yf-hero-nav-btn yf-hero-nav-btn--prev" aria-label="Previous slide">
      <svg viewBox="0 0 24 24" width="22" height="22" aria-hidden="true"><polyline points="15 18 9 12 15 6" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"/></svg>
    </button>
    <button type="button" id="heroNext" class="yf-hero-nav-btn yf-hero-nav-btn--next" aria-label="Next slide">
      <svg viewBox="0 0 24 24" width="22" height="22" aria-hidden="true"><polyline points="9 18 15 12 9 6" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"/></svg>
    </button>
    <div class="yf-hero-dots" role="tablist">
$heroDots
    </div>
  </section>

  <section class="intro" aria-label="Welcome">
    <div class="container">
      <div class="intro-card">
        <div class="intro-eyebrow">Welcome to MengFlix</div>
        <h1 class="intro-title">Free Movies and TV Shows to Stream</h1>
        <p>Discover trending titles, new releases, and binge-worthy series &mdash; all in crisp HD, no sign-up required.</p>
      </div>
    </div>
  </section>

$( Slider-Section-Shell 'latest-movies' 'Latest Movies' )

$( Slider-Section-Shell 'trending' 'Trending Now' )

$( Slider-Section-Shell 'top-rated' 'Top Rated' )

$( Slider-Section-Shell 'latest-series' 'Latest TV Series' )

$( Slider-Section-Shell 'web-series' 'Web Series' )

$( Slider-Section-Shell 'binge' 'Binge-Worthy Series' )

$( Slider-Section-Shell 'donghua' 'Donghua' )

  </main>

  <footer class="site-footer">
    <div class="footer-top">
      <div class="footer-logo-row">
        <div class="footer-line footer-line--left"></div>
        <a href="#" class="footer-logo-btn" aria-label="MengFlix">
          <span class="footer-mark" aria-hidden="true">
            <span class="footer-mark-m">M</span><span class="footer-mark-flix">FLIX</span>
          </span>
        </a>
        <div class="footer-line footer-line--right"></div>
      </div>
      <p class="footer-desc">
        <strong>MengFlix</strong> is your destination to watch free HD movies and stream premium TV series online. A curated library of trending titles, new releases, and binge-worthy shows &mdash; zero ads, zero sign-ups.
      </p>
    </div>
    <div class="footer-bottom-bar">
      <span class="footer-copy">&copy; 2026 MengFlix</span>
      <p class="footer-legal">MengFlix is a demo UI. All artwork is sourced from yFlix (yflix.ws) and TMDb; no media is hosted. Built as a portfolio piece.</p>
      <nav class="footer-nav" aria-label="Footer links">
        <a href="#">Request Content</a>
        <a href="#">DMCA</a>
        <a href="#">Contact</a>
      </nav>
    </div>
  </footer>

  <div class="search-overlay" id="searchOverlay" hidden>
    <div class="search-overlay-backdrop" data-close></div>
    <div class="search-overlay-body" role="dialog" aria-modal="true" aria-label="Search">
      <button type="button" class="search-overlay-close" id="searchCloseBtn" aria-label="Close search">
        <svg viewBox="0 0 24 24" width="20" height="20" aria-hidden="true"><line x1="6" y1="6" x2="18" y2="18" stroke="currentColor" stroke-width="2" stroke-linecap="round"/><line x1="18" y1="6" x2="6" y2="18" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>
      </button>
      <form class="search-overlay-form" onsubmit="event.preventDefault();">
        <span class="search-overlay-icon" aria-hidden="true">
          <svg viewBox="0 0 24 24" width="22" height="22"><circle cx="11" cy="11" r="7" fill="none" stroke="currentColor" stroke-width="2"/><line x1="21" y1="21" x2="16.65" y2="16.65" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>
        </span>
        <span class="search-overlay-input-wrap">
          <input type="search" class="search-overlay-input" placeholder="Search for a movie, show, or genre&hellip;" autofocus>
        </span>
      </form>
      <p class="search-overlay-hint">Try &ldquo;Dune&rdquo;, &ldquo;Shogun&rdquo;, or &ldquo;Comedy&rdquo;. Press <kbd>Esc</kbd> to close.</p>
    </div>
  </div>

  <div class="detail-overlay" id="detailOverlay" hidden aria-hidden="true">
    <div class="detail-backdrop-img" id="detailBackdrop" aria-hidden="true"></div>
    <div class="detail-overlay-bg" data-close></div>
    <div class="detail-panel" role="dialog" aria-modal="true" aria-labelledby="detailTitle" tabindex="-1">
      <button type="button" class="detail-close" id="detailClose" aria-label="Close details" data-close>
        <svg viewBox="0 0 24 24" width="20" height="20" aria-hidden="true"><line x1="6" y1="6" x2="18" y2="18" stroke="currentColor" stroke-width="2" stroke-linecap="round"/><line x1="18" y1="6" x2="6" y2="18" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>
      </button>
      <div class="detail-layout">
        <div class="detail-poster-wrap">
          <img class="detail-poster" id="detailPoster" alt="" loading="lazy" decoding="async">
        </div>
        <div class="detail-info">
          <nav class="detail-breadcrumbs" aria-label="Breadcrumb">
            <a href="#" data-close>Home</a>
            <span class="sep" aria-hidden="true">/</span>
            <a href="#latest-movies" data-close id="detailCrumbType">Movies</a>
            <span class="sep" aria-hidden="true">/</span>
            <span class="current" id="detailCrumbTitle">&hellip;</span>
          </nav>
          <h1 class="detail-title" id="detailTitle">&hellip;</h1>
          <div class="detail-badges" id="detailBadges"></div>
          <p class="detail-desc" id="detailDesc"></p>
          <div class="detail-meta-grid" id="detailMeta"></div>
          <div class="detail-actions">
            <a href="#" class="detail-action-play" id="detailPlay" aria-label="Play">
              <span class="play-circle-outer"><span class="play-circle-inner">
                <svg viewBox="0 0 24 24" aria-hidden="true"><polygon points="6 4 20 12 6 20 6 4"/></svg>
              </span></span>
              <span class="play-circle-label"><span>Play Now</span><small>Stream in HD</small></span>
            </a>
            <a href="#" class="detail-action-trailer" id="detailTrailer" target="_blank" rel="noopener" aria-label="Watch trailer">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><polygon points="23 7 16 12 23 17 23 7"/><rect x="1" y="5" width="15" height="14" rx="2" ry="2"/></svg>
              <span>Watch Trailer</span>
            </a>
            <button type="button" class="detail-action-icon" id="detailFav" aria-label="Add to favorites">
              <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
            </button>
            <button type="button" class="detail-action-icon" id="detailShare" aria-label="Share">
              <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><circle cx="18" cy="5" r="3"/><circle cx="6" cy="12" r="3"/><circle cx="18" cy="19" r="3"/><line x1="8.59" y1="13.51" x2="15.42" y2="17.49"/><line x1="15.41" y1="6.51" x2="8.59" y2="10.49"/></svg>
            </button>
            <div class="detail-stars" id="detailStars" aria-label="Rating"></div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- Player Overlay -->
  <div class="player-overlay" id="playerOverlay" hidden aria-hidden="true">
    <div class="player-overlay-bg" data-close></div>
    <div class="player-panel" id="playerPanel" role="dialog" aria-modal="true" aria-labelledby="playerTitle" tabindex="-1">
      <button type="button" class="player-close" id="playerClose" aria-label="Close player" data-close>
        <svg viewBox="0 0 24 24" width="20" height="20" aria-hidden="true"><line x1="6" y1="6" x2="18" y2="18" stroke="currentColor" stroke-width="2" stroke-linecap="round"/><line x1="18" y1="6" x2="6" y2="18" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>
      </button>
      <nav class="player-breadcrumbs" aria-label="Breadcrumb">
        <a href="#" data-close>Home</a>
        <span class="sep" aria-hidden="true">/</span>
        <a href="#" data-close id="playerCrumbType">Movies</a>
        <span class="sep" aria-hidden="true">/</span>
        <span class="current" id="playerCrumbTitle">&hellip;</span>
      </nav>
      <h2 class="player-title" id="playerTitle">&hellip;</h2>
      <div class="player-layout">
        <div class="player-video-wrap">
          <div class="player-placeholder" id="playerPlaceholder">
            <div class="player-placeholder-icon">
              <svg viewBox="0 0 24 24" width="48" height="48" aria-hidden="true"><polygon points="6 4 20 12 6 20 6 4" fill="currentColor"/></svg>
            </div>
            <p class="player-placeholder-text">Select a server to start streaming</p>
          </div>
          <iframe class="player-frame" id="playerFrame" allowfullscreen allow="autoplay; encrypted-media" sandbox="allow-scripts allow-same-origin allow-forms allow-popups" loading="lazy"></iframe>
        </div>
        <div class="player-sidebar">
          <div class="player-servers" id="playerServers">
            <h3 class="player-servers-title">Servers</h3>
            <p class="player-servers-empty">Loading server options&hellip;</p>
          </div>
          <div class="player-episodes" id="playerEpisodes" hidden>
            <h3 class="player-episodes-title">Episodes <span class="episode-count" id="episodeCount"></span></h3>
            <div class="episode-grid" id="episodeGrid"></div>
          </div>
          <div class="player-hint" id="playerHint">
            If the player doesn't load, try a different server or
            <a href="#" id="playerWatchLink" target="_blank" rel="noopener" style="display:none">open in a new tab</a>.
          </div>
        </div>
      </div>
    </div>
  </div>

  <script src="assets/js/main.js" defer></script>
  <script src="assets/js/episodes.js" defer></script>
  <script>
  /* Fallback: sign-in toast */
  (function(){
    var btn = document.getElementById('signInBtn');
    if (btn) btn.addEventListener('click', function(e){
      e.preventDefault();
      var t = document.createElement('div');
      t.className = 'mf-toast'; t.setAttribute('role', 'status');
      t.textContent = 'Sign in is coming soon. Stay tuned!';
      document.body.appendChild(t);
      requestAnimationFrame(function(){ t.classList.add('mf-toast-visible'); });
      setTimeout(function(){ t.classList.remove('mf-toast-visible'); setTimeout(function(){ t.remove(); }, 300); }, 2500);
    });
  })();

  /* View All: show full grid of all items in category */
  var _viewMode = false;
  document.addEventListener('click', function(e) {
    var btn = e.target.closest('.btn-view-all');
    if (!btn) return;
    e.preventDefault();
    var section = btn.closest('.section');
    if (!section) return;
    var id = section.id;
    _viewMode = true;
    var sections = document.querySelectorAll('.section');
    sections.forEach(function(s) { if (s.id !== id) s.style.display = 'none'; });
    /* Expand this section to show all items in full grid */
    var track = section.querySelector('.slider-track');
    if (track) {
      track.style.display = 'grid';
      track.style.gridTemplateColumns = 'repeat(auto-fill, minmax(160px, 1fr))';
      track.style.gridAutoFlow = 'row';
      track.style.overflow = 'visible';
      track.style.maxHeight = 'none';
      track.style.scrollSnapType = 'none';
      track.style.cursor = 'auto';
    }
    section.style.maxWidth = 'none';
    section.style.padding = '28px 28px 60px';
    /* Remove slider buttons */
    var btns = section.querySelectorAll('.slider-btn');
    btns.forEach(function(b) { b.style.display = 'none'; });
    /* Add back button */
    var existingBack = section.querySelector('.view-all-back');
    if (!existingBack) {
      var back = document.createElement('a');
      back.href = '#';
      back.className = 'view-all-back';
      back.style.cssText = 'display:inline-flex;align-items:center;gap:8px;padding:8px 16px;border-radius:999px;background:var(--surface);box-shadow:0 4px 12px rgba(0,0,0,0.08);font-size:13px;font-weight:700;margin-bottom:18px;margin-right:12px';
      back.innerHTML = '<svg viewBox="0 0 24 24" width="16" height="16"><polyline points="15 18 9 12 15 6" fill="none" stroke="currentColor" stroke-width="2.5"/></svg> Back';
      var header = section.querySelector('.section-header');
      if (header) header.prepend(back);
      back.addEventListener('click', function(ev) {
        ev.preventDefault();
        _viewMode = false;
        sections.forEach(function(s) { s.style.display = ''; });
        if (track) {
          track.style.display = '';
          track.style.gridTemplateColumns = '';
          track.style.gridAutoFlow = '';
          track.style.overflow = '';
          track.style.maxHeight = '';
          track.style.scrollSnapType = '';
          track.style.cursor = '';
        }
        section.style.maxWidth = '';
        section.style.padding = '';
        btns.forEach(function(b) { b.style.display = ''; });
        back.remove();
        /* Reload cards */
        if (typeof loadAndRenderCards === 'function') loadAndRenderCards();
      });
    }
    /* Load more items from full_data.json */
    var header2 = section.querySelector('.section-header');
    if (!header2 || header2.dataset.fullLoaded) return;
    header2.dataset.fullLoaded = '1';
    fetch('assets/full_data.json').then(function(r) { return r.json(); }).then(function(data) {
      var allItems = [];
      if (id === 'latest-movies' || id === 'trending' || id === 'top-rated') allItems = data.movies || [];
      else if (id === 'latest-series' || id === 'web-series' || id === 'binge') allItems = data.tvs || [];
      if (allItems.length === 0) return;
      if (track) {
        track.innerHTML = '';
        allItems.forEach(function(item) {
          var art = document.createElement('article');
          art.className = 'content-card';
          art.setAttribute('data-title', item.title);
          art.setAttribute('data-type', item.type);
          art.setAttribute('data-poster', item.poster);
          art.setAttribute('data-year', String(item.year));
          art.setAttribute('data-runtime', String(item.runtime));
          art.setAttribute('data-genre', item.genre);
          var label = item.type === 'TVSeries' ? 'Series' : 'Movie';
          art.innerHTML = '<a href="#" title="' + item.title.replace(/"/g,'&quot;') + '" data-open>' +
            '<div class="card-poster-wrap">' +
            '<img src="' + item.poster.replace(/"/g,'&quot;') + '" alt="' + item.title.replace(/"/g,'&quot;') + '" loading="lazy" decoding="async" width="342" height="513">' +
            '<div class="card-play-overlay"><div class="card-play-icon"><svg viewBox="0 0 24 24"><polygon points="5 3 19 12 5 21 5 3"/></svg></div></div>' +
            '<div class="card-info-overlay"><h3 class="card-title">' + item.title.replace(/</g,'&lt;') + '</h3>' +
            '<div class="card-meta"><span>' + label + '</span><span class="sep">&middot;</span><span>' + item.year + '</span></div></div></div></a>';
          track.appendChild(art);
        });
      }
    }).catch(function(){});
  });
  </script>
</body>
</html>
"@

[System.IO.File]::WriteAllText((Resolve-Path .).Path + '\index.html', $html, [System.Text.UTF8Encoding]::new($false))
Write-Output ("index.html bytes: " + (Get-Item index.html).Length)

# Minify
Write-Output "`nMinifying..."
& python minify.py