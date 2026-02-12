# get.ps1 — FotoRezka install bootstrap
# Usage (pipe):   powershell -c "irm https://fotorezka.github.io/get.ps1 | iex"
# Usage (file):   powershell -ExecutionPolicy Bypass -File get.ps1

$ErrorActionPreference = 'Stop'

$repoBase = 'https://github.com/fotorezka/fotorezka.github.io'
$zipUrl   = "$repoBase/releases/latest/download/FotoRezka-update.zip"
$fullUrl  = "$repoBase/releases/latest/download/FotoRezka.zip"
$zip = Join-Path $env:TEMP 'FotoRezka-update.zip'
$dir = Join-Path $env:TEMP 'FotoRezka_install'

Write-Host "`nFotoRezka — Install`n" -ForegroundColor Cyan

# Clean up any previous attempt
if (Test-Path $dir) { Remove-Item $dir -Recurse -Force }
if (Test-Path $zip) { Remove-Item $zip -Force }

Write-Host "Downloading..."
Invoke-WebRequest -Uri $zipUrl -OutFile $zip -UseBasicParsing

Write-Host "Extracting..."
Expand-Archive -Path $zip -DestinationPath $dir -Force

$inst = Get-ChildItem $dir -Filter '_install.ps1' -Recurse | Select-Object -First 1
if (-not $inst) { throw "_install.ps1 not found in archive" }

Write-Host "Running installer (confirmation required)...`n"
Start-Process powershell -Verb RunAs -Wait `
    -ArgumentList "-ExecutionPolicy Bypass -File `"$($inst.FullName)`""

# Clean up
Remove-Item $zip -Force -ErrorAction SilentlyContinue
Remove-Item $dir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "`nDone!" -ForegroundColor Green
Write-Host "Models will download on first launch (~100 MB)."
Write-Host "Full archive (with models): $fullUrl`n"

# When run as a file (not piped), pause so the window doesn't close immediately
if ($MyInvocation.MyCommand.Path) {
    Read-Host "Press Enter to exit"
}
