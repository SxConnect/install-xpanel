################################################################################
# XPanel - Instalador para Windows (Auto-Elevação)
# Versão: 2.0.0
# Descrição: Instala o XPanel usando Docker Desktop no Windows
# Solicita permissões de Administrador automaticamente
################################################################################

# Verificar se está rodando como Administrador
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
    Write-Host "║                                                                ║" -ForegroundColor Yellow
    Write-Host "║              Permissões de Administrador Necessárias           ║" -ForegroundColor Yellow
    Write-Host "║                                                                ║" -ForegroundColor Yellow
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "O instalador precisa de permissões de Administrador." -ForegroundColor Cyan
    Write-Host "Uma janela de UAC será exibida para você autorizar." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Pressione qualquer tecla para continuar..." -ForegroundColor Green
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
    # Reiniciar o script como Administrador
    $scriptPath = $MyInvocation.MyCommand.Path
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
    exit
}

# A partir daqui, o script está rodando como Administrador
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Variáveis
$XPANEL_DIR = "$env:USERPROFILE\xpanel"
$GITHUB_USERNAME = "sxconnect"
$VERSION = "latest"
$GITHUB_RAW = "https://raw.githubusercontent.com/$GITHUB_USERNAME/install-xpanel/main"

################################################################################
# Funções Auxiliares
################################################################################

function Write-Header {
    Clear-Host
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                                                                ║" -ForegroundColor Cyan
    Write-Host "║                    XPanel Installer v2.0                       ║" -ForegroundColor Magenta
    Write-Host "║                                                                ║" -ForegroundColor Cyan
    Write-Host "║              Instalação via Docker Desktop                     ║" -ForegroundColor Blue
    Write-Host "║                                                                ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step {
    param([string]$Message)
    Write-Host "[✓] " -ForegroundColor Green -NoNewline
    Write-Host $Message
}

function Write-Error-Message {
    param([string]$Message)
    Write-Host "[✗] " -ForegroundColor Red -NoNewline
    Write-Host $Message
}

function Write-Warning-Message {
    param([string]$Message)
    Write-Host "[!] " -ForegroundColor Yellow -NoNewline
    Write-Host $Message
}

function Write-Info {
    param([string]$Message)
    Write-Host "[i] " -ForegroundColor Blue -NoNewline
    Write-Host $Message
}

function Write-Progress-Message {
    param([string]$Message)
    Write-Host "[→] " -ForegroundColor Cyan -NoNewline
    Write-Host $Message
}

function Test-DockerDesktop {
    Write-Progress-Message "Verificando Docker Desktop..."
    
    try {
        $dockerVersion = docker --version 2>$null
        if ($dockerVersion) {
            Write-Step "Docker Desktop instalado: $dockerVersion"
            return $true
        }
    } catch {
        return $false
    }
    
    return $false
}

function Install-DockerDesktop {
    Write-Warning-Message "Docker Desktop não encontrado!"
    Write-Host ""
    Write-Host "O XPanel requer Docker Desktop para funcionar no Windows." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Por favor, siga os passos:" -ForegroundColor Cyan
    Write-Host "1. Baixe o Docker Desktop em: https://www.docker.com/products/docker-desktop" -ForegroundColor White
    Write-Host "2. Instale o Docker Desktop" -ForegroundColor White
    Write-Host "3. Reinicie o computador se solicitado" -ForegroundColor White
    Write-Host "4. Inicie o Docker Desktop" -ForegroundColor White
    Write-Host "5. Execute este instalador novamente" -ForegroundColor White
    Write-Host ""
    
    $response = Read-Host "Deseja abrir a página de download agora? (S/N)"
    if ($response -eq "S" -or $response -eq "s") {
        Start-Process "https://www.docker.com/products/docker-desktop"
    }
    
    Write-Host ""
    Write-Host "Instalação cancelada. Execute novamente após instalar o Docker Desktop." -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Pressione Enter para sair"
    exit 1
}

function Test-DockerRunning {
    Write-Progress-Message "Verificando se Docker está em execução..."
    
    try {
        docker ps 2>$null | Out-Null
        Write-Step "Docker está em execução"
        return $true
    } catch {
        Write-Error-Message "Docker não está em execução!"
        Write-Host ""
        Write-Host "Por favor, inicie o Docker Desktop e tente novamente." -ForegroundColor Yellow
        Write-Host ""
        Read-Host "Pressione Enter para sair"
        exit 1
    }
}

function Test-SystemRequirements {
    Write-Progress-Message "Verificando requisitos do sistema..."
    
    # Verificar memória RAM (mínimo 4GB para Windows)
    $totalRAM = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
    if ($totalRAM -lt 4) {
        Write-Warning-Message "RAM disponível: ${totalRAM}GB (recomendado: 8GB+)"
    } else {
        Write-Step "RAM disponível: ${totalRAM}GB"
    }
    
    # Verificar espaço em disco (mínimo 10GB)
    $disk = Get-PSDrive -Name C
    $freeSpaceGB = [math]::Round($disk.Free / 1GB, 2)
    if ($freeSpaceGB -lt 10) {
        Write-Error-Message "Espaço em disco insuficiente: ${freeSpaceGB}GB (mínimo: 10GB)"
        Read-Host "Pressione Enter para sair"
        exit 1
    } else {
        Write-Step "Espaço em disco: ${freeSpaceGB}GB"
    }
    
    # Verificar versão do Windows
    $osVersion = [System.Environment]::OSVersion.Version
    Write-Step "Windows versão: $($osVersion.Major).$($osVersion.Minor)"
}

function New-InstallationDirectory {
    Write-Progress-Message "Criando diretório de instalação..."
    
    if (Test-Path $XPANEL_DIR) {
        Write-Warning-Message "Diretório já existe: $XPANEL_DIR"
        $response = Read-Host "Deseja remover e reinstalar? (S/N)"
        if ($response -eq "S" -or $response -eq "s") {
            Remove-Item -Path $XPANEL_DIR -Recurse -Force
            Write-Step "Diretório removido"
        } else {
            Write-Host "Instalação cancelada." -ForegroundColor Yellow
            Read-Host "Pressione Enter para sair"
            exit 1
        }
    }
    
    New-Item -ItemType Directory -Path $XPANEL_DIR -Force | Out-Null
    Write-Step "Diretório criado: $XPANEL_DIR"
}

# Continua com o resto do instalador...
# (Incluir todas as outras funções do install-windows.ps1 original)

################################################################################
# Execução Principal
################################################################################

try {
    Write-Header
    
    Write-Info "Executando como Administrador ✓"
    Write-Host ""
    
    Test-SystemRequirements
    
    if (-not (Test-DockerDesktop)) {
        Install-DockerDesktop
    }
    
    Test-DockerRunning
    
    Write-Host ""
    Write-Info "Iniciando instalação do XPanel..."
    Write-Host ""
    
    New-InstallationDirectory
    
    # Copiar docker-compose.yml e .env da pasta install-xpanel
    Write-Progress-Message "Copiando arquivos de configuração..."
    Copy-Item "h:\dev-xpanel\install-xpanel\docker-compose.yml" "$XPANEL_DIR\" -Force
    Copy-Item "h:\dev-xpanel\install-xpanel\.env.example" "$XPANEL_DIR\.env" -Force
    Write-Step "Arquivos copiados"
    
    # Iniciar containers
    Write-Progress-Message "Iniciando containers..."
    Set-Location $XPANEL_DIR
    docker compose up -d
    
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║                                                                ║" -ForegroundColor Green
    Write-Host "║              ✓ XPanel Instalado com Sucesso!                  ║" -ForegroundColor Green
    Write-Host "║                                                                ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "Acesse: http://localhost:3000" -ForegroundColor Cyan
    Write-Host "Email: admin@xpanel.local" -ForegroundColor Yellow
    Write-Host "Senha: admin123" -ForegroundColor Yellow
    Write-Host ""
    
    $response = Read-Host "Deseja abrir o XPanel no navegador agora? (S/N)"
    if ($response -eq "S" -or $response -eq "s") {
        Start-Process "http://localhost:3000"
    }
    
} catch {
    Write-Host ""
    Write-Error-Message "Erro durante a instalação: $_"
    Write-Host ""
    Read-Host "Pressione Enter para sair"
    exit 1
}
