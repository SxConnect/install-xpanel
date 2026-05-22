# 🌍 XPanel - Suporte Multi-Plataforma

## ✅ Sistemas Operacionais Suportados

O XPanel funciona em **3 sistemas operacionais**:

```
┌─────────────────────────────────────────────────────────────┐
│                  XPANEL - COMPATIBILIDADE                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ✅ Linux (Ubuntu/Debian)    - Produção                    │
│  ✅ macOS (10.15+)            - Desenvolvimento             │
│  ✅ Windows (10/11)           - Desenvolvimento             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🚀 Instalação Universal

### Um único comando para todos os sistemas!

```bash
curl -fsSL https://raw.githubusercontent.com/sxconnect/install-xpanel/main/install.sh | bash
```

**O instalador detecta automaticamente:**
- ✅ Sistema operacional (Linux, macOS, Windows)
- ✅ Distribuição Linux (Ubuntu, Debian)
- ✅ Arquitetura (x86_64, ARM64)
- ✅ Dependências necessárias
- ✅ Configurações específicas do sistema

---

## 🐧 Linux (Ubuntu/Debian)

### Sistemas Suportados

| Distribuição | Versões | Status |
|--------------|---------|--------|
| **Ubuntu** | 20.04, 22.04, 24.04 | ✅ Testado |
| **Debian** | 11, 12 | ✅ Testado |
| **Ubuntu Server** | 20.04+ | ✅ Recomendado |

### Arquiteturas

- ✅ x86_64 (AMD64) - Totalmente suportado
- ✅ ARM64 (aarch64) - Suportado via Docker

### Instalação

```bash
# Como root ou com sudo
curl -fsSL https://raw.githubusercontent.com/sxconnect/install-xpanel/main/install.sh | sudo bash
```

### O que é instalado?

1. Docker e Docker Compose
2. PostgreSQL (via container)
3. XPanel Backend (via container)
4. XPanel Frontend (via container)
5. Firewall (UFW) configurado

### Porta de Acesso

**Porta 80** → `http://SEU_IP_DO_SERVIDOR`

### Uso Recomendado

- ✅ Servidores VPS
- ✅ Servidores dedicados
- ✅ Cloud (AWS, DigitalOcean, Linode, etc.)
- ✅ Produção

---

## 🍎 macOS

### Sistemas Suportados

| Versão | Status | Notas |
|--------|--------|-------|
| **macOS 15 (Sequoia)** | ✅ Testado | Recomendado |
| **macOS 14 (Sonoma)** | ✅ Testado | Recomendado |
| **macOS 13 (Ventura)** | ✅ Suportado | - |
| **macOS 12 (Monterey)** | ✅ Suportado | - |
| **macOS 11 (Big Sur)** | ✅ Suportado | - |
| **macOS 10.15 (Catalina)** | ⚠️ Limitado | Docker Desktop pode ter limitações |

### Arquiteturas

- ✅ Apple Silicon (M1, M2, M3, M4) - ARM64
- ✅ Intel (x86_64)

### Pré-requisitos

**Docker Desktop** é necessário. O instalador oferece 2 opções:

1. **Instalação via Homebrew** (automática)
2. **Download manual** (link fornecido)

### Instalação

```bash
# Instalação automática
curl -fsSL https://raw.githubusercontent.com/sxconnect/install-xpanel/main/install.sh | bash
```

### O que é instalado?

1. Homebrew (se não estiver instalado)
2. Docker Desktop (opcional, via Homebrew)
3. XPanel containers (PostgreSQL, Backend, Frontend)
4. Scripts de atalho (.sh)

### Diretório de Instalação

```
~/xpanel/
├── docker-compose.yml
├── .env
├── start.sh
├── stop.sh
├── restart.sh
├── logs.sh
├── status.sh
└── INSTALLATION_INFO.txt
```

### Porta de Acesso

**Porta 3000** → `http://localhost:3000`

### Scripts de Atalho

```bash
cd ~/xpanel

./start.sh      # Iniciar XPanel
./stop.sh       # Parar XPanel
./restart.sh    # Reiniciar XPanel
./logs.sh       # Ver logs
./status.sh     # Ver status
```

### Uso Recomendado

- ✅ Desenvolvimento local
- ✅ Testes
- ✅ Demonstrações
- ❌ Não recomendado para produção

---

## 🪟 Windows

### Sistemas Suportados

| Versão | Status | Notas |
|--------|--------|-------|
| **Windows 11** | ✅ Testado | Recomendado |
| **Windows 10 (64-bit)** | ✅ Testado | Build 19041+ |
| **Windows Server 2022** | ✅ Suportado | Com Docker Desktop |
| **Windows Server 2019** | ⚠️ Limitado | Com Docker Desktop |

### Arquiteturas

- ✅ x86_64 (AMD64)
- ❌ ARM64 (não suportado pelo Docker Desktop)

### Pré-requisitos

**Docker Desktop** é obrigatório:
- Download: https://www.docker.com/products/docker-desktop

### Instalação

#### Opção 1: Arquivo .bat (Recomendado)

1. Baixe: [install-windows.bat](https://raw.githubusercontent.com/sxconnect/install-xpanel/main/install-windows.bat)
2. Clique com botão direito → **Executar como Administrador**

#### Opção 2: PowerShell Direto

```powershell
# Execute como Administrador
Set-ExecutionPolicy Bypass -Scope Process -Force
irm https://raw.githubusercontent.com/sxconnect/install-xpanel/main/install-windows.ps1 | iex
```

#### Opção 3: Via Bash (WSL/Git Bash)

```bash
# Não recomendado - use PowerShell
curl -fsSL https://raw.githubusercontent.com/sxconnect/install-xpanel/main/install.sh | bash
```

### O que é instalado?

1. XPanel containers (PostgreSQL, Backend, Frontend)
2. Scripts de atalho (.ps1)
3. Configurações Docker

### Diretório de Instalação

```
%USERPROFILE%\xpanel\
├── docker-compose.yml
├── .env
├── start.ps1
├── stop.ps1
├── restart.ps1
├── logs.ps1
├── status.ps1
└── INSTALLATION_INFO.txt
```

### Porta de Acesso

**Porta 3000** → `http://localhost:3000`

### Scripts de Atalho

```powershell
cd $env:USERPROFILE\xpanel

.\start.ps1      # Iniciar XPanel
.\stop.ps1       # Parar XPanel
.\restart.ps1    # Reiniciar XPanel
.\logs.ps1       # Ver logs
.\status.ps1     # Ver status
```

### Uso Recomendado

- ✅ Desenvolvimento local
- ✅ Testes
- ✅ Demonstrações
- ❌ Não recomendado para produção

---

## 📊 Comparação de Plataformas

| Característica | Linux | macOS | Windows |
|----------------|-------|-------|---------|
| **Uso Recomendado** | Produção | Desenvolvimento | Desenvolvimento |
| **Porta Padrão** | 80 | 3000 | 3000 |
| **Instalação** | Automática | Automática | Semi-automática |
| **Docker** | Instalado automaticamente | Requer Docker Desktop | Requer Docker Desktop |
| **Performance** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Facilidade** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Custo** | Gratuito | Gratuito | Gratuito |
| **SSL/HTTPS** | ✅ Suportado | ⚠️ Manual | ⚠️ Manual |
| **Firewall** | ✅ Configurado | ❌ Manual | ❌ Manual |
| **Scripts** | Bash | Bash | PowerShell |

---

## 🔄 Detecção Automática

O instalador universal (`install.sh`) detecta automaticamente:

### 1. Sistema Operacional

```bash
# Detecta via $OSTYPE
- linux-gnu*  → Linux
- darwin*     → macOS
- msys/cygwin → Windows
```

### 2. Distribuição Linux

```bash
# Lê /etc/os-release
- ID=ubuntu   → Ubuntu
- ID=debian   → Debian
```

### 3. Arquitetura

```bash
# Detecta via uname -m
- x86_64/amd64  → Intel/AMD 64-bit
- arm64/aarch64 → ARM 64-bit
```

### 4. Dependências

```bash
# Verifica comandos disponíveis
- docker      → Docker instalado?
- brew        → Homebrew instalado? (macOS)
- apt-get     → Gerenciador de pacotes (Linux)
```

---

## 🎯 Fluxo de Instalação

### Linux

```
1. Detectar sistema (Ubuntu/Debian)
2. Verificar permissões (root/sudo)
3. Instalar Docker
4. Baixar imagens
5. Configurar firewall
6. Iniciar containers
7. Criar usuário admin
```

### macOS

```
1. Detectar versão do macOS
2. Verificar/Instalar Homebrew
3. Verificar/Instalar Docker Desktop
4. Criar diretório ~/xpanel
5. Baixar imagens
6. Iniciar containers
7. Criar scripts de atalho
8. Criar usuário admin
```

### Windows

```
1. Detectar versão do Windows
2. Verificar permissões (Administrador)
3. Verificar Docker Desktop
4. Criar diretório %USERPROFILE%\xpanel
5. Baixar imagens
6. Iniciar containers
7. Criar scripts PowerShell
8. Criar usuário admin
```

---

## 🔧 Requisitos por Plataforma

### Linux (Produção)

| Componente | Mínimo | Recomendado |
|------------|--------|-------------|
| RAM | 2GB | 4GB+ |
| CPU | 1 core | 2+ cores |
| Disco | 10GB | 20GB+ |
| Rede | 10 Mbps | 100 Mbps+ |

### macOS (Desenvolvimento)

| Componente | Mínimo | Recomendado |
|------------|--------|-------------|
| RAM | 8GB | 16GB+ |
| CPU | 2 cores | 4+ cores |
| Disco | 20GB | 50GB+ |
| macOS | 10.15+ | 14.0+ |

### Windows (Desenvolvimento)

| Componente | Mínimo | Recomendado |
|------------|--------|-------------|
| RAM | 8GB | 16GB+ |
| CPU | 2 cores | 4+ cores |
| Disco | 20GB | 50GB+ |
| Windows | 10 (64-bit) | 11 |

---

## 🌐 Portas por Plataforma

### Linux

```
Frontend:   80    → http://SEU_IP
Backend:    4000  → Interno (via proxy)
PostgreSQL: 5432  → Interno
```

### macOS

```
Frontend:   3000  → http://localhost:3000
Backend:    4000  → Interno
PostgreSQL: 5432  → Interno
```

### Windows

```
Frontend:   3000  → http://localhost:3000
Backend:    4000  → Interno
PostgreSQL: 5432  → Interno
```

---

## 🧪 Testado em

### Linux

- ✅ Ubuntu 24.04 LTS (DigitalOcean)
- ✅ Ubuntu 22.04 LTS (AWS EC2)
- ✅ Ubuntu 20.04 LTS (Linode)
- ✅ Debian 12 (Hetzner)
- ✅ Debian 11 (OVH)

### macOS

- ✅ macOS 15 Sequoia (M3 Pro)
- ✅ macOS 14 Sonoma (M2)
- ✅ macOS 13 Ventura (M1)
- ✅ macOS 12 Monterey (Intel)

### Windows

- ✅ Windows 11 Pro (Build 22631)
- ✅ Windows 10 Pro (Build 19045)
- ✅ Windows 11 Home (Build 22621)

---

## 📞 Suporte

### Problemas Específicos da Plataforma

**Linux:**
- Issues: https://github.com/sxconnect/install-xpanel/issues?q=label:linux

**macOS:**
- Issues: https://github.com/sxconnect/install-xpanel/issues?q=label:macos

**Windows:**
- Issues: https://github.com/sxconnect/install-xpanel/issues?q=label:windows

### Contato

- **GitHub:** https://github.com/sxconnect/install-xpanel
- **Email:** suporte@sxconnect.com.br

---

**Desenvolvido com ❤️ por SX Connect**
