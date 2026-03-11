"""
╔══════════════════════════════════════════════════════════════╗
║  GreenOps Monitor — Coletor de Métricas                     ║
║  Gera relatório markdown com a saúde do hardware local.     ║
║  Alvo: Dell Inspiron 15 · i5 7ª Gen · 16GB RAM              ║
╚══════════════════════════════════════════════════════════════╝
"""

import psutil
import platform
import os
import sys
from datetime import datetime


# ── Thresholds de alerta ─────────────────────────────────────
CPU_WARNING = 80     # %
RAM_WARNING = 85     # %
DISK_WARNING = 90    # %

REPORT_FILE = "status_hardware.md"


def get_status_icon(value: float, threshold: float) -> str:
    """Retorna ícone de status baseado no valor vs threshold."""
    if value >= threshold:
        return "🔴"
    elif value >= threshold * 0.8:
        return "🟡"
    return "🟢"


def collect_metrics() -> dict:
    """Coleta todas as métricas de hardware de forma segura."""
    metrics = {
        "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "os_info": f"{platform.system()} {platform.release()} ({platform.architecture()[0]})",
        "hostname": platform.node(),
        "processor": platform.processor(),
        "python_version": platform.python_version(),
    }

    # ── CPU ──────────────────────────────────────────────────
    try:
        metrics["cpu_percent"] = psutil.cpu_percent(interval=1)
        metrics["cpu_cores_physical"] = psutil.cpu_count(logical=False)
        metrics["cpu_cores_logical"] = psutil.cpu_count(logical=True)
        freq = psutil.cpu_freq()
        metrics["cpu_freq_mhz"] = round(freq.current, 1) if freq else "N/A"
    except Exception as e:
        metrics["cpu_percent"] = -1
        metrics["cpu_error"] = str(e)

    # ── RAM ──────────────────────────────────────────────────
    try:
        mem = psutil.virtual_memory()
        metrics["ram_percent"] = mem.percent
        metrics["ram_total_gb"] = round(mem.total / (1024**3), 2)
        metrics["ram_used_gb"] = round(mem.used / (1024**3), 2)
        metrics["ram_available_gb"] = round(mem.available / (1024**3), 2)
    except Exception as e:
        metrics["ram_percent"] = -1
        metrics["ram_error"] = str(e)

    # ── Disco C: ─────────────────────────────────────────────
    try:
        disk = psutil.disk_usage("C:\\")
        metrics["disk_percent"] = disk.percent
        metrics["disk_total_gb"] = round(disk.total / (1024**3), 2)
        metrics["disk_free_gb"] = round(disk.free / (1024**3), 2)
        metrics["disk_used_gb"] = round(disk.used / (1024**3), 2)
    except PermissionError:
        metrics["disk_percent"] = -1
        metrics["disk_error"] = "Permissão negada para acessar C:\\"
    except Exception as e:
        metrics["disk_percent"] = -1
        metrics["disk_error"] = str(e)

    return metrics


def generate_report(metrics: dict) -> str:
    """Gera relatório markdown formatado com as métricas coletadas."""

    cpu = metrics.get("cpu_percent", -1)
    ram = metrics.get("ram_percent", -1)
    disk = metrics.get("disk_percent", -1)

    cpu_icon = get_status_icon(cpu, CPU_WARNING) if cpu >= 0 else "⚠️"
    ram_icon = get_status_icon(ram, RAM_WARNING) if ram >= 0 else "⚠️"
    disk_icon = get_status_icon(disk, DISK_WARNING) if disk >= 0 else "⚠️"

    # Status geral
    if cpu >= CPU_WARNING or ram >= RAM_WARNING or disk >= DISK_WARNING:
        overall = "⚠️ ATENÇÃO NECESSÁRIA"
    else:
        overall = "✅ SISTEMA SAUDÁVEL"

    # Alertas
    alerts = []
    if cpu >= CPU_WARNING:
        alerts.append(f"- 🔴 **CPU em {cpu}%** — Verificar processos pesados no Task Manager")
    if ram >= RAM_WARNING:
        alerts.append(f"- 🔴 **RAM em {ram}%** — Considere fechar aplicações ou limpar cache")
    if disk >= DISK_WARNING:
        alerts.append(f"- 🔴 **Disco C: em {disk}%** — Espaço em disco crítico, executar limpeza")

    alerts_section = "\n".join(alerts) if alerts else "- ✅ Nenhum alerta ativo. Todos os componentes dentro dos limites."

    report = f"""# 🖥️ GreenOps Monitor — Relatório de Saúde

> **Status Geral:** {overall}
> **Gerado em:** {metrics['timestamp']}

---

## 📋 Informações do Sistema

| Propriedade | Valor |
|---|---|
| **Hostname** | `{metrics['hostname']}` |
| **Sistema Operacional** | {metrics['os_info']} |
| **Processador** | {metrics.get('processor', 'N/A')} |
| **Python** | {metrics.get('python_version', 'N/A')} |

---

## 📊 Métricas de Hardware

### {cpu_icon} CPU
| Métrica | Valor |
|---|---|
| **Uso** | **{cpu}%** |
| **Cores Físicos** | {metrics.get('cpu_cores_physical', 'N/A')} |
| **Cores Lógicos** | {metrics.get('cpu_cores_logical', 'N/A')} |
| **Frequência** | {metrics.get('cpu_freq_mhz', 'N/A')} MHz |

### {ram_icon} RAM
| Métrica | Valor |
|---|---|
| **Uso** | **{ram}%** |
| **Total** | {metrics.get('ram_total_gb', 'N/A')} GB |
| **Em Uso** | {metrics.get('ram_used_gb', 'N/A')} GB |
| **Disponível** | {metrics.get('ram_available_gb', 'N/A')} GB |

### {disk_icon} Disco C:
| Métrica | Valor |
|---|---|
| **Uso** | **{disk}%** |
| **Total** | {metrics.get('disk_total_gb', 'N/A')} GB |
| **Usado** | {metrics.get('disk_used_gb', 'N/A')} GB |
| **Livre** | {metrics.get('disk_free_gb', 'N/A')} GB |

---

## 🚨 Alertas

{alerts_section}

---

> *Relatório gerado automaticamente pelo GreenOps Monitor*
> *Thresholds: CPU > {CPU_WARNING}% | RAM > {RAM_WARNING}% | Disco > {DISK_WARNING}%*
"""
    return report


# ── Ponto de entrada ─────────────────────────────────────────
if __name__ == "__main__":
    print("🟢 GreenOps Monitor — Coletando métricas...")

    metrics = collect_metrics()
    report = generate_report(metrics)

    # Salva o relatório
    script_dir = os.path.dirname(os.path.abspath(__file__))
    report_path = os.path.join(script_dir, REPORT_FILE)

    with open(report_path, "w", encoding="utf-8") as f:
        f.write(report)

    print(f"✅ Relatório salvo em: {report_path}")

    # Resumo no terminal
    cpu = metrics.get("cpu_percent", -1)
    ram = metrics.get("ram_percent", -1)
    disk = metrics.get("disk_percent", -1)
    print(f"   CPU: {cpu}% | RAM: {ram}% | Disco: {disk}%")

    # Exit code baseado em alertas
    if cpu >= CPU_WARNING or ram >= RAM_WARNING or disk >= DISK_WARNING:
        print("⚠️  Alertas detectados — verifique o relatório.")
        sys.exit(1)
    else:
        print("✅ Sistema saudável — nenhum alerta.")
        sys.exit(0)