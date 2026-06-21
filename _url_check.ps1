$out = 'C:\Users\mengxiang\Documents\MengFlix\_poster_urls.txt'
$log = New-Object System.Collections.Generic.List[string]
$entries = @(
  @{n='A Real Pain'; y=2024; t='Movie'},
  @{n='Alien Romulus'; y=2024; t='Movie'},
  @{n='Andor'; y=2022; t='TVSeries'},
  @{n='Arcane'; y=2021; t='TVSeries'},
  @{n='Beef'; y=2023; t='TVSeries'},
  @{n='Beetlejuice B.'; y=2024; t='Movie'},
  @{n='Better Call Saul'; y=2015; t='TVSeries'},
  @{n='Breaking Bad'; y=2008; t='TVSeries'},
  @{n='Civil War'; y=2024; t='Movie'},
  @{n='Conclave'; y=2024; t='Movie'},
  @{n='Dune: Part Two'; y=2024; t='Movie'},
  @{n='Fallout'; y=2024; t='TVSeries'},
  @{n='Fargo'; y=2014; t='TVSeries'},
  @{n='Furiosa'; y=2024; t='Movie'},
  @{n='Gladiator II'; y=2024; t='Movie'},
  @{n='Heretic'; y=2024; t='Movie'},
  @{n='Hit Man'; y=2024; t='Movie'},
  @{n='House of the Dragon'; y=2022; t='TVSeries'},
  @{n='Invincible'; y=2021; t='TVSeries'},
  @{n='It Ends With Us'; y=2024; t='Movie'},
  @{n='Joker: Folie 2'; y=2024; t='Movie'},
  @{n='Love Lies Bleeding'; y=2024; t='Movie'},
  @{n='Morning Show'; y=2019; t='TVSeries'},
  @{n='Nosferatu'; y=2024; t='Movie'},
  @{n='One Piece'; y=2023; t='TVSeries'},
  @{n='Oppenheimer'; y=2023; t='Movie'},
  @{n='Peaky Blinders'; y=2013; t='TVSeries'},
  @{n='Poor Things'; y=2023; t='Movie'},
  @{n='Reacher'; y=2022; t='TVSeries'},
  @{n='Severance'; y=2022; t='TVSeries'},
  @{n='Shogun'; y=2024; t='TVSeries'},
  @{n='Slow Horses'; y=2022; t='TVSeries'},
  @{n='Smile 2'; y=2024; t='Movie'},
  @{n='Society of Snow'; y=2023; t='Movie'},
  @{n='Stranger Things'; y=2016; t='TVSeries'},
  @{n='Succession'; y=2018; t='TVSeries'},
  @{n='Terrifier 3'; y=2024; t='Movie'},
  @{n='The Bear'; y=2022; t='TVSeries'},
  @{n='The Boys'; y=2019; t='TVSeries'},
  @{n='The Crown'; y=2016; t='TVSeries'},
  @{n='The Last of Us'; y=2023; t='TVSeries'},
  @{n='The Penguin'; y=2024; t='TVSeries'},
  @{n='The Substance'; y=2024; t='Movie'},
  @{n='The White Lotus'; y=2021; t='TVSeries'},
  @{n='The Wild Robot'; y=2024; t='Movie'},
  @{n='True Detective'; y=2014; t='TVSeries'},
  @{n='Wednesday'; y=2022; t='TVSeries'},
  @{n='Wicked'; y=2024; t='Movie'}
)
foreach ($e in $entries) {
  $q = [System.Uri]::EscapeDataString($e.n)
  $u = "https://yflix.ws/search?q=$q"
  try {
    $r = Invoke-WebRequest $u -UseBasicParsing -TimeoutSec 8
    $c = $r.Content
    $pat = '/images/posters/(movies|tv)/([a-z0-9-]+)\.webp'
    $ms = [regex]::Matches($c, $pat)
    $best = ''
    foreach ($m in $ms) {
      $slug = $m.Groups[2].Value
      if ($slug -like ('*-' + $e.y)) { $best = 'https://yflix.ws' + $m.Groups[0].Value; break }
    }
    if ($best -eq '' -and $ms.Count -gt 0) {
      $best = 'https://yflix.ws' + $ms[0].Groups[0].Value
    }
    if ($best -ne '') {
      $log.Add(('{0} | {1}' -f $e.n, $best))
    } else {
      $log.Add(('MISS {0}' -f $e.n))
    }
  } catch {
    $log.Add(('ERR {0}: {1}' -f $e.n, $_.Exception.Message))
  }
}
[System.IO.File]::WriteAllLines($out, $log)