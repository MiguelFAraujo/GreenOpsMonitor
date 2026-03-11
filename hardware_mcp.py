"""
╔══════════════════════════════════════════════════════════════╗
║  GreenOps Monitor — MCP Server                              ║
║  Expõe métricas de hardware via Model Context Protocol      ║
║  para consumo por agentes de IA.                            ║
╚══════════════════════════════════════════════════════════════╝
"""

from mcp.server.fastmcp import FastMCP
import psutil
import platform
from datetime import datetime

# ── Inicializa o servidor MCP ────────────────────────────────
mcp = FastMCP(
    "GreenOps Monitor",
    description="Servidor MCP para monitoramento de saúde do hardware local"
)


@mcp.tool()
def get_system_health() -> dict:
    """
    Coleta métricas de saúde do sistema em tempo real.

    Retorna um dicionário com:
    - CPU: percentual de uso atual
    - RAM: percentual de uso e valores absolutos (GB)
    - Disco C:: percentual de uso, espaço total e livre (GB)
    - Info: hostname, sistema operacional, timestamp

    Trata erros de permissão do Windows graciosamente.
    """
    result = {
        "timestamp": datetime.now().isoformat(),
        "hostname": platform.node(),
        "os": f"{platform.system()} {platform.release()}",
        "cpu": {},
        "ram": {},
        "disk": {},
        "status": "healthy",
        "alerts": []
    }

    # ── CPU ──────────────────────────────────────────────────
    try:
        cpu_percent = psutil.cpu_percent(interval=1)
        cpu_count_logical = psutil.cpu_count(logical=True)
        cpu_count_physical = psutil.cpu_count(logical=False)
        cpu_freq = psutil.cpu_freq()

        result["cpu"] = {
            "usage_percent": cpu_percent,
            "cores_physical": cpu_count_physical,
            "cores_logical": cpu_count_logical,
            "frequency_mhz": round(cpu_freq.current, 1) if cpu_freq else None
        }

        if cpu_percent > 80:
            result["alerts"].append({
                "level": "warning",
                "component": "CPU",
                "message": f"CPU em {cpu_percent}% — verificar processos pesados"
            })

    except psutil.AccessDenied:
        result["cpu"] = {"error": "Acesso negado — execute como Administrador"}
    except Exception as e:
        result["cpu"] = {"error": f"Erro ao coletar CPU: {str(e)}"}

    # ── RAM ──────────────────────────────────────────────────
    try:
        mem = psutil.virtual_memory()
        result["ram"] = {
            "usage_percent": mem.percent,
            "total_gb": round(mem.total / (1024**3), 2),
            "available_gb": round(mem.available / (1024**3), 2),
            "used_gb": round(mem.used / (1024**3), 2)
        }

        if mem.percent > 85:
            result["alerts"].append({
                "level": "critical",
                "component": "RAM",
                "message": f"RAM em {mem.percent}% — considere limpeza de processos"
            })

    except psutil.AccessDenied:
        result["ram"] = {"error": "Acesso negado — execute como Administrador"}
    except Exception as e:
        result["ram"] = {"error": f"Erro ao coletar RAM: {str(e)}"}

    # ── Disco C: ─────────────────────────────────────────────
    try:
        disk = psutil.disk_usage("C:\\")
        result["disk"] = {
            "usage_percent": disk.percent,
            "total_gb": round(disk.total / (1024**3), 2),
            "free_gb": round(disk.free / (1024**3), 2),
            "used_gb": round(disk.used / (1024**3), 2)
        }

        if disk.percent > 90:
            result["alerts"].append({
                "level": "critical",
                "component": "Disco",
                "message": f"Disco C: em {disk.percent}% — espaço crítico"
            })

    except PermissionError:
        result["disk"] = {"error": "Permissão negada para acessar C:\\"}
    except FileNotFoundError:
        result["disk"] = {"error": "Unidade C:\\ não encontrada"}
    except Exception as e:
        result["disk"] = {"error": f"Erro ao coletar Disco: {str(e)}"}

    # ── Status geral ─────────────────────────────────────────
    if any(a["level"] == "critical" for a in result["alerts"]):
        result["status"] = "critical"
    elif any(a["level"] == "warning" for a in result["alerts"]):
        result["status"] = "warning"

    return result


# ── Ponto de entrada ─────────────────────────────────────────
if __name__ == "__main__":
    print("🟢 GreenOps MCP Server iniciando...")
    print("   Conecte seu agente de IA via MCP para consumir métricas.")
    mcp.run()
