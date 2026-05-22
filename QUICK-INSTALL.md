# ⚡ XPanel - Instalação Rápida

## 🚀 Instalação Universal (Linux, macOS, Windows)

### Um único comando para todos os sistemas!

```bash
curl -fsSL https://raw.githubusercontent.com/sxconnect/install-xpanel/main/install.sh | bash
```

O instalador detecta automaticamente seu sistema operacional e executa a instalação apropriada.

---

## 🐧 Linux (VPS/Servidor)

```bash
curl -fsSL https://raw.githubusercontent.com/sxconnect/install-xpanel/main/install.sh | sudo bash
```

**Acesso:** `http://SEU_IP`  
**Login:** `admin@xpanel.local` / `admin123`

---

## 🍎 macOS (Desenvolvimento)

```bash
curl -fsSL https://raw.githubusercontent.com/sxconnect/install-xpanel/main/install.sh | bash
```

**Requisito:** Docker Desktop (o instalador oferece instalação via Homebrew)  
**Acesso:** `http://localhost:3000`  
**Login:** `admin@xpanel.local` / `admin123`

---

## 🪟 Windows (Desenvolvimento)

### 1. Instale o Docker Desktop
https://www.docker.com/products/docker-desktop

### 2. Execute o Instalador

**Opção A: Download e Execute**
1. Baixe: [install-windows.bat](https://raw.githubusercontent.com/sxconnect/install-xpanel/main/install-windows.bat)
2. Clique com botão direito → **Executar como Administrador**

**Opção B: PowerShell (Direto)**
```powershell
# Execute como Administrador
Set-ExecutionPolicy Bypass -Scope Process -Force
irm https://raw.githubusercontent.com/sxconnect/install-xpanel/main/install-windows.ps1 | iex
```

**Acesso:** `http://localhost:3000`  
**Login:** `admin@xpanel.local` / `admin123`

---

## 📚 Documentação Completa

Para instruções detalhadas, troubleshooting e comandos úteis, veja:
- [INSTALL-README.md](INSTALL-README.md) - Guia completo de instalação
- [README.md](README.md) - Documentação do projeto

---

## 🆘 Problemas?

**Linux:**
```bash
cd /opt/xpanel
docker compose logs
```

**Windows:**
```powershell
cd $env:USERPROFILE\xpanel
docker compose logs
```

**Suporte:** https://github.com/sxconnect/install-xpanel/issues
