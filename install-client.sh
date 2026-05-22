#!/bin/bash
set -e

# ============================================
# XPanel Client - Instalador
# ============================================
# Este script instala apenas o XPanel Client
# (interface pública para usuários)
# ============================================

echo "🚀 XPanel Client - Instalador"
echo "================================"
echo ""

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Variáveis
INSTALL_DIR="$HOME/xpanel-client"
GITHUB_RAW="https://raw.githubusercontent.com/sxconnect/install-xpanel/main"

# Verificar se Docker está instalado
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker não está instalado!${NC}"
    echo "Por favor, instale o Docker primeiro:"
    echo "https://docs.docker.com/get-docker/"
    exit 1
fi

# Verificar se Docker Compose está instalado
if ! command -v docker compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose não está instalado!${NC}"
    echo "Por favor, instale o Docker Compose primeiro:"
    echo "https://docs.docker.com/compose/install/"
    exit 1
fi

echo -e "${BLUE}📦 Criando diretório de instalação...${NC}"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

echo -e "${BLUE}📥 Baixando arquivos de configuração...${NC}"

# Baixar docker-compose
curl -fsSL "$GITHUB_RAW/docker-compose-client.yml" -o docker-compose.yml

# Baixar .env.example
curl -fsSL "$GITHUB_RAW/.env.client.example" -o .env.example

# Criar .env se não existir
if [ ! -f .env ]; then
    echo -e "${BLUE}⚙️  Criando arquivo de configuração...${NC}"
    cp .env.example .env
    
    # Gerar INSTANCE_ID único
    if command -v uuidgen &> /dev/null; then
        INSTANCE_ID=$(uuidgen)
    else
        INSTANCE_ID="client-$(date +%s)-$RANDOM"
    fi
    
    sed -i "s/INSTANCE_ID=.*/INSTANCE_ID=$INSTANCE_ID/" .env
    
    echo ""
    echo -e "${YELLOW}⚠️  IMPORTANTE: Configure o arquivo .env${NC}"
    echo "Edite o arquivo $INSTALL_DIR/.env e configure:"
    echo "  - MASTER_URL: URL do seu servidor XPanel Master"
    echo "  - INSTANCE_NAME: Nome da sua empresa/instalação"
    echo "  - INSTANCE_EMAIL: Seu email"
    echo ""
    read -p "Pressione ENTER para continuar após configurar o .env..."
fi

echo -e "${BLUE}🐳 Iniciando XPanel Client...${NC}"
docker compose up -d

echo ""
echo -e "${GREEN}✅ XPanel Client instalado com sucesso!${NC}"
echo ""
echo "📍 Localização: $INSTALL_DIR"
echo "🌐 Acesse: http://localhost:$(grep CLIENT_PORT .env | cut -d'=' -f2 || echo 3000)"
echo ""
echo "📝 Comandos úteis:"
echo "  docker compose logs -f          # Ver logs"
echo "  docker compose restart          # Reiniciar"
echo "  docker compose stop             # Parar"
echo "  docker compose down             # Remover"
echo ""
echo "🔧 Para reconfigurar, edite: $INSTALL_DIR/.env"
echo ""
