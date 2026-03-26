# fisc.io

Gerenciador de finanças pessoais — self-hosted, open source.

Controle suas despesas, monitore sua inflação real e gerencie contas compartilhadas com total privacidade. Seus dados ficam no seu servidor.

**Stack:** FastAPI · PostgreSQL 16 · Vanilla JS · Nginx · Docker

---

## Funcionalidades

### 📱 PWA
Funciona como PWA, pode ser instalado no celular como app nativo.

### 💸 Controle de despesas
Registre despesas com categoria, data, número de parcelas e método de pagamento. Cada despesa fica associada a quem pagou e como foi dividida.

### 👥 Perfis de divisão
Crie perfis de rateio com percentuais personalizados por usuário — por exemplo, 60% Usuario 1 / 40% Usuario 2. Cada despesa compartilhada referencia um perfil, e o sistema calcula automaticamente quanto cabe a cada pessoa no período.

### ⚖️ Balanço entre usuários
O app calcula o balanço líquido entre todos os participantes: quem está no positivo (tem a receber) e quem está no negativo (deve). O cálculo considera quem pagou cada despesa e qual era a divisão acordada.

### 🔁 Despesas recorrentes
Cadastre despesas fixas mensais (aluguel, streaming, assinaturas). Um cron job roda todo dia à meia-noite e gera automaticamente as despesas do mês caso ainda não tenham sido criadas — tolerante a falhas, se o servidor estiver offline no dia 1 ele gera assim que voltar.

### 📊 Gráficos e análises
Visualize seus gastos por categoria, por método de pagamento e por período.

### 📈 Sua inflação real
A aba Inflação calcula a variação de preços que você realmente sentiu no bolso — não o IPCA genérico. O cálculo leva em conta suas categorias de gasto, seus volumes de consumo e os pesos reais de cada item na sua carteira. O resultado é comparado com o IPCA Índice Geral para mostrar se você está acima ou abaixo da média.

### 🔧 Análise Preço × Volume
Para cada categoria, o app decompõe a variação dos seus gastos em dois fatores: quanto mudou por causa de preço (inflação) e quanto mudou por causa de volume (você consumiu mais ou menos). Isso permite entender se você está gastando mais porque os preços subiram ou porque mudou seu padrão de consumo.

### 🎯 Metas por categoria
Defina targets mensais por categoria e método de pagamento. O app compara seus gastos reais com as metas definidas e sinaliza quando você está próximo ou acima do limite.

### 🔔 Notificações push
Receba notificações quando uma despesa for adicionada ou editada, e lembretes mensais com o fechamento do balanço.

### 🌙 Dark mode
Interface completa em modo escuro ou claro, com preferência salva por dispositivo.

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
