<#
  GreenOps Monitor - Dashboard Interativo
  Interface no PowerShell
#>

$ErrorActionPreference = "SilentlyContinue"
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition

# -- Cores -------------------------------------------------------
function Write-Color($Text, $Color = "White") { Write-Host $Text -ForegroundColor $Color -NoNewline }
function Write-ColorLine($Text, $Color = "White") { Write-Host $Text -ForegroundColor $Color }

# -- Barra de progresso visual ------------------------------------
function Get-Bar($Value, $Max = 100, $Width = 30) {
    $filled = [math]::Round(($Value / $Max) * $Width)
    $empty = $Width - $filled

    if ($Value -ge 90) { $color = "Red" }
    elseif ($Value -ge 75) { $color = "Yellow" }
    else { $color = "Green" }

    $bar = ("#" * $filled) + ("-" * $empty)
    return @{ Bar = $bar; Color = $color }
}

# -- Coleta de metricas via Python --------------------------------
function Get-Metrics {
    $json = & python -c @"
import psutil, json, platform
from datetime import datetime
cpu = psutil.cpu_percent(interval=1)
mem = psutil.virtual_memory()
disk = psutil.disk_usage('C:\\')
freq = psutil.cpu_freq()
print(json.dumps({
    'cpu': cpu,
    'ram': round(mem.percent, 1),
    'ram_used': round(mem.used / (1024**3), 1),
    'ram_total': round(mem.total / (1024**3), 1),
    'disk': round(disk.percent, 1),
    'disk_used': round(disk.used / (1024**3), 1),
    'disk_total': round(disk.total / (1024**3), 1),
    'disk_free': round(disk.free / (1024**3), 1),
    'cores': psutil.cpu_count(logical=True),
    'freq': round(freq.current, 0) if freq else 0,
    'os': f'{platform.system()} {platform.release()}',
    'host': platform.node(),
    'time': datetime.now().strftime('%H:%M:%S'),
    'date': datetime.now().strftime('%d/%m/%Y')
}))
"@ 2>$null

    return $json | ConvertFrom-Json
}

# -- Tela principal -----------------------------------------------
function Show-Dashboard {
    Clear-Host
    Write-ColorLine ""
    Write-ColorLine "  ========================================================" Cyan
    Write-ColorLine "         GreenOps Monitor - Dashboard                      " Cyan
    Write-ColorLine "  ========================================================" Cyan
    Write-ColorLine ""

    Write-ColorLine "  Coletando metricas..." DarkGray

    $script:metrics = Get-Metrics
    if (-not $script:metrics) {
        Write-ColorLine "  [ERRO] Falha ao coletar metricas. Verifique Python e psutil." Red
        return
    }

    $m = $script:metrics

    Clear-Host
    Write-ColorLine ""
    Write-ColorLine "  ========================================================" Cyan
    Write-ColorLine "         GreenOps Monitor - Dashboard                      " Cyan
    Write-ColorLine "  ========================================================" Cyan
    Write-ColorLine ""

    # Info do sistema
    Write-Color "   Host: " DarkGray; Write-ColorLine "$($m.host)" White
    Write-Color "   OS:   " DarkGray; Write-ColorLine "$($m.os)" White
    Write-Color "   Data: " DarkGray; Write-ColorLine "$($m.date)  $($m.time)" White
    Write-ColorLine ""

    # Status geral
    if ($m.cpu -ge 80 -or $m.ram -ge 85 -or $m.disk -ge 90) {
        Write-ColorLine "   [!] STATUS: ATENCAO NECESSARIA" Yellow
    } else {
        Write-ColorLine "   [OK] STATUS: SISTEMA SAUDAVEL" Green
    }
    Write-ColorLine ""

    # CPU
    $cpuBar = Get-Bar $m.cpu
    Write-Color "   CPU    [" White
    Write-Color $cpuBar.Bar $cpuBar.Color
    Write-ColorLine "]  $($m.cpu)%  ($($m.cores) cores, $($m.freq) MHz)" $cpuBar.Color

    # RAM
    $ramBar = Get-Bar $m.ram
    Write-Color "   RAM    [" White
    Write-Color $ramBar.Bar $ramBar.Color
    Write-ColorLine "]  $($m.ram)%  ($($m.ram_used)/$($m.ram_total) GB)" $ramBar.Color

    # Disco
    $diskBar = Get-Bar $m.disk
    Write-Color "   DISCO  [" White
    Write-Color $diskBar.Bar $diskBar.Color
    Write-ColorLine "]  $($m.disk)%  ($($m.disk_used)/$($m.disk_total) GB, $($m.disk_free) GB livre)" $diskBar.Color

    Write-ColorLine ""
    Write-ColorLine "  --------------------------------------------------------" DarkGray
}

# -- Menu interativo -----------------------------------------------
function Show-Menu {
    Write-ColorLine ""
    Write-ColorLine "   [1] Atualizar metricas" White
    Write-ColorLine "   [2] Gerar relatorio (status_hardware.md)" White
    Write-ColorLine "   [3] Gerar + Push GitHub" White
    Write-ColorLine "   [4] Iniciar servidor MCP" White
    Write-ColorLine "   [0] Sair" White
    Write-ColorLine ""
    Write-Color "   Escolha: " Cyan
}

# -- Acoes ----------------------------------------------------------
function Invoke-GenerateReport {
    Write-ColorLine ""
    Write-ColorLine "   Gerando relatorio..." Yellow
    & python "$ProjectRoot\monitor.py"
    if ($LASTEXITCODE -eq 0) {
        Write-ColorLine "   [OK] Relatorio salvo em status_hardware.md" Green
    } else {
        Write-ColorLine "   [!] Relatorio gerado com alertas" Yellow
    }
}

function Invoke-GitPush {
    Invoke-GenerateReport
    Write-ColorLine ""
    Write-ColorLine "   Enviando para GitHub..." Yellow
    Push-Location $ProjectRoot
    git add status_hardware.md
    $msg = "chore(monitor): saude - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
    git commit -m $msg
    git push
    Pop-Location
    if ($LASTEXITCODE -eq 0) {
        Write-ColorLine "   [OK] Push realizado com sucesso!" Green
    } else {
        Write-ColorLine "   [ERRO] Falha no push. Verifique autenticacao." Red
    }
}

function Invoke-MCPServer {
    Write-ColorLine ""
    Write-ColorLine "   Iniciando servidor MCP..." Yellow
    Write-ColorLine "   (Pressione Ctrl+C para parar)" DarkGray
    Write-ColorLine ""
    & python "$ProjectRoot\hardware_mcp.py"
}

# -- Loop principal -------------------------------------------------
Show-Dashboard
Show-Menu

while ($true) {
    $choice = Read-Host

    switch ($choice) {
        "1" {
            Show-Dashboard
            Show-Menu
        }
        "2" {
            Invoke-GenerateReport
            Write-ColorLine ""; Write-Color "   Pressione Enter para voltar..." DarkGray
            Read-Host
            Show-Dashboard
            Show-Menu
        }
        "3" {
            Invoke-GitPush
            Write-ColorLine ""; Write-Color "   Pressione Enter para voltar..." DarkGray
            Read-Host
            Show-Dashboard
            Show-Menu
        }
        "4" {
            Invoke-MCPServer
            Show-Dashboard
            Show-Menu
        }
        "0" {
            Write-ColorLine ""
            Write-ColorLine "   GreenOps Monitor encerrado." Cyan
            Write-ColorLine ""
            break
        }
        default {
            Write-Color "   Opcao invalida. Escolha: " Red
        }
    }
}
