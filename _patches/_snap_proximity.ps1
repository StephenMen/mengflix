$path = "C:\Users\mengxiang\Documents\MengFlix\assets\css\styles.css"
$text = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
$lf = "`n"
$old = "  scroll-snap-type: x mandatory;"
$new = "  scroll-snap-type: x proximity;"
$contains = $text.Contains($old)
Write-Output ("contains: {0}" -f $contains)
if (-not $contains) { exit 1 }
$text = $text.Replace($old, $new)
[System.IO.File]::WriteAllText($path, $text, [System.Text.Encoding]::UTF8)
Write-Output 'snap -> proximity'
