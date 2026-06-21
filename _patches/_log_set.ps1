$path = "C:\Users\mengxiang\Documents\MengFlix\assets\js\main.js"
$text = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
$lf = "`n"
$old = "      track.scrollLeft = startScroll - dx;"
$new = "      const target = startScroll - dx; track.scrollLeft = target; try { console.log('[dbg] set scrollLeft', target, '->', track.scrollLeft, 'snap', getComputedStyle(track).scrollSnapType); } catch (err) {}"
$contains = $text.Contains($old)
Write-Output ("contains: {0}" -f $contains)
if (-not $contains) { exit 1 }
$text = $text.Replace($old, $new)
[System.IO.File]::WriteAllText($path, $text, [System.Text.Encoding]::UTF8)
Write-Output 'log set'
