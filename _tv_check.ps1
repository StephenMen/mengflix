$out = 'C:\Users\mengxiang\Documents\MengFlix\_tv_urls.txt'
$log = New-Object System.Collections.Generic.List[string]
$titles = @{
  'Andor' = @{ y=2022; slugs=@('andor-2022','andor') }
  'Arcane' = @{ y=2021; slugs=@('arcane-2021','arcane') }
  'Better Call Saul' = @{ y=2015; slugs=@('better-call-saul-2015','better-call-saul') }
  'Breaking Bad' = @{ y=2008; slugs=@('breaking-bad-2008','breaking-bad') }
  'House of the Dragon' = @{ y=2022; slugs=@('house-of-the-dragon-2022','house-of-the-dragon') }
  'Slow Horses' = @{ y=2022; slugs=@('slow-horses-2022','slow-horses') }
  'Succession' = @{ y=2018; slugs=@('succession-2018','succession') }
  'The Last of Us' = @{ y=2023; slugs=@('the-last-of-us-2023','the-last-of-us') }
  'True Detective' = @{ y=2014; slugs=@('true-detective-2014','true-detective') }
  'Fargo' = @{ y=2014; slugs=@('fargo-2014','fargo') }
  'Invincible' = @{ y=2021; slugs=@('invincible-2021','invincible') }
  'Reacher' = @{ y=2022; slugs=@('reacher-2022','reacher') }
  'Severance' = @{ y=2022; slugs=@('severance-2022','severance') }
  'Shogun' = @{ y=2024; slugs=@('shogun-2024','shogun') }
  'The Bear' = @{ y=2022; slugs=@('the-bear-2022','the-bear') }
  'The Boys' = @{ y=2019; slugs=@('the-boys-2019','the-boys') }
  'The Crown' = @{ y=2016; slugs=@('the-crown-2016','the-crown') }
  'The Penguin' = @{ y=2024; slugs=@('the-penguin-2024','the-penguin') }
  'The White Lotus' = @{ y=2021; slugs=@('the-white-lotus-2021','the-white-lotus') }
  'Wednesday' = @{ y=2022; slugs=@('wednesday-2022','wednesday') }
  'Beef' = @{ y=2023; slugs=@('beef-2023','beef') }
  'One Piece' = @{ y=2023; slugs=@('one-piece-2023','one-piece') }
  'Fallout' = @{ y=2024; slugs=@('fallout-2024','fallout') }
  'Morning Show' = @{ y=2019; slugs=@('the-morning-show-2019','morning-show-2019','morning-show') }
  'Peaky Blinders' = @{ y=2013; slugs=@('peaky-blinders-2013','peaky-blinders') }
  'Stranger Things' = @{ y=2016; slugs=@('stranger-things-2016','stranger-things') }
}
foreach ($k in $titles.Keys) {
  $info = $titles[$k]
  $found = ''
  foreach ($slug in $info.slugs) {
    $u = "https://yflix.ws/images/posters/series/$slug.webp"
    try {
      $r = Invoke-WebRequest $u -UseBasicParsing -TimeoutSec 4
      if ($r.StatusCode -eq 200) { $found = $u; break }
    } catch {}
  }
  if ($found -ne '') {
    $log.Add(('OK {0} | {1}' -f $k, $found))
  } else {
    $log.Add(('MISS {0}' -f $k))
  }
}
[System.IO.File]::WriteAllLines($out, $log)