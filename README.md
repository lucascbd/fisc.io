# fisc.io

Personal finance manager — self-hosted, open source.

Track shared expenses, monitor inflation, set targets, and manage recurring bills.

**Stack:** FastAPI · PostgreSQL 16 · Vanilla JS · Nginx · Docker

---

## Deploy com Portainer

### 1. Pré-requisito no servidor

Antes de criar o Stack, coloque o `firebase-credentials.json` no servidor:

```bash
mkdir -p /opt/fiscio
# copie o arquivo para o servidor
scp firebase-credentials.json user@seu-servidor:/opt/fiscio/firebase-credentials.json
```

> Se não for usar push notifications, crie um arquivo vazio:
> `touch /opt/fiscio/firebase-credentials.json`

---

### 2. Criar o Stack no Portainer

1. Abra o Portainer → **Stacks** → **Add Stack**
2. Dê o nome: `fiscio`
3. Selecione **Git Repository**
4. Preencha:
   - **Repository URL:** `https://github.com/seu-usuario/fisc.io`
   - **Branch:** `main`
   - **Compose path:** `docker-compose.yml`
5. Em **Environment variables**, adicione:

| Variável | Valor |
|---|---|
| `POSTGRES_DB` | `budget_db` |
| `POSTGRES_USER` | `budget_user` |
| `POSTGRES_PASSWORD` | uma senha segura |
| `SECRET_KEY` | chave aleatória (ver abaixo) |
| `APP_NAME` | `fisc.io` |
| `DEBUG` | `False` |
| `FIREBASE_CREDENTIALS_PATH` | `/opt/fiscio/firebase-credentials.json` |

6. Clique em **Deploy the Stack**

**Gerar SECRET_KEY:**
```bash
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

---

### 3. Primeiro acesso

- Frontend: `http://seu-servidor:3000`
- API docs: `http://seu-servidor:8000/docs`

Crie o primeiro usuário admin via API:

```bash
curl -X POST http://seu-servidor:8000/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Admin","email":"admin@example.com","password":"suasenha","is_admin":true}'
```

---

### 4. Atualizar

No Portainer → Stacks → fiscio → **Pull and redeploy**

---

### 5. Migrar dados do servidor atual

```bash
# No servidor, antes de subir o Docker
pg_dump -U budget_user budget_db > /opt/fiscio/backup.sql

# Após subir o Stack, restaurar
cat /opt/fiscio/backup.sql | docker exec -i fiscio-db psql -U budget_user -d budget_db
```

---

## Cloudflare Tunnel

Após o deploy, configure os tunnels apontando para:

| Domínio | Porta |
|---|---|
| `fisc-io.lucascbd.app.br` | `localhost:3000` |
| `fisc-io-backend.lucascbd.app.br` | `localhost:8000` |

---

## Cron jobs (automático)

O container `fiscio-cron` roda automaticamente dentro do Docker:

| Horário | Script | Função |
|---|---|---|
| Todo dia 00:00 | `generate_recurring.py` | Gera despesas recorrentes do mês |
| A cada hora | `send_reminders.py` | Envia lembretes mensais |

---

## Estrutura do repositório

```
fisc.io/
├── docker-compose.yml
├── backend/
│   ├── Dockerfile
│   ├── main.py
│   ├── models.py
│   ├── expense_service.py
│   ├── requirements.txt
│   └── ...
├── frontend/
│   ├── Dockerfile
│   ├── nginx.conf
│   ├── index.html
│   └── ...
└── README.md
```

---

## License

MIT
