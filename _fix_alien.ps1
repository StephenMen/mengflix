$path = 'C:\Users\mengxiang\Documents\MengFlix\index.html'
$content = [System.IO.File]::ReadAllText($path)
$nl = [Environment]::NewLine
$old = 'data-title="Alien: Romulus" data-type="Movie" data-poster="assets/posters/alien-romulus.svg"'
$new = 'data-title="Alien: Romulus" data-type="Movie" data-poster="https://yflix.ws/images/posters/movies/alien-romulus-2024.webp"'
$count = ([regex]::Matches($content, [regex]::Escape($old))).Count
Write-Output "Outer matches: $count"
$newContent = $content.Replace($old, $new)
# Now fix the inner <img>
$oldImg = '<img src="assets/posters/alien-romulus.svg" alt="Alien: Romulus"'
$newImg = '<img src="https://yflix.ws/images/posters/movies/alien-romulus-2024.webp" alt="Alien: Romulus"'
$count2 = ([regex]::Matches($newContent, [regex]::Escape($oldImg))).Count
Write-Output "Inner img matches: $count2"
$newContent = $newContent.Replace($oldImg, $newImg)
[System.IO.File]::WriteAllText($path, $newContent, [System.Text.UTF8Encoding]::new($false))
Write-Output "Done."