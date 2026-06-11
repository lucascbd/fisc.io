"""Pluggy (Open Finance): pluggy_transaction_id em expenses/incomes + tabela pluggy_accounts

Em deployments existentes essas colunas já foram criadas pelo _safe_add_column
do startup — os op.add_column/create_table abaixo são tolerantes a re-execução
via checagem prévia no information_schema.

Revision ID: 0002
Revises: 0001
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision: str = "0002"
down_revision: Union[str, None] = "0001"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def _has_column(table: str, column: str) -> bool:
    conn = op.get_bind()
    return conn.execute(sa.text(
        "SELECT 1 FROM information_schema.columns "
        "WHERE table_name = :t AND column_name = :c"
    ), {"t": table, "c": column}).first() is not None


def _has_table(table: str) -> bool:
    conn = op.get_bind()
    return conn.execute(sa.text(
        "SELECT 1 FROM information_schema.tables WHERE table_name = :t"
    ), {"t": table}).first() is not None


def upgrade() -> None:
    if not _has_column("expenses", "pluggy_transaction_id"):
        op.add_column("expenses", sa.Column("pluggy_transaction_id", sa.String(36), nullable=True))
        op.create_index(
            op.f("ix_expenses_pluggy_transaction_id"), "expenses",
            ["pluggy_transaction_id"], unique=True,
        )

    if not _has_column("incomes", "pluggy_transaction_id"):
        op.add_column("incomes", sa.Column("pluggy_transaction_id", sa.String(36), nullable=True))
        op.create_index(
            op.f("ix_incomes_pluggy_transaction_id"), "incomes",
            ["pluggy_transaction_id"], unique=True,
        )

    if not _has_table("pluggy_accounts"):
        op.create_table(
            "pluggy_accounts",
            sa.Column("id", sa.Integer(), nullable=False),
            sa.Column("user_id", sa.Integer(), nullable=False),
            sa.Column("item_id", sa.String(36), nullable=False),
            sa.Column("pluggy_account_id", sa.String(36), nullable=False),
            sa.Column("account_name", sa.String(200), nullable=False),
            sa.Column("account_type", sa.String(20), nullable=False),
            sa.Column("payment_method_id", sa.Integer(), nullable=True),
            sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=True),
            sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
            sa.ForeignKeyConstraint(["payment_method_id"], ["payment_methods.id"], ondelete="SET NULL"),
            sa.PrimaryKeyConstraint("id"),
        )
        op.create_index(op.f("ix_pluggy_accounts_id"), "pluggy_accounts", ["id"], unique=False)
        op.create_index(op.f("ix_pluggy_accounts_user_id"), "pluggy_accounts", ["user_id"], unique=False)
        op.create_index(
            op.f("ix_pluggy_accounts_pluggy_account_id"), "pluggy_accounts",
            ["pluggy_account_id"], unique=True,
        )


def downgrade() -> None:
    op.drop_index(op.f("ix_pluggy_accounts_pluggy_account_id"), table_name="pluggy_accounts")
    op.drop_index(op.f("ix_pluggy_accounts_user_id"), table_name="pluggy_accounts")
    op.drop_index(op.f("ix_pluggy_accounts_id"), table_name="pluggy_accounts")
    op.drop_table("pluggy_accounts")

    op.drop_index(op.f("ix_incomes_pluggy_transaction_id"), table_name="incomes")
    op.drop_column("incomes", "pluggy_transaction_id")

    op.drop_index(op.f("ix_expenses_pluggy_transaction_id"), table_name="expenses")
    op.drop_column("expenses", "pluggy_transaction_id")
