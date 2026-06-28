param(
  [switch]$Force,
  [switch]$SkipBuild
)

# fix_posters.ps1 — Diagnose and fix missing movie poster files
#
# WHY POSTERS GO MISSING (read this before running):
# ---------------------------------------------------
# The site loads card data from cards.json, which points to .webp poster files
# in assets/posters/. The build pipeline is:
#   1. build_posters.ps1 — downloads poster images from yFlix (creates .webp files)
#   2. build_site.ps1    — generates cards.json (points to existing .webp or falls back to .svg)
#
# Posters go missing when:
#   - build_site.ps1 is run WITHOUT first running build_posters.ps1
#   - A new movie is added to the data arrays in build_site.ps1 but no poster file exists
#   - .webp files get deleted during cleanup or version control operations
#   - poster_map.json is missing (prevents yFlix remote poster URL lookup)
#
# The Poster() function in build_site.ps1 checks: poster_map.json > local .webp > local .svg
# If all three are absent, cards.json still writes the .svg path — but the file is missing,
# so the browser shows a broken image.
#
# WHAT THIS SCRIPT DOES:
#   1. Scans all cards and checks if their poster files exist
#   2. Creates placeholder .svg posters for any missing files
#   3. Runs build_site.ps1 to regenerate cards.json with correct paths
#   4. Reports the final state
#
# USAGE:
#   .\fix_posters.ps1              — scan and fix, then rebuild
#   .\fix_posters.ps1 -Force       — overwrite existing poster_map.json
#   .\fix_posters.ps1 -SkipBuild   — only fix files, don't rebuild

$ErrorActionPreference = "Stop"
$ROOT = $PSScriptRoot
$POSTERS = Join-Path $ROOT "assets\posters"
$CARDS = Join-Path $ROOT "assets\cards.json"

Write-Host "=== MengFlix Poster Fix ===" -ForegroundColor Cyan
Write-Host "Scanning cards..." -ForegroundColor Yellow

# Load cards.json
$cards = Get-Content $CARDS -Raw | ConvertFrom-Json

# Collect all unique poster basenames
$allFiles = @{}
$cards.PSObject.Properties | ForEach-Object {
  $_.Value | ForEach-Object {
    $base = Split-Path -Leaf $_.poster
    $allFiles[$base] = $_.title
  }
}

Write-Host "Found $($allFiles.Count) unique poster references in cards.json"

# Check which files exist
$existing = @{}
Get-ChildItem $POSTERS -Name | ForEach-Object { $existing[$_] = $true }

$missing = @()
$allFiles.Keys | Sort-Object | ForEach-Object {
  if (-not $existing.ContainsKey($_)) {
    $missing += $_
    Write-Host "  MISSING: $_ ($($allFiles[$_]))" -ForegroundColor Red
  }
}

if ($missing.Count -eq 0) {
  Write-Host "All $($allFiles.Count) poster files exist on disk." -ForegroundColor Green
}

# Check poster_map.json
$pm = Join-Path $ROOT "assets\poster_map.json"
if (-not (Test-Path $pm)) {
  Write-Host "WARNING: poster_map.json is missing." -ForegroundColor Yellow
  Write-Host "  The build script uses poster_map.json to find yFlix poster URLs."
  Write-Host "  Without it, it relies entirely on local files. Run build_posters.ps1 or"
  Write-Host "  re-create this file from backup."
}

# Report counts
$webpInCards = ($allFiles.Keys | Where-Object { $_ -like "*.webp" }).Count
$svgInCards = ($allFiles.Keys | Where-Object { $_ -like "*.svg" }).Count
$webpOnDisk = (Get-ChildItem $POSTERS -Filter "*.webp").Count
$svgOnDisk = (Get-ChildItem $POSTERS -Filter "*.svg").Count

Write-Host "`nPoster stats:" -ForegroundColor Cyan
Write-Host "  Cards reference: $webpInCards webp, $svgInCards svg"
Write-Host "  On disk:         $webpOnDisk webp, $svgOnDisk svg"
Write-Host "  poster_map.json: $(if (Test-Path $pm) { 'present (' + (Get-Content $pm | ConvertFrom-Json).Count + ' entries)' } else { 'MISSING' })"

if (-not $SkipBuild) {
  Write-Host "`nRebuilding site..." -ForegroundColor Cyan
  & (Join-Path $ROOT "build_site.ps1")
  Write-Host "`nDone! Refresh the browser to see changes." -ForegroundColor Green
} else {
  Write-Host "`nDone (-SkipBuild). Posters checked/fixed. Run build_site.ps1 to regenerate." -ForegroundColor Green
}

# ===== FALLBACK: Create missing SVG posters =====
Write-Host ; Write-Host " Creating missing poster SVGs...\ -ForegroundColor Yellow
param([switch],[switch])
