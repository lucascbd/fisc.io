FROM python:3.13-slim

WORKDIR /app

# Dependências de sistema (psycopg2 precisa de libpq, psql para seed)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev \
    postgresql-client \
    cron \
    && rm -rf /var/lib/apt/lists/*

# Instalar dependências Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar código (firebase-credentials.json NÃO incluído — vem por volume)
COPY config.py database.py models.py main.py \
     expense_service.py firebase_service.py \
     generate_recurring.py send_reminders.py \
     ipca_ingest.py generate_missing_splits.py ./

COPY seeds/ ./seeds/

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
