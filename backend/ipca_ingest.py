# ipca_ingest.py
# -*- coding: utf-8 -*-

"""
Ingestão direta do SIDRA para PostgreSQL (sem interpretar nada):
- Baixa o JSON do endpoint
- Cria tabela bruta com TODAS as colunas do header (TEXT)
- Calcula um SHA-256 do conteúdo da linha (na ordem do header) como chave única
- Insere tudo; duplicatas (mesmo hash) são ignoradas com ON CONFLICT

Tabela: ipca_raw
Colunas extras:
- sidra_row_hash TEXT UNIQUE     -> identifica unicamente o registro bruto
- ingested_at    TIMESTAMP       -> timestamp de ingestão
"""

import os
import json
import hashlib
from urllib.request import urlopen, Request
from datetime import datetime
import psycopg2
from psycopg2 import sql

API_URL = (
    "https://apisidra.ibge.gov.br/values/"
    "t/7060/n1/all/n71/4801/v/63/"
    "p/last%201/"
    "c315/all/"
    "d/v63%202"
)

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://budget_user:budget_pass_2026@localhost:5432/budget_db"
)

TABLE_NAME = "ipca"  # tabela bruta


def log(msg):
    print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] {msg}")


def fetch_json():
    req = Request(API_URL, headers={"User-Agent": "sidra-ingest-minimal"})
    with urlopen(req, timeout=60) as response:
        return json.loads(response.read().decode("utf-8"))


def sanitize_columns(header_keys):
    """
    Saneia nomes de colunas para o PostgreSQL:
    - chaves vazias -> col_<idx>
    - chaves repetidas -> sufixo _2, _3, ...
    Retorna: (safe_cols, mapping) onde mapping: safe_col -> original_key
    """
    used = {}
    safe_cols = []
    mapping = {}

    for i, key in enumerate(header_keys, start=1):
        name = (key or "").strip()
        if not name:
            name = f"col_{i}"
        base = name
        count = used.get(base, 0)
        if count > 0:
            name = f"{base}_{count+1}"
        used[base] = count + 1
        safe_cols.append(name)
        mapping[name] = key
    return safe_cols, mapping


def ensure_table(conn, safe_cols):
    """
    Cria a tabela bruta (se não existir) com:
    - todas as colunas do header (TEXT)
    - sidra_row_hash (TEXT NOT NULL UNIQUE)
    - ingested_at (TIMESTAMP DEFAULT NOW())
    Também garante o índice único no hash.
    """
    col_defs = [sql.SQL("{} TEXT").format(sql.Identifier(c)) for c in safe_cols]
    col_defs.append(sql.SQL("{} TEXT NOT NULL").format(sql.Identifier("sidra_row_hash")))
    col_defs.append(sql.SQL("{} TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()").format(sql.Identifier("ingested_at")))

    create_table = sql.SQL("CREATE TABLE IF NOT EXISTS {} ({});").format(
        sql.Identifier(TABLE_NAME),
        sql.SQL(", ").join(col_defs)
    )
    create_uindex = sql.SQL(
        "CREATE UNIQUE INDEX IF NOT EXISTS {} ON {} ({});"
    ).format(
        sql.Identifier(f"{TABLE_NAME}_rowhash_uidx"),
        sql.Identifier(TABLE_NAME),
        sql.Identifier("sidra_row_hash"),
    )

    with conn.cursor() as cur:
        cur.execute(create_table)
        cur.execute(create_uindex)
    conn.commit()


def compute_row_hash(values_in_order):
    """
    Gera um SHA-256 determinístico a partir da sequência de valores (na ordem do header).
    Converte a lista em JSON (sem sort_keys) para manter a ordem do header.
    """
    payload = json.dumps(values_in_order, ensure_ascii=False, separators=(",", ":"))
    return hashlib.sha256(payload.encode("utf-8")).hexdigest()


def normalize_value(original_key, value):
    """
    Regras de normalização minimalistas:
    - Se a coluna original for 'V' (valor) e vier '-'  -> salva como NULL (None)
    - (Opcional) Se vier '...' você também pode salvar como NULL
    """
    if original_key == "V":
        if value == "-" or value == "...":
            return None
    return value


def insert_rows(conn, safe_cols, mapping, rows):
    """
    Insere linhas com ON CONFLICT (sidra_row_hash) DO NOTHING.
    - Monta a lista de valores na ORDEM do header (safe_cols),
      aplica normalize_value apenas quando a coluna original for 'V',
      calcula o hash, e inclui 'sidra_row_hash' no INSERT.
    """
    insert_cols = list(safe_cols) + ["sidra_row_hash"]  # colunas a inserir
    insert_sql = sql.SQL("""
        INSERT INTO {} ({})
        VALUES ({})
        ON CONFLICT (sidra_row_hash) DO NOTHING;
    """).format(
        sql.Identifier(TABLE_NAME),
        sql.SQL(", ").join(sql.Identifier(c) for c in insert_cols),
        sql.SQL(", ").join(sql.Placeholder() for _ in insert_cols)
    )

    with conn.cursor() as cur:
        for row in rows:
            # valores em ordem do header original (mapeado -> safe_cols)
            ordered_values = []
            for safe_col in safe_cols:
                original_key = mapping[safe_col]
                raw_val = row.get(original_key, None)
                ordered_values.append(normalize_value(original_key, raw_val))

            row_hash = compute_row_hash(ordered_values)
            cur.execute(insert_sql, ordered_values + [row_hash])

    conn.commit()


def main():
    log("Baixando dados da API...")
    data = fetch_json()

    if not isinstance(data, list) or len(data) < 2 or not isinstance(data[0], dict):
        raise RuntimeError("Resposta da API não está no formato esperado.")

    header = data[0]
    rows = data[1:]

    log(f"Header possui {len(header.keys())} colunas.")
    log(f"Dataset possui {len(rows)} registros.")

    original_cols = list(header.keys())
    safe_cols, mapping = sanitize_columns(original_cols)

    conn = psycopg2.connect(DATABASE_URL)

    log("Criando tabela bruta (se não existir) e índice único no hash...")
    ensure_table(conn, safe_cols)

    log("Inserindo registros (duplicatas serão ignoradas pelo hash)...")
    insert_rows(conn, safe_cols, mapping, rows)

    conn.close()
    log("Concluído com sucesso.")


if __name__ == "__main__":
    main()
