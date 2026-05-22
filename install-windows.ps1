################################################################################
# XPanel - Instalador para Windows
# Versão: 2.0.0
# Descrição: Instala o XPanel usando Docker Desktop no Windows
# Uso: powershell -ExecutionPolicy Bypass -File install-windows.ps1
################################################################################

# Requer execução como Administrador
#Requires -RunAsAdministrator

# Configurações
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

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
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
            exit 1
        }
    }
    
    New-Item -ItemType Directory -Path $XPANEL_DIR -Force | Out-Null
    Write-Step "Diretório criado: $XPANEL_DIR"
}

function Get-ConfigurationFiles {
    Write-Progress-Message "Baixando arquivos de configuração..."
    
    try {
        # Baixar docker-compose.yml
        $dockerComposeUrl = "$GITHUB_RAW/docker-compose.yml"
        Invoke-WebRequest -Uri $dockerComposeUrl -OutFile "$XPANEL_DIR\docker-compose.yml" -UseBasicParsing
        
        # Baixar .env.example
        $envExampleUrl = "$GITHUB_RAW/.env.example"
        Invoke-WebRequest -Uri $envExampleUrl -OutFile "$XPANEL_DIR\.env.example" -UseBasicParsing
        
        Write-Step "Arquivos baixados com sucesso"
    } catch {
        Write-Error-Message "Erro ao baixar arquivos de configuração"
        Write-Host "Usando configuração local..." -ForegroundColor Yellow
        
        # Criar docker-compose.yml local
        New-DockerComposeFile
        New-EnvExampleFile
    }
}

function New-DockerComposeFile {
    $dockerComposeContent = @"
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: xpanel-postgres
    restart: unless-stopped
    environment:
      POSTGRES_DB: `${POSTGRES_DB:-xpanel}
      POSTGRES_USER: `${POSTGRES_USER:-xpanel}
      POSTGRES_PASSWORD: `${POSTGRES_PASSWORD:-xpanel_secure_password}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - xpanel-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U `${POSTGRES_USER:-xpanel}"]
      interval: 10s
      timeout: 5s
      retries: 5

  backend:
    image: ghcr.io/`${GITHUB_USERNAME:-sxconnect}/xpanel-backend:`${VERSION:-latest}
    container_name: xpanel-backend
    restart: unless-stopped
    depends_on:
      postgres:
        condition: service_healthy
    environment:
      DATABASE_URL: postgresql://`${POSTGRES_USER:-xpanel}:`${POSTGRES_PASSWORD:-xpanel_secure_password}@postgres:5432/`${POSTGRES_DB:-xpanel}
      JWT_SECRET: `${JWT_SECRET:-change_this_secret_in_production}
      JWT_EXPIRES_IN: `${JWT_EXPIRES_IN:-7d}
      PORT: 4000
      NODE_ENV: `${NODE_ENV:-production}
    networks:
      - xpanel-network
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:4000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  frontend:
    image: ghcr.io/`${GITHUB_USERNAME:-sxconnect}/xpanel-frontend:`${VERSION:-latest}
    container_name: xpanel-frontend
    restart: unless-stopped
    depends_on:
      - backend
    ports:
      - "`${FRONTEND_PORT:-3000}:80"
    networks:
      - xpanel-network
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 10s

networks:
  xpanel-network:
    driver: bridge
    name: xpanel-network

volumes:
  postgres_data:
    name: xpanel-postgres-data
"@
    
    Set-Content -Path "$XPANEL_DIR\docker-compose.yml" -Value $dockerComposeContent
    Write-Step "docker-compose.yml criado"
}

function New-EnvExampleFile {
    $envContent = @"
# XPanel - Environment Variables
POSTGRES_DB=xpanel
POSTGRES_USER=xpanel
POSTGRES_PASSWORD=change_this_password_in_production

JWT_SECRET=change_this_secret_in_production_use_long_random_string
JWT_EXPIRES_IN=7d

NODE_ENV=production
FRONTEND_PORT=3000

GITHUB_USERNAME=sxconnect
VERSION=latest
"@
    
    Set-Content -Path "$XPANEL_DIR\.env.example" -Value $envContent
    Write-Step ".env.example criado"
}

function New-EnvironmentFile {
    Write-Progress-Message "Gerando credenciais seguras..."
    
    # Gerar senhas aleatórias
    $dbPassword = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 32 | ForEach-Object {[char]$_})
    $jwtSecret = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 64 | ForEach-Object {[char]$_})
    
    $envContent = @"
# ============================================
# XPanel - Environment Variables
# Gerado automaticamente em: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
# ============================================

# Database Configuration
POSTGRES_DB=xpanel
POSTGRES_USER=xpanel
POSTGRES_PASSWORD=$dbPassword

# JWT Configuration
JWT_SECRET=$jwtSecret
JWT_EXPIRES_IN=7d

# Server Configuration
NODE_ENV=production
FRONTEND_PORT=3000

# GitHub Container Registry
GITHUB_USERNAME=$GITHUB_USERNAME
VERSION=$VERSION
"@
    
    Set-Content -Path "$XPANEL_DIR\.env" -Value $envContent
    Write-Step "Credenciais geradas e salvas em .env"
}

function Get-DockerImages {
    Write-Progress-Message "Baixando imagens Docker..."
    Write-Host ""
    
    try {
        # Pull PostgreSQL
        Write-Info "Baixando PostgreSQL..."
        docker pull postgres:15-alpine
        
        # Pull backend
        Write-Info "Baixando backend..."
        docker pull ghcr.io/$GITHUB_USERNAME/xpanel-backend:$VERSION
        
        # Pull frontend
        Write-Info "Baixando frontend..."
        docker pull ghcr.io/$GITHUB_USERNAME/xpanel-frontend:$VERSION
        
        Write-Host ""
        Write-Step "Imagens baixadas com sucesso"
    } catch {
        Write-Warning-Message "Erro ao baixar imagens. Tentando continuar..."
    }
}

function Start-XPanelContainers {
    Write-Progress-Message "Iniciando containers..."
    
    Set-Location $XPANEL_DIR
    
    try {
        docker compose up -d
        
        Write-Progress-Message "Aguardando containers iniciarem..."
        Start-Sleep -Seconds 15
        
        $containers = docker compose ps --format json | ConvertFrom-Json
        $runningCount = ($containers | Where-Object { $_.State -eq "running" }).Count
        
        if ($runningCount -gt 0) {
            Write-Step "Containers iniciados com sucesso"
        } else {
            Write-Error-Message "Erro ao iniciar containers"
            docker compose logs
            exit 1
        }
    } catch {
        Write-Error-Message "Erro ao iniciar containers: $_"
        exit 1
    }
}

function Initialize-Database {
    Write-Progress-Message "Inicializando banco de dados..."
    
    Start-Sleep -Seconds 5
    
    try {
        docker compose exec -T backend npx prisma db push 2>$null
        Write-Step "Banco de dados inicializado"
    } catch {
        Write-Warning-Message "Erro ao inicializar banco. Pode já estar configurado."
    }
}

function New-AdminUser {
    Write-Progress-Message "Criando usuário administrador..."
    
    $createAdminScript = @"
const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcrypt');
const prisma = new PrismaClient();

async function createAdmin() {
    try {
        const hashedPassword = await bcrypt.hash('admin123', 10);
        await prisma.user.upsert({
            where: { email: 'admin@xpanel.local' },
            update: {},
            create: {
                email: 'admin@xpanel.local',
                password: hashedPassword,
                name: 'Administrator',
                role: 'ADMIN',
                tier: 'PREMIUM'
            }
        });
        console.log('Admin user created successfully');
    } catch (error) {
        console.error('Error:', error.message);
    } finally {
        await prisma.\`$disconnect();
    }
}

createAdmin();
"@
    
    $scriptPath = "$XPANEL_DIR\create-admin.js"
    Set-Content -Path $scriptPath -Value $createAdminScript
    
    try {
        docker cp $scriptPath xpanel-backend:/tmp/create-admin.js
        docker compose exec -T backend node /tmp/create-admin.js 2>$null
        Write-Step "Usuário administrador criado"
    } catch {
        Write-Warning-Message "Usuário admin pode já existir"
    }
    
    Remove-Item $scriptPath -Force -ErrorAction SilentlyContinue
}

function New-InfoFile {
    Write-Progress-Message "Criando arquivo de informações..."
    
    $infoContent = @"
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║                  XPanel - Informações de Instalação            ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝

Data de Instalação: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Diretório: $XPANEL_DIR
Versão: $VERSION

╔════════════════════════════════════════════════════════════════╗
║ ACESSO                                                         ║
╚════════════════════════════════════════════════════════════════╝

URL: http://localhost:3000

Usuário Admin:
  Email: admin@xpanel.local
  Senha: admin123

⚠️  IMPORTANTE: Altere a senha do admin após o primeiro login!

╔════════════════════════════════════════════════════════════════╗
║ COMANDOS ÚTEIS (PowerShell)                                    ║
╚════════════════════════════════════════════════════════════════╝

Navegar para o diretório:
  cd $XPANEL_DIR

Ver status dos containers:
  docker compose ps

Ver logs:
  docker compose logs -f

Ver logs de um serviço específico:
  docker compose logs -f backend
  docker compose logs -f frontend
  docker compose logs -f postgres

Reiniciar todos os serviços:
  docker compose restart

Reiniciar um serviço específico:
  docker compose restart backend

Parar todos os serviços:
  docker compose stop

Iniciar todos os serviços:
  docker compose start

Atualizar XPanel:
  docker compose pull
  docker compose up -d

Backup do banco de dados:
  docker compose exec postgres pg_dump -U xpanel xpanel > backup.sql

Restaurar banco de dados:
  Get-Content backup.sql | docker compose exec -T postgres psql -U xpanel xpanel

Desinstalar XPanel:
  docker compose down -v
  Remove-Item -Path $XPANEL_DIR -Recurse -Force

╔════════════════════════════════════════════════════════════════╗
║ ATALHOS                                                        ║
╚════════════════════════════════════════════════════════════════╝

Foram criados scripts de atalho no diretório:

  start.ps1   - Iniciar XPanel
  stop.ps1    - Parar XPanel
  restart.ps1 - Reiniciar XPanel
  logs.ps1    - Ver logs
  status.ps1  - Ver status

Uso: .\start.ps1

╔════════════════════════════════════════════════════════════════╗
║ SUPORTE                                                        ║
╚════════════════════════════════════════════════════════════════╝

GitHub: https://github.com/$GITHUB_USERNAME/install-xpanel
Issues: https://github.com/$GITHUB_USERNAME/install-xpanel/issues
Email: suporte@sxconnect.com.br

╔════════════════════════════════════════════════════════════════╗
║ TROUBLESHOOTING                                                ║
╚════════════════════════════════════════════════════════════════╝

Se o XPanel não iniciar:

1. Verifique se o Docker Desktop está em execução
2. Verifique os logs: docker compose logs
3. Reinicie os containers: docker compose restart
4. Se necessário, recrie os containers: docker compose down && docker compose up -d

Se a porta 3000 já estiver em uso:
1. Edite o arquivo .env
2. Altere FRONTEND_PORT=3000 para outra porta (ex: 3001)
3. Reinicie: docker compose up -d

"@
    
    Set-Content -Path "$XPANEL_DIR\INSTALLATION_INFO.txt" -Value $infoContent
    Write-Step "Arquivo de informações criado"
}

function New-ShortcutScripts {
    Write-Progress-Message "Criando scripts de atalho..."
    
    # start.ps1
    $startScript = @"
Set-Location "$XPANEL_DIR"
docker compose start
Write-Host "XPanel iniciado!" -ForegroundColor Green
Write-Host "Acesse: http://localhost:3000" -ForegroundColor Cyan
"@
    Set-Content -Path "$XPANEL_DIR\start.ps1" -Value $startScript
    
    # stop.ps1
    $stopScript = @"
Set-Location "$XPANEL_DIR"
docker compose stop
Write-Host "XPanel parado!" -ForegroundColor Yellow
"@
    Set-Content -Path "$XPANEL_DIR\stop.ps1" -Value $stopScript
    
    # restart.ps1
    $restartScript = @"
Set-Location "$XPANEL_DIR"
docker compose restart
Write-Host "XPanel reiniciado!" -ForegroundColor Green
Write-Host "Acesse: http://localhost:3000" -ForegroundColor Cyan
"@
    Set-Content -Path "$XPANEL_DIR\restart.ps1" -Value $restartScript
    
    # logs.ps1
    $logsScript = @"
Set-Location "$XPANEL_DIR"
docker compose logs -f
"@
    Set-Content -Path "$XPANEL_DIR\logs.ps1" -Value $logsScript
    
    # status.ps1
    $statusScript = @"
Set-Location "$XPANEL_DIR"
docker compose ps
"@
    Set-Content -Path "$XPANEL_DIR\status.ps1" -Value $statusScript
    
    Write-Step "Scripts de atalho criados"
}

function Show-Success {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║                                                                ║" -ForegroundColor Green
    Write-Host "║              ✓ XPanel Instalado com Sucesso!                  ║" -ForegroundColor Green
    Write-Host "║                                                                ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "┌────────────────────────────────────────────────────────────┐" -ForegroundColor Cyan
    Write-Host "│  Acesse o painel em:                                      │" -ForegroundColor Cyan
    Write-Host "│  " -ForegroundColor Cyan -NoNewline
    Write-Host "http://localhost:3000" -ForegroundColor Yellow -NoNewline
    Write-Host "                                        │" -ForegroundColor Cyan
    Write-Host "└────────────────────────────────────────────────────────────┘" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "┌────────────────────────────────────────────────────────────┐" -ForegroundColor Cyan
    Write-Host "│  Credenciais de acesso:                                   │" -ForegroundColor Cyan
    Write-Host "│  Email: " -ForegroundColor Cyan -NoNewline
    Write-Host "admin@xpanel.local" -ForegroundColor Green -NoNewline
    Write-Host "                               │" -ForegroundColor Cyan
    Write-Host "│  Senha: " -ForegroundColor Cyan -NoNewline
    Write-Host "admin123" -ForegroundColor Green -NoNewline
    Write-Host "                                         │" -ForegroundColor Cyan
    Write-Host "└────────────────────────────────────────────────────────────┘" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "⚠️  IMPORTANTE: Altere a senha após o primeiro login!" -ForegroundColor Red
    Write-Host ""
    Write-Host "📄 Informações completas em: $XPANEL_DIR\INSTALLATION_INFO.txt" -ForegroundColor Blue
    Write-Host ""
    Write-Host "🎉 Instalação concluída! Aproveite o XPanel! 🎉" -ForegroundColor Green
    Write-Host ""
    
    $response = Read-Host "Deseja abrir o XPanel no navegador agora? (S/N)"
    if ($response -eq "S" -or $response -eq "s") {
        Start-Process "http://localhost:3000"
    }
}

################################################################################
# Execução Principal
################################################################################

function Main {
    Write-Header
    
    # Verificações iniciais
    if (-not (Test-Administrator)) {
        Write-Error-Message "Este script precisa ser executado como Administrador"
        Write-Host ""
        Write-Host "Clique com botão direito no PowerShell e selecione 'Executar como Administrador'" -ForegroundColor Yellow
        Write-Host ""
        exit 1
    }
    
    Test-SystemRequirements
    
    if (-not (Test-DockerDesktop)) {
        Install-DockerDesktop
    }
    
    Test-DockerRunning
    
    Write-Host ""
    Write-Info "Iniciando instalação do XPanel..."
    Write-Host ""
    
    # Instalação
    New-InstallationDirectory
    Get-ConfigurationFiles
    New-EnvironmentFile
    Get-DockerImages
    Start-XPanelContainers
    Initialize-Database
    New-AdminUser
    
    # Finalização
    New-InfoFile
    New-ShortcutScripts
    Show-Success
}

# Executar instalação
try {
    Main
} catch {
    Write-Host ""
    Write-Error-Message "Erro durante a instalação: $_"
    Write-Host ""
    Write-Host "Por favor, verifique os logs e tente novamente." -ForegroundColor Yellow
    Write-Host "Se o problema persistir, abra uma issue em:" -ForegroundColor Yellow
    Write-Host "https://github.com/$GITHUB_USERNAME/install-xpanel/issues" -ForegroundColor Cyan
    Write-Host ""
    exit 1
}
