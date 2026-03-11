<div align="center">

# 🖥️ GreenOps Monitor

**Sistema de Monitoramento Local de Hardware com IA Acessível**

[![Python](https://img.shields.io/badge/Python-3.10+-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://python.org)
[![MCP](https://img.shields.io/badge/MCP-Model_Context_Protocol-00B4D8?style=for-the-badge)](https://modelcontextprotocol.io)
[![Windows](https://img.shields.io/badge/Windows-11-0078D6?style=for-the-badge&logo=windows&logoColor=white)](https://microsoft.com)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

*Monitoramento inteligente que roda no seu hardware, sem cloud, sem custos.*

</div>

---

## 📋 Sobre o Projeto

O **GreenOps Monitor** é um sistema de monitoramento de hardware projetado para rodar **100% localmente** em um notebook pessoal. Ele coleta métricas de CPU, RAM e Disco em tempo real, gera relatórios automatizados em Markdown, e expõe os dados via **Model Context Protocol (MCP)** para que agentes de IA possam analisar a saúde da máquina e sugerir ações de manutenção.

### 🎯 Por que este projeto existe?

- Demonstrar que **IA acessível + automação local** são viáveis sem infraestrutura cloud cara
- Criar um pipeline completo: coleta → análise IA → automação → versionamento
- Servir como projeto de portfólio que une **hardware, software e inteligência artificial**

---

## 🏗️ Arquitetura

```
┌─────────────────────────────────────────────────────────┐
│                    Dell Inspiron 15                      │
│                i5 7ª Gen · 16GB RAM · Windows            │
│                                                         │
│  ┌──────────────┐    ┌──────────────┐    ┌───────────┐  │
│  │  monitor.py   │───▶│status_hard   │───▶│  Git Push  │  │
│  │  (psutil)     │    │  ware.md     │    │  (GitHub)  │  │
│  └──────────────┘    └──────┬───────┘    └───────────┘  │
│                             │                           │
│  ┌──────────────┐    ┌──────▼───────┐                   │
│  │hardware_mcp  │◀──▶│  Agente IA   │                   │
│  │  .py (MCP)   │    │ (analista    │                   │
│  │              │    │   .agent)    │                   │
│  └──────────────┘    └──────────────┘                   │
│                                                         │
│  ┌──────────────────────────────────────────────────┐   │
│  │  deploy_saude.ps1 — Pipeline de Automação         │   │
│  │  Coleta → Análise IA → Commit → Push              │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

---

## 📁 Estrutura de Arquivos

```
GreenOps Monitor/
├── hardware_mcp.py      # 🔌 Servidor MCP — expõe métricas para agentes de IA
├── monitor.py           # 📊 Coletor — gera relatório markdown com psutil
├── analista.agent       # 🤖 System Prompt — instruções do agente SRE
├── deploy_saude.ps1     # ⚡ Automação — pipeline coleta → IA → Git
├── status_hardware.md   # 📄 Relatório — gerado automaticamente
├── requirements.txt     # 📦 Dependências Python
├── .gitignore           # 🚫 Exclusões do Git
└── README.md            # 📖 Este arquivo
```

---

## 🚀 Como Usar

### Pré-requisitos

- Python 3.10+
- Windows 10/11
- Git instalado

### 1. Instalar dependências

```bash
pip install -r requirements.txt
```

### 2. Gerar relatório de saúde

```bash
python monitor.py
```

O relatório será salvo em `status_hardware.md` com métricas de CPU, RAM e Disco.

### 3. Iniciar servidor MCP

```bash
python hardware_mcp.py
```

O servidor expõe a ferramenta `get_system_health` via protocolo MCP para qualquer agente de IA compatível.

### 4. Pipeline completo (PowerShell)

```powershell
.\deploy_saude.ps1
```

Executa coleta de métricas automaticamente. Descomente as seções de IA e Git no script para automação completa.

---

## 🔧 Stack Tecnológica

| Componente | Tecnologia | Função |
|---|---|---|
| **Coleta de Dados** | `psutil` | Métricas de hardware em tempo real |
| **Protocolo IA** | `FastMCP` | Exposição de dados via Model Context Protocol |
| **Automação** | `PowerShell` | Pipeline de execução e deploy |
| **Relatórios** | `Markdown` | Formato portável e versionável |
| **Versionamento** | `Git/GitHub` | Histórico de saúde da máquina |

---

## 📊 Exemplo de Relatório

Após executar `python monitor.py`, o arquivo `status_hardware.md` conterá:

- ✅ Status geral do sistema (Saudável / Atenção / Crítico)
- 📋 Info do sistema (OS, hostname, processador)
- 📊 Métricas detalhadas com tabelas (CPU, RAM, Disco)
- 🚨 Alertas automáticos quando thresholds são ultrapassados

---

## 🤖 Integração com IA via MCP

O arquivo `hardware_mcp.py` cria um servidor **Model Context Protocol** que permite que qualquer agente de IA conectado consuma métricas em tempo real:

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

O agente pode chamar a ferramenta `get_system_health()` e receber um JSON completo com CPU, RAM, Disco, alertas e status geral.

---

## 👤 Sobre o Autor

**Autodidata. Hardware + IA. Soluções que rodam localmente.**

Sou profissional de tecnologia focado em **suporte técnico, montagem de computadores e automação prática**. Minha filosofia é simples: tecnologia boa é tecnologia que funciona no seu hardware, sem depender de cloud caro ou infraestrutura complexa.

Acredito que **IA acessível** não é sobre ter o melhor GPU ou a subscription mais cara — é sobre entender seus dados, automatizar o que importa, e fazer mais com o que você já tem. Este projeto é a prova disso: um notebook i5 com 16GB de RAM rodando monitoramento inteligente com MCP e agentes de IA.

**Áreas de atuação:**
- 🔧 Suporte técnico e montagem de hardware
- 🤖 Automação local com Python e PowerShell
- 🧠 Integração de IA acessível via MCP
- 📊 Monitoramento e diagnóstico de sistemas

---

<div align="center">

*Feito com 🟢 Python, hardware real e a filosofia de que IA boa roda no seu notebook.*

</div>
