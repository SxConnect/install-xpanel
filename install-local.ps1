# XPanel - Instalação Local (Sem Admin)
# Para teste local no Windows

$ErrorActionPreference = "Stop"

$XPANEL_DIR = "$env:USERPROFILE\xpanel"
$GITHUB_USERNAME = "sxconnect"
$VERSION = "latest"

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                                ║" -ForegroundColor Cyan
Write-Host "║                    XPanel Installer (Local)                    ║" -ForegroundColor Magenta
Write-Host "║                                                                ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Verificar Docker
Write-Host "[→] Verificando Docker..." -ForegroundColor Cyan
try {
    docker ps | Out-Null
    Write-Host "[✓] Docker está rodando" -ForegroundColor Green
} catch {
    Write-Host "[✗] Docker não está rodando!" -ForegroundColor Red
    Write-Host "Por favor, inicie o Docker Desktop e tente novamente." -ForegroundColor Yellow
    exit 1
}

# Criar diretório
Write-Host "[→] Criando diretório de instalação..." -ForegroundColor Cyan
if (Test-Path $XPANEL_DIR) {
    Write-Host "[!] Diretório já existe: $XPANEL_DIR" -ForegroundColor Yellow
    $response = Read-Host "Deseja remover e reinstalar? (S/N)"
    if ($response -eq "S" -or $response -eq "s") {
        Remove-Item -Path $XPANEL_DIR -Recurse -Force
        Write-Host "[✓] Diretório removido" -ForegroundColor Green
    } else {
        Write-Host "Instalação cancelada." -ForegroundColor Yellow
        exit 0
    }
}

New-Item -ItemType Directory -Path $XPANEL_DIR -Force | Out-Null
Set-Location $XPANEL_DIR
Write-Host "[✓] Diretório criado: $XPANEL_DIR" -ForegroundColor Green

# Copiar docker-compose.yml
Write-Host "[→] Copiando arquivos de configuração..." -ForegroundColor Cyan
Copy-Item "h:\dev-xpanel\install-xpanel\docker-compose.yml" "$XPANEL_DIR\" -Force
Copy-Item "h:\dev-xpanel\install-xpanel\.env.example" "$XPANEL_DIR\" -Force
Write-Host "[✓] Arquivos copiados" -ForegroundColor Green

# Gerar credenciais
Write-Host "[→] Gerando credenciais seguras..." -ForegroundColor Cyan
$dbPassword = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 32 | ForEach-Object {[char]$_})
$jwtSecret = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 64 | ForEach-Object {[char]$_})

$envContent = @"
# XPanel - Environment Variables
# Gerado automaticamente em: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

POSTGRES_DB=xpanel
POSTGRES_USER=xpanel
POSTGRES_PASSWORD=$dbPassword

JWT_SECRET=$jwtSecret
JWT_EXPIRES_IN=7d

NODE_ENV=production
FRONTEND_PORT=3000

GITHUB_USERNAME=$GITHUB_USERNAME
VERSION=$VERSION
"@

Set-Content -Path "$XPANEL_DIR\.env" -Value $envContent
Write-Host "[✓] Credenciais geradas" -ForegroundColor Green

# Baixar imagens
Write-Host "[→] Baixando imagens Docker..." -ForegroundColor Cyan
Write-Host ""
docker pull postgres:15-alpine
docker pull ghcr.io/$GITHUB_USERNAME/xpanel-backend:$VERSION
docker pull ghcr.io/$GITHUB_USERNAME/xpanel-frontend:$VERSION
Write-Host ""
Write-Host "[✓] Imagens baixadas" -ForegroundColor Green

# Iniciar containers
Write-Host "[→] Iniciando containers..." -ForegroundColor Cyan
docker compose up -d

Write-Host "[→] Aguardando containers iniciarem..." -ForegroundColor Cyan
Start-Sleep -Seconds 15

Write-Host "[✓] Containers iniciados" -ForegroundColor Green

# Criar scripts de atalho
Write-Host "[→] Criando scripts de atalho..." -ForegroundColor Cyan

@"
Set-Location "$XPANEL_DIR"
docker compose start
Write-Host "XPanel iniciado!" -ForegroundColor Green
Write-Host "Acesse: http://localhost:3000" -ForegroundColor Cyan
"@ | Set-Content "$XPANEL_DIR\start.ps1"

@"
Set-Location "$XPANEL_DIR"
docker compose stop
Write-Host "XPanel parado!" -ForegroundColor Yellow
"@ | Set-Content "$XPANEL_DIR\stop.ps1"

@"
Set-Location "$XPANEL_DIR"
docker compose restart
Write-Host "XPanel reiniciado!" -ForegroundColor Green
Write-Host "Acesse: http://localhost:3000" -ForegroundColor Cyan
"@ | Set-Content "$XPANEL_DIR\restart.ps1"

@"
Set-Location "$XPANEL_DIR"
docker compose logs -f
"@ | Set-Content "$XPANEL_DIR\logs.ps1"

@"
Set-Location "$XPANEL_DIR"
docker compose ps
"@ | Set-Content "$XPANEL_DIR\status.ps1"

Write-Host "[✓] Scripts criados" -ForegroundColor Green

# Mensagem final
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
Write-Host "                                    │" -ForegroundColor Cyan
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
Write-Host "📄 Diretório: $XPANEL_DIR" -ForegroundColor Blue
Write-Host ""

$response = Read-Host "Deseja abrir o XPanel no navegador agora? (S/N)"
if ($response -eq "S" -or $response -eq "s") {
    Start-Process "http://localhost:3000"
}
