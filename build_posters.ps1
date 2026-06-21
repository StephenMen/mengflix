# Generate per-movie SVG posters and save under assets/posters
$ErrorActionPreference = "Stop"

$movies = @(
  @{t='The Brutalist'; g='Drama'},
  @{t='Dune: Part Two'; g='Sci-Fi'},
  @{t='Oppenheimer'; g='Biography'},
  @{t='Poor Things'; g='Comedy'},
  @{t='The Substance'; g='Horror'},
  @{t='Anora'; g='Drama'},
  @{t='Wicked'; g='Fantasy'},
  @{t='Conclave'; g='Thriller'},
  @{t='Nosferatu'; g='Horror'},
  @{t='A Real Pain'; g='Drama'},
  @{t='Gladiator II'; g='Action'},
  @{t='Heretic'; g='Thriller'},
  @{t='The Wild Robot'; g='Animation'},
  @{t='Civil War'; g='Action'},
  @{t='Hit Man'; g='Comedy'},
  @{t='Love Lies Bleeding'; g='Thriller'},
  @{t='Furiosa'; g='Action'},
  @{t='Alien: Romulus'; g='Sci-Fi'},
  @{t='It Ends With Us'; g='Drama'},
  @{t='Beetlejuice B.'; g='Comedy'},
  @{t='Joker: Folie 2'; g='Drama'},
  @{t='Smile 2'; g='Horror'},
  @{t='Terrifier 3'; g='Horror'},
  @{t='Society of Snow'; g='Drama'},
  @{t='The Holdovers'; g='Drama'},
  @{t='Anatomy of a Fall'; g='Drama'},
  @{t='Maestro'; g='Biography'},
  @{t='May December'; g='Drama'},
  @{t='Killers of F.M.'; g='Crime'},
  @{t='Boy and Heron'; g='Animation'},
  @{t='Past Lives'; g='Romance'},
  @{t='Barbie'; g='Comedy'},
  @{t='MI: Dead Reckoning'; g='Action'},
  @{t='Spider-Verse 2'; g='Animation'},
  @{t='GotG Vol. 3'; g='Action'},
  @{t='John Wick 4'; g='Action'},
  @{t='Sisu'; g='Action'}
)

$tvs = @(
  @{t='Shogun'; g='Drama'},
  @{t='The Penguin'; g='Crime'},
  @{t='Severance'; g='Sci-Fi'},
  @{t='The Bear'; g='Drama'},
  @{t='House of the Dragon'; g='Fantasy'},
  @{t='Andor'; g='Sci-Fi'},
  @{t='The Last of Us'; g='Drama'},
  @{t='Succession'; g='Drama'},
  @{t='The White Lotus'; g='Drama'},
  @{t='Reacher'; g='Action'},
  @{t='Slow Horses'; g='Thriller'},
  @{t='Morning Show'; g='Drama'},
  @{t='Beef'; g='Drama'},
  @{t='Wednesday'; g='Comedy'},
  @{t='Stranger Things'; g='Sci-Fi'},
  @{t='The Crown'; g='Biography'},
  @{t='Peaky Blinders'; g='Crime'},
  @{t='Better Call Saul'; g='Crime'},
  @{t='Breaking Bad'; g='Crime'},
  @{t='The Boys'; g='Action'},
  @{t='Invincible'; g='Animation'},
  @{t='Arcane'; g='Animation'},
  @{t='One Piece'; g='Action'},
  @{t='Fallout'; g='Sci-Fi'},
  @{t='True Detective'; g='Crime'},
  @{t='Fargo'; g='Crime'},
  @{t='Fleabag'; g='Comedy'},
  @{t='Chernobyl'; g='Drama'}
)

$palette = @{
  'Drama'      = @('1a3b8b', '4d7dff')
  'Sci-Fi'     = @('081229', '4d7dff')
  'Biography'  = @('4b1d52', 'b85ccb')
  'Comedy'     = @('ff7a3c', 'ffd166')
  'Horror'     = @('1a0010', '6b0028')
  'Fantasy'    = @('3a1078', '4e31aa')
  'Thriller'   = @('10202e', '1f3a5f')
  'Action'     = @('1a0a08', 'b32424')
  'Animation'  = @('0a4f3c', '19a974')
  'Crime'      = @('2a1a08', '6b3d10')
  'Romance'    = @('a52e6a', 'ff8db4')
  'Music'      = @('3a0a4d', 'ff2e63')
}

function Get-Palette($g){
  if ($palette.ContainsKey($g)) { return $palette[$g] }
  return @('1a1a2e','4d7dff')
}

function Slug($s){ ($s.ToLower() -replace "[^a-z0-9]+","-" -replace "^-|-$","") }

function Make-Poster($title, $genre, $idx, $kind){
  $pal = Get-Palette $genre
  $c1 = $pal[0]; $c2 = $pal[1]
  $slug = Slug $title
  $tag = if ($kind -eq 'series') { 'SERIES' } else { 'MOVIE' }
  $fontSize = if ($title.Length -gt 18) { 28 } elseif ($title.Length -gt 12) { 36 } else { 46 }
  $shape = ($idx % 4)
  $shapeSvg = switch ($shape) {
    0 { '<circle cx="300" cy="380" r="180" fill="rgba(255,255,255,0.10)"/><circle cx="300" cy="380" r="120" fill="rgba(255,255,255,0.06)"/>' }
    1 { '<rect x="80" y="280" width="440" height="320" rx="40" fill="rgba(255,255,255,0.10)" transform="rotate(-6 300 440)"/>' }
    2 { '<polygon points="300,180 520,500 80,500" fill="rgba(255,255,255,0.10)"/>' }
    3 { '<path d="M60,420 Q300,200 540,420" stroke="rgba(255,255,255,0.18)" stroke-width="40" fill="none" stroke-linecap="round"/>' }
  }
  $svg = "<svg xmlns=`"http://www.w3.org/2000/svg`" viewBox=`"0 0 600 900`" preserveAspectRatio=`"xMidYMid slice`">
  <defs>
    <linearGradient id=`"bg`" x1=`"0`" y1=`"0`" x2=`"1`" y2=`"1`">
      <stop offset=`"0`" stop-color=`"#$c1`"/>
      <stop offset=`"1`" stop-color=`"#$c2`"/>
    </linearGradient>
    <linearGradient id=`"grain`" x1=`"0`" y1=`"0`" x2=`"0`" y2=`"1`">
      <stop offset=`"0`" stop-color=`"rgba(255,255,255,0.18)`"/>
      <stop offset=`"1`" stop-color=`"rgba(0,0,0,0.30)`"/>
    </linearGradient>
    <filter id=`"noise`">
      <feTurbulence type=`"fractalNoise`" baseFrequency=`"0.9`" numOctaves=`"2`" seed=`"$idx`"/>
      <feColorMatrix values=`"0 0 0 0 1  0 0 0 0 1  0 0 0 0 1  0 0 0 0.06 0`"/>
      <feComposite in2=`"SourceGraphic`" operator=`"in`"/>
    </filter>
  </defs>
  <rect width=`"600`" height=`"900`" fill=`"url(#bg)`"/>
  $shapeSvg
  <rect width=`"600`" height=`"900`" fill=`"url(#grain)`"/>
  <rect width=`"600`" height=`"900`" filter=`"url(#noise)`"/>
  <g font-family=`"Inter,Segoe UI,sans-serif`" fill=`"white`">
    <text x=`"50`" y=`"80`" font-size=`"18`" font-weight=`"800`" letter-spacing=`"4`" opacity=`"0.8`">$tag</text>
    <line x1=`"50`" y1=`"98`" x2=`"120`" y2=`"98`" stroke=`"white`" stroke-width=`"3`" opacity=`"0.8`"/>
    <text x=`"50`" y=`"500`" font-size=`"$fontSize`" font-weight=`"900`" letter-spacing=`"-1`">$title</text>
    <text x=`"50`" y=`"540`" font-size=`"18`" font-weight=`"600`" opacity=`"0.85`">$genre</text>
    <g transform=`"translate(50,840)`">
      <rect width=`"56`" height=`"20`" rx=`"4`" fill=`"white`" opacity=`"0.95`"/>
      <text x=`"28`" y=`"14`" font-size=`"12`" font-weight=`"800`" fill=`"#$c1`" text-anchor=`"middle`">HD</text>
    </g>
  </g>
</svg>"
  $dir = "assets/posters"
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  [System.IO.File]::WriteAllText("$dir/$slug.svg", $svg, [System.Text.UTF8Encoding]::new($false))
  return $slug
}

function Make-Backdrop($title, $genre, $idx){
  $pal = Get-Palette $genre
  $c1 = $pal[0]; $c2 = $pal[1]
  $shape = ($idx % 4)
  $shapeSvg = switch ($shape) {
    0 { '<circle cx="1200" cy="500" r="500" fill="rgba(255,255,255,0.08)"/>' }
    1 { '<polygon points="0,800 1920,200 1920,1080 0,1080" fill="rgba(255,255,255,0.10)"/>' }
    2 { '<rect x="100" y="100" width="1720" height="880" rx="60" fill="none" stroke="rgba(255,255,255,0.20)" stroke-width="6"/>' }
    3 { '<path d="M0,540 Q480,200 960,540 T1920,540" stroke="rgba(255,255,255,0.18)" stroke-width="80" fill="none"/>' }
  }
  $svg = "<svg xmlns=`"http://www.w3.org/2000/svg`" viewBox=`"0 0 1920 1080`" preserveAspectRatio=`"xMidYMid slice`">
  <defs>
    <linearGradient id=`"bg`" x1=`"0`" y1=`"0`" x2=`"1`" y2=`"1`">
      <stop offset=`"0`" stop-color=`"#$c1`"/>
      <stop offset=`"1`" stop-color=`"#$c2`"/>
    </linearGradient>
    <linearGradient id=`"fade`" x1=`"0`" y1=`"0`" x2=`"0`" y2=`"1`">
      <stop offset=`"0`" stop-color=`"rgba(255,255,255,0)`"/>
      <stop offset=`"0.5`" stop-color=`"rgba(255,255,255,0.35)`"/>
      <stop offset=`"1`" stop-color=`"rgba(255,255,255,0.85)`"/>
    </linearGradient>
    <filter id=`"noise`">
      <feTurbulence type=`"fractalNoise`" baseFrequency=`"0.85`" numOctaves=`"2`" seed=`"$idx`"/>
      <feColorMatrix values=`"0 0 0 0 1  0 0 0 0 1  0 0 0 0 1  0 0 0 0.04 0`"/>
    </filter>
  </defs>
  <rect width=`"1920`" height=`"1080`" fill=`"url(#bg)`"/>
  $shapeSvg
  <rect width=`"1920`" height=`"1080`" filter=`"url(#noise)`"/>
  <rect width=`"1920`" height=`"1080`" fill=`"url(#fade)`"/>
</svg>"
  $slug = Slug $title
  $dir = "assets/backdrops"
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  [System.IO.File]::WriteAllText("$dir/$slug.svg", $svg, [System.Text.UTF8Encoding]::new($false))
  return $slug
}

$i = 0
foreach ($m in $movies) {
  $slug = Make-Poster $m['t'] $m['g'] $i 'movie'
  $i++
}
$i = 0
foreach ($m in $tvs) {
  $slug = Make-Poster $m['t'] $m['g'] ($i + 100) 'series'
  $i++
}

$hero = @(
  @{t='The Devil Wears Prada 2'; g='Drama'},
  @{t='Swapped'; g='Comedy'},
  @{t='Michael'; g='Biography'},
  @{t='Apex'; g='Action'},
  @{t='The Gates'; g='Thriller'},
  @{t='Scream 7'; g='Horror'}
)
$j = 0
foreach ($m in $hero) {
  $slug = Make-Backdrop $m['t'] $m['g'] $j
  $j++
}

Write-Output ("posters: " + ((Get-ChildItem assets/posters).Count) + "  backdrops: " + ((Get-ChildItem assets/backdrops).Count))
