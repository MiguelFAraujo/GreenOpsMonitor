<#
╔══════════════════════════════════════════════════════════════╗
║  GreenOps Monitor — Pipeline de Automação                   ║
║  Coleta métricas → Análise IA → Commit GitHub               ║
╚══════════════════════════════════════════════════════════════╝
#>

# ── Configuração ─────────────────────────────────────────────
$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition

Write-Host ""
Write-Host "╔══════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  🟢 GreenOps Monitor — Deploy Pipeline       ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ── Etapa 1: Verificar dependências ─────────────────────────
Write-Host "[1/4] 🔍 Verificando dependências..." -ForegroundColor Yellow

$pythonCmd = if (Get-Command python -ErrorAction SilentlyContinue) { "python" }
             elseif (Get-Command python3 -ErrorAction SilentlyContinue) { "python3" }
             else { $null }

if (-not $pythonCmd) {
    Write-Host "  ❌ Python não encontrado. Instale: https://python.org" -ForegroundColor Red
    exit 1
}

Write-Host "  ✅ Python encontrado: $pythonCmd" -ForegroundColor Green

# Verifica se psutil está instalado
$psutilCheck = & $pythonCmd -c "import psutil" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ⚠️  psutil não encontrado. Instalando..." -ForegroundColor Yellow
    & $pythonCmd -m pip install psutil --quiet
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ❌ Falha ao instalar psutil." -ForegroundColor Red
        exit 1
    }
    Write-Host "  ✅ psutil instalado com sucesso." -ForegroundColor Green
} else {
    Write-Host "  ✅ psutil disponível." -ForegroundColor Green
}

# ── Etapa 2: Coletar métricas ───────────────────────────────
Write-Host ""
Write-Host "[2/4] 📊 Coletando métricas de hardware..." -ForegroundColor Yellow

& $pythonCmd "$ProjectRoot\monitor.py"

if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✅ Relatório gerado — sistema saudável." -ForegroundColor Green
} elseif ($LASTEXITCODE -eq 1) {
    Write-Host "  ⚠️  Relatório gerado — alertas detectados!" -ForegroundColor Yellow
} else {
    Write-Host "  ❌ Erro ao executar monitor.py (exit code: $LASTEXITCODE)" -ForegroundColor Red
    exit 1
}

# ── Etapa 3: Análise IA via Antigravity (comentado) ─────────
Write-Host ""
Write-Host "[3/4] 🤖 Análise IA (Antigravity)..." -ForegroundColor Yellow

# Descomente a linha abaixo para ativar a análise IA:
# antigravity run "Leia o arquivo analista.agent e analise o status_hardware.md. Gere um diagnóstico técnico e uma mensagem de commit."

Write-Host "  ⏭️  Etapa IA desativada (descomente no script para ativar)." -ForegroundColor DarkGray

# ── Etapa 4: Git commit & push (comentado) ──────────────────
Write-Host ""
Write-Host "[4/4] 📤 Git commit & push..." -ForegroundColor Yellow

# Descomente as linhas abaixo para ativar o push automático:
# Set-Location $ProjectRoot
# git add status_hardware.md
# $commitMsg = "chore(monitor): relatório de saúde — $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
# git commit -m $commitMsg
# git push origin main

Write-Host "  ⏭️  Git push desativado (descomente no script para ativar)." -ForegroundColor DarkGray

# ── Resultado ────────────────────────────────────────────────
Write-Host ""
Write-Host "╔══════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  ✅ Pipeline concluído com sucesso!           ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
