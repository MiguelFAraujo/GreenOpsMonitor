<div align="center">

# 🖥️ GreenOps Monitor

**Monitoramento local de hardware com IA acessível — direto no seu terminal.**

[![Python](https://img.shields.io/badge/Python-3.10+-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://python.org)
[![MCP](https://img.shields.io/badge/MCP-Model_Context_Protocol-00B4D8?style=for-the-badge)](https://modelcontextprotocol.io)
[![Windows](https://img.shields.io/badge/Windows-10%2F11-0078D6?style=for-the-badge&logo=windows&logoColor=white)](https://microsoft.com)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

</div>

---

## ⚡ Instalação (uma linha)

Abra o **PowerShell** e cole:

```powershell
irm https://raw.githubusercontent.com/MiguelFAraujo/GreenOpsMonitor/master/install.ps1 | iex
```

Depois, de qualquer terminal:

```powershell
greenops
```

Pronto. Dashboard com métricas de CPU, RAM e Disco na tela.

```
  ╔══════════════════════════════════════════════════════╗
  ║        🖥️  GreenOps Monitor — Dashboard             ║
  ╚══════════════════════════════════════════════════════╝

   ✅ STATUS: SISTEMA SAUDÁVEL

   CPU    ████████████░░░░░░░░░░░░░░░░░░  39.2%  (4 cores)
   RAM    ████████████████░░░░░░░░░░░░░░  54.4%  (8.7/15.9 GB)
   DISCO  █████████████████████░░░░░░░░░  72.2%  (322/446 GB)

   [1] 🔄 Atualizar    [2] 📄 Relatório
   [3] 📤 Push GitHub   [4] 🔌 Servidor MCP
```

---

## 📋 O que é

Um sistema de monitoramento de hardware que roda **100% local** no seu notebook. Sem cloud. Sem custos. Sem complicação.

- 📊 **Dashboard interativo** no PowerShell com barras coloridas
- 📄 **Relatórios em Markdown** versionáveis no Git
- 🔌 **Servidor MCP** que expõe métricas para agentes de IA
- 🤖 **Agente SRE** com diagnósticos e recomendações automáticas
- ⚡ **Pipeline de automação** — coleta → análise → commit → push

---

## 🏗️ Arquitetura

```
┌─────────────────────────────────────────────────────┐
│                 Seu Notebook (Windows)               │
│                                                     │
│  greenops.ps1 ──▶ Dashboard interativo no terminal  │
│       │                                              │
│  monitor.py ────▶ status_hardware.md ──▶ Git Push   │
│       │                                              │
│  hardware_mcp.py ◀──▶ Agente IA (analista.agent)   │
│                                                     │
│  deploy_saude.ps1 ── Pipeline automatizado          │
└─────────────────────────────────────────────────────┘
```

---

## 📁 Estrutura

```
GreenOpsMonitor/
├── greenops.ps1         # ⚡ Dashboard interativo (ponto de entrada)
├── install.ps1          # 📥 Instalador one-line
├── hardware_mcp.py      # 🔌 Servidor MCP para agentes de IA
├── monitor.py           # 📊 Coletor de métricas → Markdown
├── analista.agent       # 🤖 System Prompt do agente SRE
├── deploy_saude.ps1     # ⚙️ Pipeline de automação
├── requirements.txt     # 📦 Dependências Python
└── status_hardware.md   # 📄 Relatório gerado automaticamente
```

---

## 🔌 Integração MCP (para agentes de IA)

Adicione ao config do seu cliente MCP:

```json
{
  "mcpServers": {
    "greenops": {
      "command": "python",
      "args": ["hardware_mcp.py"]
    }
  }
}
```

O agente chama `get_system_health()` e recebe CPU, RAM, Disco, alertas e status em JSON.

---

## 🔧 Pré-requisitos

- **Python 3.10+** — [python.org](https://python.org)
- **Git** — [git-scm.com](https://git-scm.com)
- **Windows 10/11**

O instalador cuida do resto (`psutil`, alias global).

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Este é um projeto aberto.

1. Fork o repositório
2. Crie sua branch: `git checkout -b minha-feature`
3. Commit: `git commit -m 'feat: minha feature'`
4. Push: `git push origin minha-feature`
5. Abra um Pull Request

---

## 👤 Sobre o Autor

**Autodidata. Hardware + IA. Soluções que rodam localmente.**

Profissional de tecnologia focado em suporte técnico, montagem de computadores e automação prática. Minha filosofia: tecnologia boa é tecnologia que funciona no seu hardware, sem depender de cloud caro.

IA acessível não é sobre ter o melhor GPU — é sobre entender seus dados, automatizar o que importa, e fazer mais com o que você já tem.

**Áreas:** Suporte técnico · Automação local (Python/PowerShell) · IA acessível via MCP · Diagnóstico de sistemas

---

## 📄 Licença

Este projeto é open source sob a licença [MIT](LICENSE).

<div align="center">

*Feito com 🟢 Python, hardware real e a filosofia de que IA boa roda no seu notebook.*

</div>
