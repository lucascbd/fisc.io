"""payment_methods: coluna is_active para soft-delete (arquivamento)

Ao invés de bloquear o delete quando o método está em uso, o backend
arquiva o registro (is_active=False). O método some da lista de seleção
mas o histórico das despesas é preservado com nome/cor/ícone originais.

Revision ID: 0003
Revises: 0002
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "0003"
down_revision: Union[str, None] = "0002"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    conn = op.get_bind()
    exists = conn.execute(sa.text(
        "SELECT 1 FROM information_schema.columns "
        "WHERE table_name = 'payment_methods' AND column_name = 'is_active'"
    )).first()
    if not exists:
        op.add_column(
            "payment_methods",
            sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.true()),
        )


def downgrade() -> None:
    op.drop_column("payment_methods", "is_active")
