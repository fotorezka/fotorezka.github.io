# get.ps1 — FotoRezka install bootstrap
# Usage: powershell -c "irm https://fotorezka.github.io/get.ps1 | iex"

$ErrorActionPreference = 'Stop'

$repoBase = 'https://github.com/fotorezka/fotorezka.github.io'
$zipUrl   = "$repoBase/releases/latest/download/FotoRezka-update.zip"
$fullUrl  = "$repoBase/releases/latest/download/FotoRezka.zip"
$zip = Join-Path $env:TEMP 'FotoRezka-update.zip'
$dir = Join-Path $env:TEMP 'FotoRezka_install'

Write-Host "`nFotoRezka — установка`n" -ForegroundColor Cyan

# Clean up any previous attempt
if (Test-Path $dir) { Remove-Item $dir -Recurse -Force }
if (Test-Path $zip) { Remove-Item $zip -Force }

Write-Host "Скачиваю..."
Invoke-WebRequest -Uri $zipUrl -OutFile $zip -UseBasicParsing

Write-Host "Распаковываю..."
Expand-Archive -Path $zip -DestinationPath $dir -Force

$inst = Get-ChildItem $dir -Filter 'install.ps1' -Recurse | Select-Object -First 1
if (-not $inst) { throw "install.ps1 не найден в архиве" }

Write-Host "Запускаю установщик (потребуется подтверждение)...`n"
Start-Process powershell -Verb RunAs -Wait `
    -ArgumentList "-ExecutionPolicy Bypass -File `"$($inst.FullName)`""

# Clean up
Remove-Item $zip -Force -ErrorAction SilentlyContinue
Remove-Item $dir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "`nГотово!" -ForegroundColor Green
Write-Host "Модели загрузятся при первом запуске (~100 МБ)."
Write-Host "Полный архив (с моделями): $fullUrl`n"
