$path = 'C:\Users\mengxiang\Documents\MengFlix\assets\js\main.js'
$content = [System.IO.File]::ReadAllText($path)
$old = "'poster': 'assets/posters/alien-romulus.svg'"
$new = "'poster': 'https://yflix.ws/images/posters/movies/alien-romulus-2024.webp'"
$count = ([regex]::Matches($content, [regex]::Escape($old))).Count
Write-Output "Matches in curated: $count"
$newContent = $content.Replace($old, $new)
[System.IO.File]::WriteAllText($path, $newContent, [System.Text.UTF8Encoding]::new($false))
Write-Output "Done."