# _get.ps1 -- FotoRezka install bootstrap
# Usage (pipe):   powershell -c "irm https://fotorezka.github.io/_get.ps1 | iex"
# Usage (file):   powershell -ExecutionPolicy Bypass -File _get.ps1

$ErrorActionPreference = 'Stop'

$isPiped = -not $MyInvocation.MyCommand.Path

# When piped (Win+R / irm|iex), hide the console — all UX goes through the GUI installer.
if ($isPiped) {
    Add-Type -MemberDefinition @'
[DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")]   public static extern bool ShowWindow(IntPtr h, int c);
'@ -Name NativeMethods -Namespace Win32
    [Win32.NativeMethods]::ShowWindow([Win32.NativeMethods]::GetConsoleWindow(), 0) | Out-Null
}

try {

$repoBase = 'https://github.com/fotorezka/fotorezka.github.io'
$zipUrl   = "$repoBase/releases/latest/download/FotoRezka-update.zip"
$zip = Join-Path $env:TEMP 'FotoRezka-update.zip'
$dir = Join-Path $env:TEMP 'FotoRezka_install'

Write-Host "`nFotoRezka -- Install`n" -ForegroundColor Cyan

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
    -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$($inst.FullName)`""

# Clean up
Remove-Item $zip -Force -ErrorAction SilentlyContinue
Remove-Item $dir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "`nDone!" -ForegroundColor Green

} catch {
    if ($isPiped) {
        # Console is hidden — show error via GUI dialog
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show(
            "Installation failed:`n`n$($_.Exception.Message)",
            "FotoRezka",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
    } else {
        Write-Host "`nERROR: $($_.Exception.Message)" -ForegroundColor Red
    }
    exit 1
}

# When run as a file (not piped), pause so the window doesn't close immediately
if (-not $isPiped) {
    Read-Host "Press Enter to exit"
}
