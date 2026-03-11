<#
  GreenOps Monitor - Quick Installer
  Usage: irm https://raw.githubusercontent.com/MiguelFAraujo/GreenOpsMonitor/master/install.ps1 | iex
#>

$Repo = "https://github.com/MiguelFAraujo/GreenOpsMonitor.git"
$InstallDir = "$HOME\GreenOpsMonitor"

Write-Host ""
Write-Host "  GreenOps Monitor - Installer" -ForegroundColor Cyan
Write-Host ""

# Check Python
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "  [ERROR] Python not found. Install: https://python.org" -ForegroundColor Red
    exit 1
}

# Check Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "  [ERROR] Git not found. Install: https://git-scm.com" -ForegroundColor Red
    exit 1
}

# Clone or update
if (Test-Path $InstallDir) {
    Write-Host "  [*] Updating..." -ForegroundColor Yellow
    Push-Location $InstallDir
    git pull --quiet
    Pop-Location
} else {
    Write-Host "  [*] Cloning repository..." -ForegroundColor Yellow
    git clone --quiet $Repo $InstallDir
}

# Install dependencies
Write-Host "  [*] Installing dependencies..." -ForegroundColor Yellow
& python -m pip install psutil --quiet 2>$null

# Create global alias
$profileDir = Split-Path $PROFILE -Parent
if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }
if (-not (Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force | Out-Null }

$alias = "function greenops { & '$InstallDir\greenops.ps1' }"
$profileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
if ($profileContent -notlike "*function greenops*") {
    Add-Content $PROFILE "`n# GreenOps Monitor`n$alias"
    Write-Host "  [OK] Command 'greenops' added to PowerShell" -ForegroundColor Green
} else {
    Write-Host "  [OK] Command 'greenops' already configured" -ForegroundColor Green
}

# Load in current shell
Invoke-Expression $alias

Write-Host ""
Write-Host "  [OK] Installed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "  >> Open a new terminal and type: greenops" -ForegroundColor Cyan
Write-Host "  >> Or run now:  greenops" -ForegroundColor Cyan
Write-Host ""
