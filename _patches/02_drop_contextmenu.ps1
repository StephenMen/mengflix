$path = "C:\Users\mengxiang\Documents\MengFlix\assets\js\main.js"
$content = Get-Content -Raw -LiteralPath $path
$nl = [char]10
$old = "    track.addEventListener('mousedown', (e) => { if (e.button === 1) e.preventDefault(); });" + $nl
$old += "    track.addEventListener('auxclick', (e) => { if (e.button === 1) e.preventDefault(); });" + $nl
$old += "    track.addEventListener('pointerdown', (e) => { if (e.button === 1) e.preventDefault(); });" + $nl
$old += "    track.addEventListener('contextmenu', (e) => e.preventDefault());" + $nl

$new = "    track.addEventListener('mousedown', (e) => { if (e.button === 1) e.preventDefault(); });" + $nl
$new += "    track.addEventListener('auxclick', (e) => { if (e.button === 1) e.preventDefault(); });" + $nl
$new += "    track.addEventListener('pointerdown', (e) => { if (e.button === 1) e.preventDefault(); });" + $nl

if (-not $content.Contains($old)) { Write-Error "not found"; exit 1 }
$content = $content.Replace($old, $new)
Set-Content -LiteralPath $path -Value $content -Encoding UTF8 -NoNewline
Write-Output "removed contextmenu prevent"
