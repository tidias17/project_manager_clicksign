# Gerenciador de Projetos

Aplicação full-stack para gerenciamento de projetos com CRUD completo, filtros, favoritos e busca.

## Stack

| Camada | Tecnologia |
|---|---|
| Frontend | Astro + Svelte + Tailwind CSS |
| Backend | Ruby on Rails 8 (API-only) |
| Banco de dados | PostgreSQL 16 |
| Deploy backend | Render |
| Deploy frontend | Vercel |

## Estrutura do repositório

```
gerenciador-projetos/
├── frontend/          # Astro + Svelte
├── backend-rails/     # Rails API-only
└── docker-compose.yml # PostgreSQL local
```

## Setup local

### Pré-requisitos

- [rbenv](https://github.com/rbenv/rbenv) + Ruby 3.3.6
- Node.js 22+
- Docker e Docker Compose

### 1. Clone o repositório

```bash
git clone <repo-url> gerenciador-projetos
cd gerenciador-projetos
```

### 2. Configure o Ruby

```bash
# Instalar rbenv (se ainda não tiver)
brew install rbenv ruby-build

# Adicionar ao shell (adicione também ao ~/.zshrc para persistir)
eval "$(rbenv init -)"

# Instalar Ruby 3.3.6
rbenv install 3.3.6
```

### 3. Suba o banco de dados

```bash
docker compose up -d
```

O Docker Compose sobe um PostgreSQL 16 na porta `5432`.

### 4. Configure e inicie o backend

```bash
cd backend-rails

cp .env.example .env   # ajuste as variáveis se necessário

bundle install
bin/rails db:create db:migrate
bin/rails server -p 3001
# API em http://localhost:3001
```

### 5. Configure e inicie o frontend

```bash
cd frontend

cp .env.example .env   # ajuste PUBLIC_API_URL se necessário

npm install
npm run dev
# App em http://localhost:4321
```

## Variáveis de ambiente

### Backend (`backend-rails/.env`)

| Variável | Padrão | Descrição |
|---|---|---|
| `DB_HOST` | `localhost` | Host do PostgreSQL |
| `DB_PORT` | `5432` | Porta do PostgreSQL |
| `DB_USER` | `postgres` | Usuário do banco |
| `DB_PASSWORD` | `postgres` | Senha do banco |
| `DB_NAME` | `gerenciador_projetos_rails` | Nome do banco |
| `CORS_ORIGINS` | `http://localhost:4321` | Origens permitidas pelo CORS |

### Frontend (`frontend/.env`)

| Variável | Padrão | Descrição |
|---|---|---|
| `PUBLIC_API_URL` | `http://localhost:3001` | URL da API backend |

## Endpoints da API

| Método | Rota | Descrição |
|---|---|---|
| `GET` | `/up` | Health check |
| `POST` | `/api/projects` | Criar projeto |
| `GET` | `/api/projects` | Listar projetos |
| `GET` | `/api/projects/:id` | Buscar projeto |
| `PATCH` | `/api/projects/:id` | Atualizar projeto |
| `DELETE` | `/api/projects/:id` | Remover projeto |

### Query params em `GET /api/projects`

| Param | Tipo | Descrição |
|---|---|---|
| `search` | string | Busca por nome (ILIKE, mín. 3 chars) |
| `favorite` | `"true"` | Apenas favoritos |
| `orderBy` | `alpha` \| `recent` \| `deadline` | Ordenação |

## Deploy

| Serviço | Plataforma | Observação |
|---|---|---|
| Frontend | Vercel | Variável `PUBLIC_API_URL` apontando para o backend |
| Backend | Render | Variável `CORS_ORIGINS` com o domínio do Vercel |
| Banco | Supabase | `DATABASE_URL` configurada no Render |

## Decisões técnicas

**Astro + Svelte** — Astro gerencia rotas e SSR; Svelte mantém bundle pequeno e reatividade sem boilerplate.

**Rails API-only** — ActiveRecord elimina boilerplate de mapeamento objeto-relacional. Validações, serialização e queries centralizam no model sem camadas extras.

**PostgreSQL UUID** — Chave primária gerada via extensão `pgcrypto` (`gen_random_uuid()`), sem dependência de sequência numérica do banco.

**camelCase ↔ snake_case** — O initializer `json_camel_to_snake` converte automaticamente o body JSON recebido (camelCase do frontend) para snake_case do Ruby, e o `as_json` do model faz o caminho inverso na resposta.

**Imagem como base64** — Armazenada como TEXT no PostgreSQL. Simples para o escopo do projeto. Em produção, o correto seria S3/Cloud Storage com URL no banco.

**Histórico de busca em localStorage** — Client-side, sem necessidade de backend ou autenticação.

**Estado dos filtros na URL** — `searchParams` permitem bookmarking e compartilhamento da listagem filtrada.
