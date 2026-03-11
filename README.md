<div align="center">

# GreenOps Monitor

**Local hardware monitoring with AI-ready data — straight from your terminal.**

[![Python](https://img.shields.io/badge/Python-3.10+-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://python.org)
[![MCP](https://img.shields.io/badge/MCP-Model_Context_Protocol-00B4D8?style=for-the-badge)](https://modelcontextprotocol.io)
[![psutil](https://img.shields.io/badge/psutil-Hardware_Metrics-4B8BBE?style=for-the-badge)](https://github.com/giampaolo/psutil)
[![PowerShell](https://img.shields.io/badge/PowerShell-Automation-5391FE?style=for-the-badge&logo=powershell&logoColor=white)](https://docs.microsoft.com/powershell)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

*No cloud. No subscriptions. Just your hardware and a Python script.*

</div>

---

## Quick Start (one line)

Open **PowerShell** and paste:

```powershell
irm https://raw.githubusercontent.com/MiguelFAraujo/GreenOpsMonitor/master/install.ps1 | iex
```

Then, from any terminal:

```powershell
greenops
```

That's it. You'll see a live dashboard like this:

```
  ========================================================
         GreenOps Monitor - Dashboard           v1.0
  ========================================================

   Host:      DESKTOP-PC
   OS:        Windows 11 (64bit)
   CPU:       Intel64 Family 6 Model 142
   Uptime:    4h 23m
   Processes: 187 running

   [OK] STATUS: SYSTEM HEALTHY

   CPU    [#########---------------------]  31.2%  (2P/4L cores, 2500 MHz)
   Cores: C0:28.1% C1:35.0% C2:29.4% C3:32.3%
   RAM    [################--------------]  54.4%  (8.7/15.9 GB, 7.2 GB free)
   SWAP   [###---------------------------]  12.1%  (2.4 GB total)
   DISK   [#####################---------]  72.2%  (322/446 GB, 124 GB free)

   NET:   Sent: 1245.3 MB  |  Recv: 3891.7 MB

   Top Processes (by CPU):
     chrome.exe              CPU: 8.2%   RAM: 4.1%
     Code.exe                CPU: 3.1%   RAM: 2.8%
     python.exe              CPU: 2.4%   RAM: 1.2%

   [1] Refresh    [2] Report    [3] Push GitHub    [4] MCP Server    [0] Exit
```

---

## What is this?

GreenOps Monitor is a **local-first hardware monitoring system** that runs entirely on your machine. It collects real-time CPU, RAM, Disk, Network, and Process metrics, then presents them through:

- **Interactive CLI dashboard** with color-coded progress bars
- **Markdown reports** you can version-control with Git
- **MCP server** that exposes your hardware data to AI agents
- **AI agent prompt** for automated health diagnosis
- **PowerShell automation pipeline** for scheduled monitoring

### Why does this exist?

Most monitoring tools require cloud infrastructure, recurring costs, or complex setups. This project proves that **practical monitoring + AI analysis can run on any notebook** — no servers, no subscriptions, no overhead. Just Python, PowerShell, and the Model Context Protocol.

---

## Architecture

```
+-------------------------------------------------------------+
|                    Your Machine (Windows)                    |
|                                                             |
|   greenops.ps1                                              |
|   [Interactive Dashboard] ---- Real-time metrics on screen  |
|        |                                                    |
|   monitor.py (psutil)                                       |
|   [Metric Collector] --------> status_hardware.md           |
|        |                            |                       |
|   hardware_mcp.py                   |                       |
|   [MCP Server] <--- AI Agent -------+                       |
|                     (analista.agent)                        |
|                                                             |
|   deploy_saude.ps1                                          |
|   [Automation Pipeline] --> Collect > Report > Git Push     |
|                                                             |
|   install.ps1                                               |
|   [One-line Installer] --> Clone + Setup + Global Alias     |
+-------------------------------------------------------------+
```

---

## Project Structure

```
GreenOpsMonitor/
|-- greenops.ps1         # Interactive CLI dashboard (main entry point)
|-- install.ps1          # One-line installer script
|-- hardware_mcp.py      # MCP server exposing metrics to AI agents
|-- monitor.py           # Metric collector, generates Markdown reports
|-- analista.agent       # AI agent system prompt (SRE specialist)
|-- deploy_saude.ps1     # Automation pipeline (collect > analyze > push)
|-- requirements.txt     # Python dependencies
|-- status_hardware.md   # Auto-generated health report
'-- README.md            # This file
```

---

## Tools & Technologies

| Tool | Version | Purpose | Why this tool? |
|---|---|---|---|
| **Python** | 3.10+ | Core language for all scripts | Universal, readable, rich ecosystem for system monitoring |
| **psutil** | 5.9+ | Cross-platform hardware metrics | De facto standard for Python system monitoring — CPU, RAM, Disk, Network, Processes |
| **FastMCP** | 1.0+ | Model Context Protocol server | Standardized protocol for exposing data to AI agents (Claude, GPT, etc.) |
| **PowerShell** | 5.1+ | Dashboard UI and automation | Native Windows shell with rich formatting, no external dependencies needed |
| **Git** | 2.x | Version control for health reports | Track hardware health history over time, like a health log for your machine |
| **GitHub CLI** | 2.x | Repository management | Enables one-line install via `irm | iex` pattern and automated pushes |

### Key Design Decisions

- **No external UI framework** — The dashboard runs in plain PowerShell, no Electron, no web server, no extra processes eating your RAM
- **ASCII-only output** — Ensures compatibility across all Windows terminal versions (CMD, PowerShell 5, PowerShell 7, Windows Terminal)
- **Python for data, PowerShell for UI** — Each tool does what it's best at: Python handles cross-platform system APIs, PowerShell handles Windows-native display
- **MCP over REST API** — The Model Context Protocol is purpose-built for AI agent communication, making integration trivial for any MCP-compatible client

---

## Features

### Dashboard (`greenops`)
- Real-time CPU, RAM, Swap, Disk usage with color-coded bars
- Per-core CPU breakdown
- Network I/O (sent/received)
- Top 5 processes by CPU usage
- System info: hostname, OS, uptime, process count
- Interactive menu for all operations

### Reports (`monitor.py`)
- Generates `status_hardware.md` with full system snapshot
- Automatic alerts when thresholds are exceeded (CPU > 80%, RAM > 85%, Disk > 90%)
- Status icons and formatted tables
- Designed to be readable both in terminal and on GitHub

### MCP Server (`hardware_mcp.py`)
- Exposes `get_system_health()` tool via Model Context Protocol
- Returns JSON with CPU, RAM, Disk metrics + alerts + overall status
- Handles Windows permission errors gracefully
- Ready for integration with Claude, ChatGPT, or any MCP client

### AI Agent (`analista.agent`)
- System prompt for an SRE specialist AI
- Reads `status_hardware.md` or calls MCP for real-time data
- Diagnoses health issues with specific thresholds
- Recommends actions: close processes, clean disk, check startup programs
- Generates Git commit messages automatically

---

## MCP Integration

Add to your AI client's MCP configuration:

```json
{
  "mcpServers": {
    "greenops": {
      "command": "python",
      "args": ["path/to/hardware_mcp.py"]
    }
  }
}
```

The AI agent calls `get_system_health()` and receives:

```json
{
  "status": "healthy",
  "cpu": { "usage_percent": 31.2, "cores_physical": 2, "cores_logical": 4 },
  "ram": { "usage_percent": 54.4, "total_gb": 15.9, "available_gb": 7.25 },
  "disk": { "usage_percent": 72.2, "total_gb": 446.28, "free_gb": 124.16 },
  "alerts": []
}
```

---

## Prerequisites

- **Python 3.10+** — [python.org](https://python.org)
- **Git** — [git-scm.com](https://git-scm.com)
- **Windows 10/11**

The installer handles everything else (`psutil`, global command).

---

## Manual Installation

If you prefer not to use the one-liner:

```bash
git clone https://github.com/MiguelFAraujo/GreenOpsMonitor.git
cd GreenOpsMonitor
pip install -r requirements.txt
.\greenops.ps1
```

---

## Contributing

Contributions are welcome! This is an open-source project.

1. Fork the repository
2. Create your branch: `git checkout -b my-feature`
3. Commit: `git commit -m 'feat: my feature'`
4. Push: `git push origin my-feature`
5. Open a Pull Request

---

## About the Author

**Self-taught. Hardware + AI. Solutions that run locally.**

I'm a technology professional focused on technical support, computer assembly, and practical automation. My philosophy is simple: good technology is technology that runs on your hardware — no expensive cloud, no complex infrastructure.

Accessible AI isn't about having the best GPU or the most expensive subscription — it's about understanding your data, automating what matters, and doing more with what you already have. This project is proof of that: a regular i5 notebook with 16GB of RAM running intelligent monitoring with MCP and AI agents.

**Areas:** Technical support | Local automation (Python/PowerShell) | Accessible AI via MCP | System diagnostics

---

## License

This project is open source under the [MIT License](LICENSE).

<div align="center">

*Built with Python, real hardware, and the philosophy that good AI runs on your notebook.*

</div>
