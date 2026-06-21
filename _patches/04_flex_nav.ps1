$path = "C:\Users\mengxiang\Documents\MengFlix\assets\css\styles.css"
$content = Get-Content -Raw -LiteralPath $path
$nl = [Environment]::NewLine

$old = "/* ---------- Responsive ---------- */" + $nl
$old += "@media (max-width: 1100px){" + $nl
$old += "  .slider-track{ grid-auto-columns: calc((100% - 40px) / 5);}" + $nl
$old += "}"

$new = "/* ---------- Responsive ---------- */" + $nl
$new += "/* Desktop / tablet: make the top nav always flexible. */" + $nl
$new += "/* 1) Allow the header row to wrap to a second line if the viewport is too narrow. */" + $nl
$new += ".site-header .container{ max-width: 100%; }" + $nl
$new += ".header-inner{ flex-wrap: wrap; row-gap: 8px; }" + $nl
$new += ".header-left{ flex-wrap: wrap; row-gap: 4px; }" + $nl
$new += "/* 2) Make each nav link shrink-resistant but allow the text to wrap if absolutely needed. */" + $nl
$new += ".header-left > a, .header-left .btn-browse{ white-space: nowrap; }" + $nl
$new += "/* 3) Push the right cluster to the far right on the first row. */" + $nl
$new += ".header-right{ margin-left: auto; }" + $nl
$new += "" + $nl
$new += "@media (max-width: 1180px){" + $nl
$new += "  /* Tighter gaps and slightly smaller wordmark so the nav fits a typical laptop. */" + $nl
$new += "  .header-inner{ gap: 12px; }" + $nl
$new += "  .header-left{ gap: 4px; margin-left: 4px; }" + $nl
$new += "  .header-left > a, .header-left .btn-browse{ padding: 8px 10px; font-size: 13.5px; }" + $nl
$new += "  .header-right{ gap: 6px; }" + $nl
$new += "  .logo-text{ font-size: 15px; }" + $nl
$new += "}" + $nl
$new += "" + $nl
$new += "@media (max-width: 1040px){" + $nl
$new += "  /* Compress further; allow the nav to wrap to a second line if needed. */" + $nl
$new += "  .header-inner{ gap: 8px; }" + $nl
$new += "  .header-left > a, .header-left .btn-browse{ padding: 7px 9px; font-size: 13px; }" + $nl
$new += "  .btn-signin{ padding: 8px 14px; font-size: 13px; }" + $nl
$new += "  .nav-search-link, .nav-theme-link, .mobile-menu-toggle{ width: 38px; height: 38px; }" + $nl
$new += "}" + $nl
$new += "" + $nl
$new += "@media (max-width: 960px){" + $nl
$new += "  /* The Browse dropdown becomes a compact icon button to save room. */" + $nl
$new += "  .header-left .btn-browse > span{ display: none; }" + $nl
$new += "  .header-left .btn-browse{ padding: 7px 9px; }" + $nl
$new += "  .header-left .btn-browse svg{ margin: 0; }" + $nl
$new += "  .header-left{ gap: 2px; }" + $nl
$new += "}" + $nl
$new += "" + $nl
$new += "@media (max-width: 1100px){" + $nl
$new += "  .slider-track{ grid-auto-columns: calc((100% - 40px) / 5);}" + $nl
$new += "}"

if (-not $content.Contains($old)) { Write-Error "responsive marker not found"; exit 1 }
$content = $content.Replace($old, $new)
Set-Content -LiteralPath $path -Value $content -Encoding UTF8 -NoNewline
Write-Output "patched responsive flex nav"
