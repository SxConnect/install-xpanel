#!/bin/bash

################################################################################
# XPanel - Instalador Universal
# Versão: 2.0.0
# Descrição: Detecta o sistema operacional e instala o XPanel automaticamente
# Suporta: Linux (Ubuntu/Debian), macOS, Windows (via WSL/Git Bash)
# Uso: curl -fsSL https://raw.githubusercontent.com/sxconnect/install-xpanel/main/install.sh | bash
################################################################################

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Variáveis globais
DETECTED_OS=""
DETECTED_ARCH=""
XPANEL_DIR=""
GITHUB_USERNAME="sxconnect"
VERSION="latest"
GITHUB_RAW="https://raw.githubusercontent.com/$GITHUB_USERNAME/install-xpanel/main"

################################################################################
# Funções Auxiliares
################################################################################

print_header() {
    clear
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                                                                ║"
    echo "║                    ${MAGENTA}XPanel Universal Installer${CYAN}                  ║"
    echo "║                                                                ║"
    echo "║              ${BLUE}Detecção Automática de Sistema${CYAN}                    ║"
    echo "║                                                                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

print_step() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[i]${NC} $1"
}

print_progress() {
    echo -e "${CYAN}[→]${NC} $1"
}

################################################################################
# Detecção de Sistema Operacional
################################################################################

detect_os() {
    print_progress "Detectando sistema operacional..."
    
    # Detectar OS
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        DETECTED_OS="linux"
        
        # Detectar distribuição Linux
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            LINUX_DISTRO=$ID
            LINUX_VERSION=$VERSION_ID
            print_step "Sistema: Linux ($LINUX_DISTRO $LINUX_VERSION)"
        else
            print_error "Distribuição Linux não identificada"
            exit 1
        fi
        
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        DETECTED_OS="macos"
        MACOS_VERSION=$(sw_vers -productVersion)
        print_step "Sistema: macOS $MACOS_VERSION"
        
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
        DETECTED_OS="windows"
        print_step "Sistema: Windows (via $OSTYPE)"
        
    else
        print_error "Sistema operacional não suportado: $OSTYPE"
        exit 1
    fi
    
    # Detectar arquitetura
    DETECTED_ARCH=$(uname -m)
    print_step "Arquitetura: $DETECTED_ARCH"
    
    # Validar arquitetura
    if [[ "$DETECTED_ARCH" != "x86_64" ]] && [[ "$DETECTED_ARCH" != "amd64" ]] && [[ "$DETECTED_ARCH" != "arm64" ]] && [[ "$DETECTED_ARCH" != "aarch64" ]]; then
        print_warning "Arquitetura $DETECTED_ARCH pode não ser totalmente suportada"
    fi
}

################################################################################
# Instalação Linux
################################################################################

install_linux() {
    print_info "Iniciando instalação para Linux..."
    echo ""
    
    # Verificar se é Ubuntu ou Debian
    if [[ "$LINUX_DISTRO" != "ubuntu" ]] && [[ "$LINUX_DISTRO" != "debian" ]]; then
        print_error "Este instalador suporta apenas Ubuntu e Debian"
        print_info "Distribuição detectada: $LINUX_DISTRO"
        exit 1
    fi
    
    # Verificar se é root
    if [ "$EUID" -ne 0 ]; then
        print_error "A instalação no Linux precisa ser executada como root"
        echo ""
        echo "Use: ${YELLOW}sudo bash install.sh${NC}"
        echo ""
        exit 1
    fi
    
    # Baixar e executar instalador Docker para Linux
    print_progress "Baixando instalador Docker para Linux..."
    
    curl -fsSL "$GITHUB_RAW/install-docker.sh" -o /tmp/install-docker.sh
    chmod +x /tmp/install-docker.sh
    
    print_step "Executando instalador..."
    bash /tmp/install-docker.sh
    
    rm -f /tmp/install-docker.sh
}

################################################################################
# Instalação macOS
################################################################################

install_macos() {
    print_info "Iniciando instalação para macOS..."
    echo ""
    
    # Verificar Homebrew
    if ! command -v brew &> /dev/null; then
        print_warning "Homebrew não encontrado. Instalando..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        print_step "Homebrew instalado"
    else
        print_step "Homebrew já instalado"
    fi
    
    # Verificar Docker Desktop
    if ! command -v docker &> /dev/null; then
        print_warning "Docker Desktop não encontrado!"
        echo ""
        echo -e "${YELLOW}O XPanel requer Docker Desktop para funcionar no macOS.${NC}"
        echo ""
        echo "Opções de instalação:"
        echo ""
        echo "1. Via Homebrew (Recomendado):"
        echo "   ${CYAN}brew install --cask docker${NC}"
        echo ""
        echo "2. Download Manual:"
        echo "   ${CYAN}https://www.docker.com/products/docker-desktop${NC}"
        echo ""
        
        read -p "Deseja instalar via Homebrew agora? (s/n): " -n 1 -r
        echo ""
        
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            print_progress "Instalando Docker Desktop via Homebrew..."
            brew install --cask docker
            print_step "Docker Desktop instalado"
            echo ""
            print_warning "Por favor, inicie o Docker Desktop manualmente e execute este script novamente"
            echo ""
            echo "1. Abra o Docker Desktop (Applications → Docker)"
            echo "2. Aguarde até que o Docker esteja completamente iniciado"
            echo "3. Execute este script novamente"
            echo ""
            exit 0
        else
            print_warning "Instalação cancelada. Instale o Docker Desktop e execute novamente."
            exit 1
        fi
    else
        print_step "Docker Desktop já instalado"
    fi
    
    # Verificar se Docker está rodando
    if ! docker ps &> /dev/null; then
        print_error "Docker não está em execução!"
        echo ""
        echo "Por favor:"
        echo "1. Abra o Docker Desktop (Applications → Docker)"
        echo "2. Aguarde até que o Docker esteja completamente iniciado"
        echo "3. Execute este script novamente"
        echo ""
        exit 1
    fi
    
    print_step "Docker está em execução"
    
    # Definir diretório de instalação
    XPANEL_DIR="$HOME/xpanel"
    
    # Verificar se diretório já existe
    if [ -d "$XPANEL_DIR" ]; then
        print_warning "Diretório já existe: $XPANEL_DIR"
        read -p "Deseja remover e reinstalar? (s/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            rm -rf "$XPANEL_DIR"
            print_step "Diretório removido"
        else
            print_info "Instalação cancelada"
            exit 0
        fi
    fi
    
    # Criar diretório
    mkdir -p "$XPANEL_DIR"
    cd "$XPANEL_DIR"
    print_step "Diretório criado: $XPANEL_DIR"
    
    # Baixar arquivos de configuração
    print_progress "Baixando arquivos de configuração..."
    
    curl -fsSL "$GITHUB_RAW/docker-compose.yml" -o docker-compose.yml
    curl -fsSL "$GITHUB_RAW/.env.example" -o .env.example
    
    print_step "Arquivos baixados"
    
    # Gerar credenciais
    print_progress "Gerando credenciais seguras..."
    
    DB_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)
    JWT_SECRET=$(openssl rand -base64 64 | tr -d "=+/" | cut -c1-64)
    
    cat > .env <<EOF
# ============================================
# XPanel - Environment Variables
# Gerado automaticamente em: $(date)
# ============================================

# Database Configuration
POSTGRES_DB=xpanel
POSTGRES_USER=xpanel
POSTGRES_PASSWORD=$DB_PASSWORD

# JWT Configuration
JWT_SECRET=$JWT_SECRET
JWT_EXPIRES_IN=7d

# Server Configuration
NODE_ENV=production
FRONTEND_PORT=3000

# GitHub Container Registry
GITHUB_USERNAME=$GITHUB_USERNAME
VERSION=$VERSION
EOF
    
    print_step "Credenciais geradas"
    
    # Baixar imagens Docker
    print_progress "Baixando imagens Docker..."
    echo ""
    
    docker pull postgres:15-alpine
    docker pull ghcr.io/$GITHUB_USERNAME/xpanel-backend:$VERSION
    docker pull ghcr.io/$GITHUB_USERNAME/xpanel-frontend:$VERSION
    
    echo ""
    print_step "Imagens baixadas"
    
    # Iniciar containers
    print_progress "Iniciando containers..."
    
    docker compose up -d
    
    print_progress "Aguardando containers iniciarem..."
    sleep 15
    
    print_step "Containers iniciados"
    
    # Inicializar banco de dados
    print_progress "Inicializando banco de dados..."
    sleep 5
    
    docker compose exec -T backend npx prisma db push 2>/dev/null || true
    print_step "Banco de dados inicializado"
    
    # Criar usuário admin
    print_progress "Criando usuário administrador..."
    
    docker compose exec -T backend node -e "
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
            await prisma.\$disconnect();
        }
    }
    
    createAdmin();
    " 2>/dev/null || print_warning "Usuário admin pode já existir"
    
    print_step "Usuário administrador criado"
    
    # Criar scripts de atalho
    print_progress "Criando scripts de atalho..."
    
    cat > start.sh <<'EOFSCRIPT'
#!/bin/bash
cd "$(dirname "$0")"
docker compose start
echo "✓ XPanel iniciado!"
echo "→ Acesse: http://localhost:3000"
EOFSCRIPT
    
    cat > stop.sh <<'EOFSCRIPT'
#!/bin/bash
cd "$(dirname "$0")"
docker compose stop
echo "✓ XPanel parado!"
EOFSCRIPT
    
    cat > restart.sh <<'EOFSCRIPT'
#!/bin/bash
cd "$(dirname "$0")"
docker compose restart
echo "✓ XPanel reiniciado!"
echo "→ Acesse: http://localhost:3000"
EOFSCRIPT
    
    cat > logs.sh <<'EOFSCRIPT'
#!/bin/bash
cd "$(dirname "$0")"
docker compose logs -f
EOFSCRIPT
    
    cat > status.sh <<'EOFSCRIPT'
#!/bin/bash
cd "$(dirname "$0")"
docker compose ps
EOFSCRIPT
    
    chmod +x start.sh stop.sh restart.sh logs.sh status.sh
    
    print_step "Scripts de atalho criados"
    
    # Criar arquivo de informações
    cat > INSTALLATION_INFO.txt <<EOF
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║                  XPanel - Informações de Instalação            ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝

Data de Instalação: $(date)
Sistema: macOS $MACOS_VERSION
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
║ COMANDOS ÚTEIS                                                 ║
╚════════════════════════════════════════════════════════════════╝

Navegar para o diretório:
  cd $XPANEL_DIR

Scripts de atalho:
  ./start.sh      - Iniciar XPanel
  ./stop.sh       - Parar XPanel
  ./restart.sh    - Reiniciar XPanel
  ./logs.sh       - Ver logs
  ./status.sh     - Ver status

Comandos Docker Compose:
  docker compose ps           - Ver status
  docker compose logs -f      - Ver logs
  docker compose restart      - Reiniciar
  docker compose stop         - Parar
  docker compose start        - Iniciar

Atualizar XPanel:
  docker compose pull
  docker compose up -d

Backup do banco de dados:
  docker compose exec postgres pg_dump -U xpanel xpanel > backup.sql

Restaurar banco de dados:
  docker compose exec -T postgres psql -U xpanel xpanel < backup.sql

Desinstalar:
  docker compose down -v
  rm -rf $XPANEL_DIR

╔════════════════════════════════════════════════════════════════╗
║ SUPORTE                                                        ║
╚════════════════════════════════════════════════════════════════╝

GitHub: https://github.com/$GITHUB_USERNAME/install-xpanel
Issues: https://github.com/$GITHUB_USERNAME/install-xpanel/issues
Email: suporte@sxconnect.com.br

EOF
    
    print_step "Arquivo de informações criado"
    
    # Mensagem de sucesso
    echo ""
    echo -e "${GREEN}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                                                                ║"
    echo "║              ✓ XPanel Instalado com Sucesso!                  ║"
    echo "║                                                                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    echo -e "${CYAN}┌────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC}  ${BLUE}Acesse o painel em:${NC}                                      ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${YELLOW}http://localhost:3000${NC}                                    ${CYAN}│${NC}"
    echo -e "${CYAN}└────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    echo -e "${CYAN}┌────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC}  ${BLUE}Credenciais de acesso:${NC}                                   ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  Email: ${GREEN}admin@xpanel.local${NC}                               ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  Senha: ${GREEN}admin123${NC}                                         ${CYAN}│${NC}"
    echo -e "${CYAN}└────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    echo -e "${RED}⚠️  IMPORTANTE: Altere a senha após o primeiro login!${NC}"
    echo ""
    echo -e "${BLUE}📄 Informações completas em:${NC} $XPANEL_DIR/INSTALLATION_INFO.txt"
    echo ""
    echo -e "${GREEN}🎉 Instalação concluída! Aproveite o XPanel! 🎉${NC}"
    echo ""
    
    read -p "Deseja abrir o XPanel no navegador agora? (s/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        open "http://localhost:3000"
    fi
}

################################################################################
# Instalação Windows
################################################################################

install_windows() {
    print_error "Instalação via Bash não suportada no Windows"
    echo ""
    echo -e "${YELLOW}Para instalar no Windows, use o instalador PowerShell:${NC}"
    echo ""
    echo "1. Baixe o instalador:"
    echo "   ${CYAN}https://raw.githubusercontent.com/$GITHUB_USERNAME/install-xpanel/main/install-windows.ps1${NC}"
    echo ""
    echo "2. Execute no PowerShell como Administrador:"
    echo "   ${CYAN}Set-ExecutionPolicy Bypass -Scope Process -Force${NC}"
    echo "   ${CYAN}.\\install-windows.ps1${NC}"
    echo ""
    echo "Ou use o instalador direto:"
    echo "   ${CYAN}irm https://raw.githubusercontent.com/$GITHUB_USERNAME/install-xpanel/main/install-windows.ps1 | iex${NC}"
    echo ""
    exit 1
}

################################################################################
# Execução Principal
################################################################################

main() {
    print_header
    
    # Detectar sistema operacional
    detect_os
    
    echo ""
    print_info "Sistema detectado: $DETECTED_OS"
    echo ""
    
    # Executar instalação apropriada
    case "$DETECTED_OS" in
        linux)
            install_linux
            ;;
        macos)
            install_macos
            ;;
        windows)
            install_windows
            ;;
        *)
            print_error "Sistema operacional não suportado: $DETECTED_OS"
            exit 1
            ;;
    esac
}

# Executar instalação
main
