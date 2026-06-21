$path = 'C:\Users\mengxiang\Documents\MengFlix\index.html'
$jsonPath = 'C:\Users\mengxiang\Documents\MengFlix\_poster_map.json'
$map = Get-Content $jsonPath -Raw | ConvertFrom-Json
$content = [System.IO.File]::ReadAllText($path)

$nl = [Environment]::NewLine
$updated = 0
$skipped = 0

# Build a quick lookup: title -> URL
$lookup = @{}
$map.PSObject.Properties | ForEach-Object { $lookup[$_.Name] = $_.Value }

# Iterate over each <article class="content-card" data-title="..." data-poster="assets/posters/..."> 
# and replace the data-poster and the inner <img src="assets/posters/..."> with the yflix URL.
$pat = [regex]"(?ms)<article class=""content-card""[^>]*?data-title=""([^""]+)""[^>]*?data-poster=""(assets/posters/[^""]+)""[^>]*?>(.*?</article>)"
$matches = [regex]::Matches($content, $pat)
Write-Output "Found $($matches.Count) card matches with local SVG poster"

# Process in reverse to preserve indices
$newContent = $content
for ($i = $matches.Count - 1; $i -ge 0; $i--) {
  $m = $matches[$i]
  $title = $m.Groups[1].Value
  $oldPoster = $m.Groups[2].Value
  $inner = $m.Groups[3].Value
  if ($lookup.ContainsKey($title)) {
    $newUrl = $lookup[$title]
    $newInner = $inner -replace [regex]::Escape($oldPoster), $newUrl
    if ($newInner -ne $inner) {
      # Also update the data-poster in the article tag
      $oldArtStart = $content.Substring($m.Index, $m.Length - $inner.Length)
      $newArtStart = $oldArtStart -replace [regex]::Escape('data-poster="' + $oldPoster + '"'), ('data-poster="' + $newUrl + '"')
      $fullNew = $newArtStart + $newInner
      $newContent = $newContent.Substring(0, $m.Index) + $fullNew + $newContent.Substring($m.Index + $m.Length)
      $updated++
    } else {
      $skipped++
    }
  } else {
    $skipped++
  }
}

[System.IO.File]::WriteAllText($path, $newContent, [System.Text.UTF8Encoding]::new($false))
Write-Output "Updated: $updated, Skipped: $skipped"