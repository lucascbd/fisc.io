# fisc.io

Gerenciador de finanças pessoais — self-hosted, open source.

Controle despesas compartilhadas, monitore inflação, defina metas e gerencie contas recorrentes.

**Stack:** FastAPI · PostgreSQL 16 · Vanilla JS · Nginx · Docker

---

## Deploy com Portainer

### 1. Pré-requisito no servidor

Coloque o `firebase-credentials.json` no servidor antes de criar o Stack:

```bash
mkdir -p /opt/fiscio
scp firebase-credentials.json user@seu-servidor:/opt/fiscio/firebase-credentials.json
```

> Se não for usar push notifications, crie um arquivo vazio:
> ```bash
> touch /opt/fiscio/firebase-credentials.json
> ```

---

### 2. Criar o Stack no Portainer

1. Portainer → **Stacks** → **Add Stack**
2. Nome: `fiscio`
3. Selecione **Git Repository**
4. Preencha:
   - **Repository URL:** `https://github.com/lucascbd/fisc.io`
   - **Repository reference:** `refs/heads/main`
   - **Compose path:** `docker-compose.yml`
5. Em **Environment variables**, adicione:

| Variável | Exemplo | Descrição |
|---|---|---|
| `POSTGRES_DB` | `budget_db` | Nome do banco |
| `POSTGRES_USER` | `budget_user` | Usuário do banco |
| `POSTGRES_PASSWORD` | senha segura | Senha do banco |
| `SECRET_KEY` | ver abaixo | Chave JWT |
| `APP_NAME` | `fisc.io` | Nome da aplicação |
| `DEBUG` | `False` | Modo debug |
| `FIREBASE_CREDENTIALS_PATH` | `/opt/fiscio/firebase-credentials.json` | Caminho do arquivo de credenciais Firebase |
| `FRONTEND_PORT` | `3005` | Porta exposta do frontend |
| `BACKEND_PORT` | `8080` | Porta exposta do backend |

6. Clique em **Deploy the Stack**

**Gerar SECRET_KEY:**
```bash
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

---

### 3. Primeiro acesso

Na primeira vez que o backend sobe com o banco vazio, ele cria automaticamente:

- Usuário admin padrão: `admin@admin.com` / `admin`
- Tabelas `categories` e `ipca` populadas com dados iniciais (via `backend/seeds/initial_data.sql`)

> **Troque a senha do admin após o primeiro login.**

Frontend disponível em: `http://seu-servidor:<FRONTEND_PORT>`

---

### 4. Atualizar

No Portainer → Stacks → fiscio → **Pull and redeploy**

O banco de dados **não é apagado** em atualizações. Apenas o código do backend e frontend é atualizado.

---

### 5. Restaurar backup

```bash
# Apaga e recria o banco (necessário para evitar conflitos de schema)
docker exec -i fiscio-db psql -U budget_user -d postgres -c "DROP DATABASE budget_db WITH (FORCE);"
docker exec -i fiscio-db psql -U budget_user -d postgres -c "CREATE DATABASE budget_db OWNER budget_user;"

# Restaura o backup
(echo '\unrestrict'; cat /caminho/backup.sql) | docker exec -i fiscio-db psql -U budget_user -d budget_db
```

> Os erros de `role "postgres" does not exist` durante a restauração são normais e não afetam os dados.

---

## Cloudflare Tunnel

Configure o tunnel apontando apenas para o frontend — o nginx interno roteia as chamadas de API para o backend:

| Domínio | Porta local |
|---|---|
| `seu-dominio.com` | `localhost:<FRONTEND_PORT>` |

O backend **não precisa** ser exposto publicamente. O nginx do container frontend recebe requisições em `/api/` e as proxeia internamente para o backend.

---

## Cron jobs

O container `fiscio-cron` executa automaticamente:

| Horário | Script | Função |
|---|---|---|
| Todo dia 00:00 | `generate_recurring.py` | Gera despesas recorrentes do mês |
| A cada hora | `send_reminders.py` | Envia lembretes de vencimento |
| Todo dia 00:00 | `ipca_ingest.py` | Importa dados do IPCA |

---

## Estrutura do repositório

```
fisc.io/
├── docker-compose.yml
├── backend/
│   ├── Dockerfile
│   ├── main.py
│   ├── models.py
│   ├── config.py
│   ├── database.py
│   ├── expense_service.py
│   ├── firebase_service.py
│   ├── generate_recurring.py
│   ├── send_reminders.py
│   ├── ipca_ingest.py
│   ├── requirements.txt
│   └── seeds/
│       └── initial_data.sql   ← categorias e ipca pré-carregados
├── frontend/
│   ├── Dockerfile
│   ├── nginx.conf             ← proxy /api/ → backend interno
│   └── index.html
└── README.md
```

---

## License

MIT
