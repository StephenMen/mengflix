# deploy.ps1 — commit any changes and push to GitHub (Netlify auto-deploys)
# Usage:
#   .\deploy.ps1                (uses default message "Update site")
#   .\deploy.ps1 "Fix player animation"

param([string]$msg = "Update site")

# Make sure we're in the project root
$ErrorActionPreference = "Stop"
Set-Location -Path $PSScriptRoot

# Check for changes
$status = git status --porcelain
if (-not $status) {
    Write-Host "Nothing to commit. Working tree clean." -ForegroundColor Yellow
    exit 0
}

Write-Host "--- Staging all changes ---" -ForegroundColor Cyan
git add .

Write-Host "--- Committing: $msg ---" -ForegroundColor Cyan
git commit -m $msg

Write-Host "--- Pushing to origin/main ---" -ForegroundColor Cyan
git push origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✓ Pushed successfully. Netlify will deploy in ~30 seconds." -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "✗ Push failed. Check the error above." -ForegroundColor Red
    exit 1
}