# ============================================
# XPanel Client - Instalador Windows
# ============================================
# Este script instala apenas o XPanel Client
# (interface pública para usuários)
# ============================================

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "🚀 XPanel Client - Instalador Windows" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Variáveis
$INSTALL_DIR = "$env:USERPROFILE\xpanel-client"
$GITHUB_RAW = "https://raw.githubusercontent.com/sxconnect/install-xpanel/main"

# Verificar Docker
Write-Host "🔍 Verificando Docker..." -ForegroundColor Blue
if (!(Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Docker não está instalado!" -ForegroundColor Red
    Write-Host "Por favor, instale o Docker Desktop:" -ForegroundColor Yellow
    Write-Host "https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

# Verificar se Docker está rodando
try {
    docker ps | Out-Null
} catch {
    Write-Host "❌ Docker não está rodando!" -ForegroundColor Red
    Write-Host "Por favor, inicie o Docker Desktop" -ForegroundColor Yellow
    exit 1
}

# Criar diretório
Write-Host "📦 Criando diretório de instalação..." -ForegroundColor Blue
New-Item -ItemType Directory -Force -Path $INSTALL_DIR | Out-Null
Set-Location $INSTALL_DIR

# Baixar arquivos
Write-Host "📥 Baixando arquivos de configuração..." -ForegroundColor Blue

try {
    Invoke-WebRequest -Uri "$GITHUB_RAW/docker-compose-client.yml" -OutFile "docker-compose.yml"
    Invoke-WebRequest -Uri "$GITHUB_RAW/.env.client.example" -OutFile ".env.example"
} catch {
    Write-Host "❌ Erro ao baixar arquivos!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# Criar .env
if (!(Test-Path ".env")) {
    Write-Host "⚙️  Criando arquivo de configuração..." -ForegroundColor Blue
    Copy-Item ".env.example" ".env"
    
    # Gerar INSTANCE_ID único
    $INSTANCE_ID = "client-" + [guid]::NewGuid().ToString()
    (Get-Content ".env") -replace 'INSTANCE_ID=.*', "INSTANCE_ID=$INSTANCE_ID" | Set-Content ".env"
    
    Write-Host ""
    Write-Host "⚠️  IMPORTANTE: Configure o arquivo .env" -ForegroundColor Yellow
    Write-Host "Edite o arquivo $INSTALL_DIR\.env e configure:" -ForegroundColor Yellow
    Write-Host "  - MASTER_URL: URL do seu servidor XPanel Master" -ForegroundColor Yellow
    Write-Host "  - INSTANCE_NAME: Nome da sua empresa/instalação" -ForegroundColor Yellow
    Write-Host "  - INSTANCE_EMAIL: Seu email" -ForegroundColor Yellow
    Write-Host ""
    
    # Abrir .env no notepad
    notepad ".env"
    
    Write-Host "Pressione ENTER após configurar o .env..." -ForegroundColor Yellow
    Read-Host
}

# Iniciar containers
Write-Host "🐳 Iniciando XPanel Client..." -ForegroundColor Blue
docker compose up -d

Write-Host ""
Write-Host "✅ XPanel Client instalado com sucesso!" -ForegroundColor Green
Write-Host ""
Write-Host "📍 Localização: $INSTALL_DIR" -ForegroundColor Cyan
Write-Host "🌐 Acesse: http://localhost:3000" -ForegroundColor Cyan
Write-Host ""
Write-Host "📝 Comandos úteis:" -ForegroundColor Cyan
Write-Host "  docker compose logs -f          # Ver logs"
Write-Host "  docker compose restart          # Reiniciar"
Write-Host "  docker compose stop             # Parar"
Write-Host "  docker compose down             # Remover"
Write-Host ""
Write-Host "🔧 Para reconfigurar, edite: $INSTALL_DIR\.env" -ForegroundColor Cyan
Write-Host ""
