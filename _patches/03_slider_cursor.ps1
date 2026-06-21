$path = "C:\Users\mengxiang\Documents\MengFlix\assets\css\styles.css"
$content = Get-Content -Raw -LiteralPath $path
$nl = [char]10
$old = ".slider-track:active{ cursor: grabbing; }"
$new = $old + $nl
$new += "  /* Prevent the browser middle-click autoscroll cursor on slider cards */" + $nl
$new += "  .slider-track a{ cursor: inherit; }" + $nl
$new += "  .slider-track a:active{ cursor: grabbing; }"
if (-not $content.Contains($old)) { Write-Error "not found"; exit 1 }
$content = $content.Replace($old, $new)
Set-Content -LiteralPath $path -Value $content -Encoding UTF8 -NoNewline
Write-Output "patched slider cursor"
