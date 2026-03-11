<#
  GreenOps Monitor — Instalador Rápido
  Uso: irm https://raw.githubusercontent.com/MiguelFAraujo/GreenOpsMonitor/master/install.ps1 | iex
#>

$Repo = "https://github.com/MiguelFAraujo/GreenOpsMonitor.git"
$InstallDir = "$HOME\GreenOpsMonitor"

Write-Host ""
Write-Host "  🟢 GreenOps Monitor — Instalador" -ForegroundColor Cyan
Write-Host ""

# Verifica Python
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "  ❌ Python nao encontrado. Instale: https://python.org" -ForegroundColor Red
    exit 1
}

# Verifica Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "  ❌ Git nao encontrado. Instale: https://git-scm.com" -ForegroundColor Red
    exit 1
}

# Clona ou atualiza
if (Test-Path $InstallDir) {
    Write-Host "  🔄 Atualizando..." -ForegroundColor Yellow
    Push-Location $InstallDir
    git pull --quiet
    Pop-Location
} else {
    Write-Host "  📥 Clonando repositorio..." -ForegroundColor Yellow
    git clone --quiet $Repo $InstallDir
}

# Instala dependencias
Write-Host "  📦 Instalando dependencias..." -ForegroundColor Yellow
& python -m pip install psutil --quiet 2>$null

# Cria alias global
$profileDir = Split-Path $PROFILE -Parent
if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }
if (-not (Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force | Out-Null }

$alias = "function greenops { & '$InstallDir\greenops.ps1' }"
$profileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
if ($profileContent -notlike "*function greenops*") {
    Add-Content $PROFILE "`n# GreenOps Monitor`n$alias"
    Write-Host "  ✅ Comando 'greenops' adicionado ao PowerShell" -ForegroundColor Green
} else {
    Write-Host "  ✅ Comando 'greenops' ja configurado" -ForegroundColor Green
}

# Carrega no shell atual
Invoke-Expression $alias

Write-Host ""
Write-Host "  ✅ Instalado com sucesso!" -ForegroundColor Green
Write-Host ""
Write-Host "  👉 Abra um novo terminal e digite: greenops" -ForegroundColor Cyan
Write-Host "  👉 Ou rode agora:  greenops" -ForegroundColor Cyan
Write-Host ""
