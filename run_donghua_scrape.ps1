# run_donghua_scrape.ps1
param([string]$Key = "")
if ($Key) { $env:FIRECRAWL_API_KEY = $Key }
python scrape_donghua_sources.py
