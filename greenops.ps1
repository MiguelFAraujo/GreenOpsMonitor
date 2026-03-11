<#
  GreenOps Monitor - Interactive Dashboard
  PowerShell CLI for real-time hardware monitoring
#>

$ErrorActionPreference = "SilentlyContinue"
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition

# -- Colors -------------------------------------------------------
function Write-Color($Text, $Color = "White") { Write-Host $Text -ForegroundColor $Color -NoNewline }
function Write-ColorLine($Text, $Color = "White") { Write-Host $Text -ForegroundColor $Color }

# -- Progress bar --------------------------------------------------
function Get-Bar($Value, $Max = 100, $Width = 30) {
    $filled = [math]::Round(($Value / $Max) * $Width)
    if ($filled -gt $Width) { $filled = $Width }
    if ($filled -lt 0) { $filled = 0 }
    $empty = $Width - $filled

    if ($Value -ge 90) { $color = "Red" }
    elseif ($Value -ge 75) { $color = "Yellow" }
    else { $color = "Green" }

    $bar = ("#" * $filled) + ("-" * $empty)
    return @{ Bar = $bar; Color = $color }
}

# -- Collect metrics via Python ------------------------------------
function Get-Metrics {
    $json = & python -c @"
import psutil, json, platform, os
from datetime import datetime

cpu = psutil.cpu_percent(interval=1)
cpu_per_core = psutil.cpu_percent(interval=0, percpu=True)
mem = psutil.virtual_memory()
swap = psutil.swap_memory()
disk = psutil.disk_usage('C:\\')
freq = psutil.cpu_freq()
boot = datetime.fromtimestamp(psutil.boot_time())
uptime = datetime.now() - boot
hours = int(uptime.total_seconds() // 3600)
mins = int((uptime.total_seconds() % 3600) // 60)

net = psutil.net_io_counters()

top_procs = []
for p in sorted(psutil.process_iter(['name', 'cpu_percent', 'memory_percent']),
                key=lambda x: x.info.get('cpu_percent', 0) or 0, reverse=True)[:5]:
    try:
        info = p.info
        if info['name'] and info['cpu_percent'] is not None:
            top_procs.append({
                'name': info['name'][:20],
                'cpu': round(info['cpu_percent'], 1),
                'ram': round(info['memory_percent'], 1) if info['memory_percent'] else 0
            })
    except:
        pass

print(json.dumps({
    'cpu': cpu,
    'cpu_per_core': cpu_per_core,
    'ram': round(mem.percent, 1),
    'ram_used': round(mem.used / (1024**3), 1),
    'ram_total': round(mem.total / (1024**3), 1),
    'ram_available': round(mem.available / (1024**3), 1),
    'swap': round(swap.percent, 1),
    'swap_total': round(swap.total / (1024**3), 1),
    'disk': round(disk.percent, 1),
    'disk_used': round(disk.used / (1024**3), 1),
    'disk_total': round(disk.total / (1024**3), 1),
    'disk_free': round(disk.free / (1024**3), 1),
    'cores_physical': psutil.cpu_count(logical=False),
    'cores_logical': psutil.cpu_count(logical=True),
    'freq': round(freq.current, 0) if freq else 0,
    'os': f'{platform.system()} {platform.release()}',
    'arch': platform.architecture()[0],
    'host': platform.node(),
    'processor': platform.processor()[:40] if platform.processor() else 'N/A',
    'python': platform.python_version(),
    'uptime': f'{hours}h {mins}m',
    'net_sent': round(net.bytes_sent / (1024**2), 1),
    'net_recv': round(net.bytes_recv / (1024**2), 1),
    'processes': len(list(psutil.process_iter())),
    'top_procs': top_procs,
    'time': datetime.now().strftime('%H:%M:%S'),
    'date': datetime.now().strftime('%d/%m/%Y')
}))
"@ 2>$null

    return $json | ConvertFrom-Json
}

# -- Main screen ---------------------------------------------------
function Show-Dashboard {
    Clear-Host
    Write-ColorLine ""
    Write-ColorLine "  ========================================================" Cyan
    Write-ColorLine "         GreenOps Monitor - Dashboard           v1.0       " Cyan
    Write-ColorLine "  ========================================================" Cyan
    Write-ColorLine ""

    Write-ColorLine "  Collecting metrics..." DarkGray

    $script:metrics = Get-Metrics
    if (-not $script:metrics) {
        Write-ColorLine "  [ERROR] Failed to collect metrics. Check Python + psutil." Red
        return
    }

    $m = $script:metrics

    Clear-Host
    Write-ColorLine ""
    Write-ColorLine "  ========================================================" Cyan
    Write-ColorLine "         GreenOps Monitor - Dashboard           v1.0       " Cyan
    Write-ColorLine "  ========================================================" Cyan
    Write-ColorLine ""

    # System info
    Write-Color "   Host:      " DarkGray; Write-ColorLine "$($m.host)" White
    Write-Color "   OS:        " DarkGray; Write-ColorLine "$($m.os) ($($m.arch))" White
    Write-Color "   CPU:       " DarkGray; Write-ColorLine "$($m.processor)" White
    Write-Color "   Uptime:    " DarkGray; Write-ColorLine "$($m.uptime)" White
    Write-Color "   Processes: " DarkGray; Write-ColorLine "$($m.processes) running" White
    Write-Color "   Collected: " DarkGray; Write-ColorLine "$($m.date)  $($m.time)" White
    Write-ColorLine ""

    # Overall status
    if ($m.cpu -ge 80 -or $m.ram -ge 85 -or $m.disk -ge 90) {
        Write-ColorLine "   [!] STATUS: ATTENTION NEEDED" Yellow
    } else {
        Write-ColorLine "   [OK] STATUS: SYSTEM HEALTHY" Green
    }
    Write-ColorLine ""

    # CPU
    $cpuBar = Get-Bar $m.cpu
    Write-Color "   CPU    [" White
    Write-Color $cpuBar.Bar $cpuBar.Color
    Write-ColorLine "]  $($m.cpu)%  ($($m.cores_physical)P/$($m.cores_logical)L cores, $($m.freq) MHz)" $cpuBar.Color

    # Per-core
    if ($m.cpu_per_core) {
        $coreStr = "   Cores: "
        Write-Color $coreStr DarkGray
        $i = 0
        foreach ($c in $m.cpu_per_core) {
            $cColor = if ($c -ge 80) { "Red" } elseif ($c -ge 50) { "Yellow" } else { "Green" }
            Write-Color "C${i}:$($c)% " $cColor
            $i++
        }
        Write-ColorLine "" White
    }

    # RAM
    $ramBar = Get-Bar $m.ram
    Write-Color "   RAM    [" White
    Write-Color $ramBar.Bar $ramBar.Color
    Write-ColorLine "]  $($m.ram)%  ($($m.ram_used)/$($m.ram_total) GB, $($m.ram_available) GB free)" $ramBar.Color

    # Swap
    $swapBar = Get-Bar $m.swap
    Write-Color "   SWAP   [" White
    Write-Color $swapBar.Bar $swapBar.Color
    Write-ColorLine "]  $($m.swap)%  ($($m.swap_total) GB total)" $swapBar.Color

    # Disk
    $diskBar = Get-Bar $m.disk
    Write-Color "   DISK   [" White
    Write-Color $diskBar.Bar $diskBar.Color
    Write-ColorLine "]  $($m.disk)%  ($($m.disk_used)/$($m.disk_total) GB, $($m.disk_free) GB free)" $diskBar.Color

    # Network
    Write-ColorLine ""
    Write-Color "   NET:   " DarkGray
    Write-ColorLine "Sent: $($m.net_sent) MB  |  Recv: $($m.net_recv) MB" White

    Write-ColorLine ""
    Write-ColorLine "  --------------------------------------------------------" DarkGray

    # Top processes
    if ($m.top_procs -and $m.top_procs.Count -gt 0) {
        Write-ColorLine ""
        Write-ColorLine "   Top Processes (by CPU):" DarkGray
        foreach ($p in $m.top_procs) {
            $pColor = if ($p.cpu -ge 20) { "Yellow" } else { "White" }
            $name = $p.name.PadRight(22)
            Write-ColorLine "     $name  CPU: $($p.cpu)%   RAM: $($p.ram)%" $pColor
        }
        Write-ColorLine ""
        Write-ColorLine "  --------------------------------------------------------" DarkGray
    }
}

# -- Interactive menu -----------------------------------------------
function Show-Menu {
    Write-ColorLine ""
    Write-ColorLine "   [1] Refresh metrics" White
    Write-ColorLine "   [2] Generate report (status_hardware.md)" White
    Write-ColorLine "   [3] Generate + Push to GitHub" White
    Write-ColorLine "   [4] Start MCP server" White
    Write-ColorLine "   [0] Exit" White
    Write-ColorLine ""
    Write-Color "   Choice: " Cyan
}

# -- Actions --------------------------------------------------------
function Invoke-GenerateReport {
    Write-ColorLine ""
    Write-ColorLine "   Generating report..." Yellow
    & python "$ProjectRoot\monitor.py"
    if ($LASTEXITCODE -eq 0) {
        Write-ColorLine "   [OK] Report saved to status_hardware.md" Green
    } else {
        Write-ColorLine "   [!] Report generated with alerts" Yellow
    }
}

function Invoke-GitPush {
    Invoke-GenerateReport
    Write-ColorLine ""
    Write-ColorLine "   Pushing to GitHub..." Yellow
    Push-Location $ProjectRoot
    git add status_hardware.md
    $msg = "chore(monitor): health report - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
    git commit -m $msg
    git push
    Pop-Location
    if ($LASTEXITCODE -eq 0) {
        Write-ColorLine "   [OK] Push successful!" Green
    } else {
        Write-ColorLine "   [ERROR] Push failed. Check authentication." Red
    }
}

function Invoke-MCPServer {
    Write-ColorLine ""
    Write-ColorLine "   Starting MCP server..." Yellow
    Write-ColorLine "   (Press Ctrl+C to stop)" DarkGray
    Write-ColorLine ""
    & python "$ProjectRoot\hardware_mcp.py"
}

# -- Main loop ------------------------------------------------------
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
            Write-ColorLine ""; Write-Color "   Press Enter to go back..." DarkGray
            Read-Host
            Show-Dashboard
            Show-Menu
        }
        "3" {
            Invoke-GitPush
            Write-ColorLine ""; Write-Color "   Press Enter to go back..." DarkGray
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
            Write-ColorLine "   GreenOps Monitor closed." Cyan
            Write-ColorLine ""
            break
        }
        default {
            Write-Color "   Invalid option. Choice: " Red
        }
    }
}
