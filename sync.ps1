# Mirror kartik-clothing's /takeshots output into this repo and push it to GitHub.
# Run after each /takeshots run:  powershell -ExecutionPolicy Bypass -File .\sync.ps1
# Add -NoPush to only copy and commit.
param([switch]$NoPush)

$ErrorActionPreference = 'Stop'
$repo = $PSScriptRoot
$src  = 'C:\Users\Administrator\Desktop\Fever-Dreams\server-data\resources\[startup]\kartik-clothing\preview'

if (-not (Test-Path -LiteralPath $src)) { throw "preview folder not found: $src" }

# /MIR makes repo\preview an exact copy (removes files deleted on the server). Only images are needed.
robocopy $src (Join-Path $repo 'preview') *.webp *.png /MIR /NFL /NDL /NJH /NP /R:1 /W:1 | Out-Null
if ($LASTEXITCODE -ge 8) { throw "robocopy failed with exit code $LASTEXITCODE" }

Set-Location $repo
git add -A
git diff --cached --quiet
if ($LASTEXITCODE -eq 0) { 'No image changes to sync.'; return }

$count = (git diff --cached --name-only | Measure-Object).Count
git commit -q -m "Sync $count preview files ($(Get-Date -Format 'yyyy-MM-dd HH:mm'))"
"Committed $count changed files."

if ($NoPush) { 'Skipped push (-NoPush).'; return }
git push -u origin main
