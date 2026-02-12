# uninstall.ps1 — FotoRezka uninstaller
# Usage: powershell -c "irm https://fotorezka.github.io/uninstall.ps1 | iex"
# Constraint: must work when piped via iex (no $MyInvocation.MyCommand.Path)

# Self-elevate to admin (re-downloads in elevated session)
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -Verb RunAs -ArgumentList `
        "-ExecutionPolicy Bypass -Command `"irm https://fotorezka.github.io/uninstall.ps1 | iex`""
    exit
}

$appDir   = "$env:ProgramFiles\FotoRezka"
$shortcut = "$env:PUBLIC\Desktop\Запустить ФотоРезку.lnk"

if (Test-Path $appDir) {
    Remove-Item $appDir -Recurse -Force
    Write-Host "Удалена папка: $appDir" -ForegroundColor Green
} else {
    Write-Host "Папка не найдена: $appDir" -ForegroundColor Yellow
}

if (Test-Path $shortcut) {
    Remove-Item $shortcut -Force
    Write-Host "Удалён ярлык с рабочего стола" -ForegroundColor Green
} else {
    Write-Host "Ярлык не найден" -ForegroundColor Yellow
}

Write-Host "`nФотоРезка удалена." -ForegroundColor Green
Write-Host "Папку с фотографиями на рабочем столе удалите вручную, если не нужна.`n"
pause
