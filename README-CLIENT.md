# 🎯 XPanel Client - Instalador

## 📋 O que é o XPanel Client?

O **XPanel Client** é a interface pública do XPanel que os usuários instalam em seus servidores para:

- ✅ Ver o catálogo de aplicações disponíveis
- ✅ Instalar aplicações com 1 clique
- ✅ Gerenciar aplicações instaladas
- ✅ Conectar com o XPanel Master (servidor central)

## 🏗️ Arquitetura

```
┌─────────────────────────────────────┐
│     XPanel Master (Seu Servidor)    │
│  - Interface Admin (barra lateral)  │
│  - Gerencia catálogo                │
│  - Controla permissões              │
│  - Monitora instalações             │
└─────────────────────────────────────┘
              ↕ API
┌─────────────────────────────────────┐
│   XPanel Client (Servidor Usuário)  │
│  - Interface Pública (sem sidebar)  │
│  - Consome catálogo do Master       │
│  - Instala apps localmente          │
│  - Envia heartbeat                  │
└─────────────────────────────────────┘
```

## 🚀 Instalação Rápida

### Linux / macOS

```bash
curl -fsSL https://raw.githubusercontent.com/sxconnect/install-xpanel/main/install-client.sh | bash
```

### Windows (PowerShell como Admin)

```powershell
irm https://raw.githubusercontent.com/sxconnect/install-xpanel/main/install-client-windows.ps1 | iex
```

## ⚙️ Configuração

Após a instalação, edite o arquivo `.env`:

```bash
# URL do XPanel Master (seu servidor central)
MASTER_URL=https://master.seudominio.com

# Porta do Client
CLIENT_PORT=3000

# Identificação
INSTANCE_NAME=Minha Empresa
INSTANCE_EMAIL=admin@minhaempresa.com
```

## 🎮 Uso

Após instalar, acesse:

**http://localhost:3000**

Você verá:
- Catálogo de aplicações
- Botão "Instalar"
- Botão "Conhecer" (informações)
- Interface limpa sem barra lateral

## 📦 Diferença entre Master e Client

| Recurso | Master | Client |
|---------|--------|--------|
| Interface Admin | ✅ Sim | ❌ Não |
| Barra Lateral | ✅ Sim | ❌ Não |
| Gerenciar Catálogo | ✅ Sim | ❌ Não |
| Ver Catálogo | ✅ Sim | ✅ Sim |
| Instalar Apps | ❌ Não | ✅ Sim |
| Banco de Dados | ✅ PostgreSQL | ❌ Não precisa |
| Backend | ✅ Node.js | ❌ Não precisa |
| Quem instala | Você (admin) | Usuários |

## 🔧 Comandos Úteis

```bash
# Ver logs
docker compose logs -f

# Reiniciar
docker compose restart

# Parar
docker compose stop

# Remover
docker compose down

# Atualizar
docker compose pull
docker compose up -d
```

## 📝 Arquivos

- `docker-compose-client.yml` - Configuração Docker do Client
- `.env.client.example` - Exemplo de configuração
- `install-client.sh` - Instalador Linux/macOS
- `install-client-windows.ps1` - Instalador Windows

## 🆘 Suporte

Se precisar de ajuda:
1. Verifique os logs: `docker compose logs -f`
2. Verifique se o Master está acessível
3. Verifique o arquivo `.env`

## 🎯 Próximos Passos

Após instalar o Client:
1. Configure o `.env` com a URL do Master
2. Acesse http://localhost:3000
3. Veja o catálogo de aplicações
4. Instale suas primeiras aplicações!
