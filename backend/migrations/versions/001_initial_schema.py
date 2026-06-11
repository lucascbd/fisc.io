"""Initial schema — documents the existing database structure.

This migration represents the schema that was already in production before
Alembic was introduced.  It is intentionally NOT run on existing deployments
(stamp with 'alembic stamp 0001' instead).  New deployments should run
'alembic upgrade head' in place of SQLAlchemy's create_all().

Revision ID: 0001
Revises:
Create Date: 2026-06-10 00:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision: str = "0001"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # ------------------------------------------------------------------
    # users
    # ------------------------------------------------------------------
    op.create_table(
        "users",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("name", sa.String(), nullable=False),
        sa.Column("email", sa.String(), nullable=False),
        sa.Column("password_hash", sa.String(), nullable=False),
        sa.Column("is_admin", sa.Boolean(), nullable=True),
        sa.Column("is_active", sa.Boolean(), nullable=True),
        sa.Column("color", sa.String(length=7), nullable=True),
        sa.Column("emoji", sa.String(length=10), nullable=True),
        sa.Column("display_order", sa.Integer(), nullable=True),
        sa.Column("created_at", sa.DateTime(), nullable=True),
        sa.Column("preferred_payment_method", sa.Integer(), nullable=True),
        sa.Column("preferred_balance_method", sa.Integer(), nullable=True),
        sa.Column("preferred_ipca_location", sa.Integer(), nullable=True),
        sa.Column("hidden_category_ids", sa.String(), nullable=True),
        sa.Column("preferred_split_profile_id", sa.Integer(), nullable=True),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("email"),
    )
    op.create_index(op.f("ix_users_id"), "users", ["id"], unique=False)
    op.create_index(op.f("ix_users_email"), "users", ["email"], unique=True)
    op.create_index(op.f("ix_users_is_active"), "users", ["is_active"], unique=False)

    # ------------------------------------------------------------------
    # payment_methods  (depends on users via FK added after users exists)
    # ------------------------------------------------------------------
    op.create_table(
        "payment_methods",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("description", sa.String(length=100), nullable=False),
        sa.Column("color", sa.String(length=20), nullable=True),
        sa.Column("is_card", sa.Boolean(), nullable=False),
        sa.Column("icon_path", sa.String(length=255), nullable=True),
        sa.Column("user_id", sa.Integer(), nullable=False),
        sa.Column("due_day", sa.Integer(), nullable=True),
        sa.Column("is_closed", sa.Boolean(), nullable=False),
        sa.Column("display_order", sa.Integer(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=True),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_payment_methods_id"), "payment_methods", ["id"], unique=False)
    op.create_index(op.f("ix_payment_methods_user_id"), "payment_methods", ["user_id"], unique=False)

    # Add self-referential FKs on users that point to payment_methods
    op.create_foreign_key(
        "fk_users_preferred_payment_method",
        "users", "payment_methods",
        ["preferred_payment_method"], ["id"],
        ondelete="SET NULL",
    )
    op.create_foreign_key(
        "fk_users_preferred_balance_method",
        "users", "payment_methods",
        ["preferred_balance_method"], ["id"],
        ondelete="SET NULL",
    )

    # ------------------------------------------------------------------
    # categories
    # ------------------------------------------------------------------
    op.create_table(
        "categories",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("name", sa.String(), nullable=False),
        sa.Column("description", sa.String(), nullable=True),
        sa.Column("icon", sa.String(), nullable=True),
        sa.Column("color", sa.String(), nullable=True),
        sa.Column("is_active", sa.Boolean(), nullable=True),
        sa.Column("display_order", sa.Integer(), nullable=True),
        sa.Column("ipca_category_code", sa.Integer(), nullable=True),
        sa.Column("ipca_category_name", sa.String(), nullable=True),
        sa.Column("created_at", sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_categories_id"), "categories", ["id"], unique=False)
    op.create_index(op.f("ix_categories_is_active"), "categories", ["is_active"], unique=False)

    # ------------------------------------------------------------------
    # split_profiles
    # ------------------------------------------------------------------
    op.create_table(
        "split_profiles",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("name", sa.String(), nullable=False),
        sa.Column("description", sa.String(), nullable=True),
        sa.Column("emoji", sa.String(length=10), nullable=True),
        sa.Column("is_active", sa.Boolean(), nullable=True),
        sa.Column("display_order", sa.Integer(), nullable=True),
        sa.Column("created_at", sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_split_profiles_id"), "split_profiles", ["id"], unique=False)
    op.create_index(op.f("ix_split_profiles_is_active"), "split_profiles", ["is_active"], unique=False)

    # ------------------------------------------------------------------
    # split_profile_users
    # ------------------------------------------------------------------
    op.create_table(
        "split_profile_users",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("profile_id", sa.Integer(), nullable=False),
        sa.Column("user_id", sa.Integer(), nullable=False),
        sa.Column("percentage", sa.Numeric(5, 4), nullable=False),
        sa.ForeignKeyConstraint(["profile_id"], ["split_profiles.id"]),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_split_profile_users_id"), "split_profile_users", ["id"], unique=False)
    op.create_index(op.f("ix_split_profile_users_profile_id"), "split_profile_users", ["profile_id"], unique=False)
    op.create_index(op.f("ix_split_profile_users_user_id"), "split_profile_users", ["user_id"], unique=False)

    # ------------------------------------------------------------------
    # expenses
    # ------------------------------------------------------------------
    op.create_table(
        "expenses",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("description", sa.String(), nullable=False),
        sa.Column("total_amount", sa.Numeric(12, 2), nullable=False),
        sa.Column("installments", sa.Integer(), nullable=True),
        sa.Column("expense_date", sa.Date(), nullable=False),
        sa.Column("paid_by_user_id", sa.Integer(), nullable=False),
        sa.Column("category_id", sa.Integer(), nullable=False),
        sa.Column("split_profile_id", sa.Integer(), nullable=False),
        sa.Column("notes", sa.String(), nullable=True),
        sa.Column("payment_method_id", sa.Integer(), nullable=True),
        sa.Column("original_date", sa.Date(), nullable=True),
        sa.Column("is_recurring", sa.Boolean(), nullable=True),
        sa.Column("created_at", sa.DateTime(), nullable=True),
        sa.Column("created_by_user_id", sa.Integer(), nullable=True),
        sa.ForeignKeyConstraint(["category_id"], ["categories.id"]),
        sa.ForeignKeyConstraint(["created_by_user_id"], ["users.id"]),
        sa.ForeignKeyConstraint(["paid_by_user_id"], ["users.id"]),
        sa.ForeignKeyConstraint(["payment_method_id"], ["payment_methods.id"], ondelete="SET NULL"),
        sa.ForeignKeyConstraint(["split_profile_id"], ["split_profiles.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_expenses_id"), "expenses", ["id"], unique=False)
    op.create_index(op.f("ix_expenses_expense_date"), "expenses", ["expense_date"], unique=False)
    op.create_index(op.f("ix_expenses_paid_by_user_id"), "expenses", ["paid_by_user_id"], unique=False)
    op.create_index(op.f("ix_expenses_category_id"), "expenses", ["category_id"], unique=False)
    op.create_index(op.f("ix_expenses_split_profile_id"), "expenses", ["split_profile_id"], unique=False)

    # ------------------------------------------------------------------
    # expense_splits
    # ------------------------------------------------------------------
    op.create_table(
        "expense_splits",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("expense_id", sa.Integer(), nullable=False),
        sa.Column("user_id", sa.Integer(), nullable=False),
        sa.Column("installment_number", sa.Integer(), nullable=False),
        sa.Column("installment_amount", sa.Numeric(10, 2), nullable=False),
        sa.Column("user_percentage", sa.Numeric(5, 4), nullable=False),
        sa.Column("user_amount", sa.Numeric(10, 2), nullable=False),
        sa.Column("paid_amount", sa.Numeric(10, 2), nullable=False),
        sa.Column("balance", sa.Numeric(10, 2), nullable=False),
        sa.Column("due_date", sa.Date(), nullable=False),
        sa.Column("created_at", sa.DateTime(), nullable=True),
        sa.ForeignKeyConstraint(["expense_id"], ["expenses.id"]),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_expense_splits_id"), "expense_splits", ["id"], unique=False)
    op.create_index(op.f("ix_expense_splits_expense_id"), "expense_splits", ["expense_id"], unique=False)
    op.create_index(op.f("ix_expense_splits_user_id"), "expense_splits", ["user_id"], unique=False)
    op.create_index(op.f("ix_expense_splits_due_date"), "expense_splits", ["due_date"], unique=False)
    # Composite indexes from __table_args__
    op.create_index("idx_splits_user_due_date", "expense_splits", ["user_id", "due_date"], unique=False)
    op.create_index("idx_splits_expense_due_date", "expense_splits", ["expense_id", "due_date"], unique=False)

    # ------------------------------------------------------------------
    # device_tokens
    # ------------------------------------------------------------------
    op.create_table(
        "device_tokens",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("user_id", sa.Integer(), nullable=False),
        sa.Column("token", sa.String(length=255), nullable=False),
        sa.Column("device_info", sa.String(length=255), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=True),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=True),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("token"),
    )
    op.create_index(op.f("ix_device_tokens_id"), "device_tokens", ["id"], unique=False)
    op.create_index(op.f("ix_device_tokens_user_id"), "device_tokens", ["user_id"], unique=False)
    op.create_index(op.f("ix_device_tokens_token"), "device_tokens", ["token"], unique=True)

    # ------------------------------------------------------------------
    # notification_preferences
    # ------------------------------------------------------------------
    op.create_table(
        "notification_preferences",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("user_id", sa.Integer(), nullable=False),
        sa.Column("notify_new_expense", sa.Boolean(), nullable=True),
        sa.Column("notify_edit_expense", sa.Boolean(), nullable=True),
        sa.Column("notify_delete_expense", sa.Boolean(), nullable=True),
        sa.Column("notify_reminders", sa.Boolean(), nullable=True),
        sa.Column("reminder_time", sa.String(length=5), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=True),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=True),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("user_id"),
    )
    op.create_index(op.f("ix_notification_preferences_id"), "notification_preferences", ["id"], unique=False)
    op.create_index(op.f("ix_notification_preferences_user_id"), "notification_preferences", ["user_id"], unique=True)

    # ------------------------------------------------------------------
    # targets
    # ------------------------------------------------------------------
    op.create_table(
        "targets",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("user_id", sa.Integer(), nullable=False),
        sa.Column("name", sa.String(length=100), nullable=False),
        sa.Column("emoji", sa.String(length=10), nullable=False),
        sa.Column("monthly_amount", sa.Numeric(10, 2), nullable=False),
        sa.Column("category_ids", sa.String(), nullable=True),
        sa.Column("payment_methods", sa.String(), nullable=True),
        sa.Column("display_mode", sa.String(length=20), nullable=False),
        sa.Column("ticket_months", sa.Integer(), nullable=False),
        sa.Column("sort_order", sa.Integer(), nullable=False),
        sa.Column("is_active", sa.Boolean(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=True),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_targets_id"), "targets", ["id"], unique=False)
    op.create_index(op.f("ix_targets_user_id"), "targets", ["user_id"], unique=False)

    # ------------------------------------------------------------------
    # recurring_expenses
    # ------------------------------------------------------------------
    op.create_table(
        "recurring_expenses",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("description", sa.String(), nullable=False),
        sa.Column("total_amount", sa.Numeric(12, 2), nullable=False),
        sa.Column("category_id", sa.Integer(), nullable=False),
        sa.Column("split_profile_id", sa.Integer(), nullable=False),
        sa.Column("paid_by_user_id", sa.Integer(), nullable=False),
        sa.Column("payment_method_id", sa.Integer(), nullable=True),
        sa.Column("notes", sa.String(), nullable=True),
        sa.Column("insert_day", sa.Integer(), nullable=True),
        sa.Column("interval", sa.Numeric(4, 2), nullable=False),
        sa.Column("is_active", sa.Boolean(), nullable=False),
        sa.Column("is_enabled", sa.Boolean(), nullable=True),
        sa.Column("last_generated_month", sa.String(length=7), nullable=True),
        sa.Column("created_by_user_id", sa.Integer(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=True),
        sa.ForeignKeyConstraint(["category_id"], ["categories.id"]),
        sa.ForeignKeyConstraint(["created_by_user_id"], ["users.id"]),
        sa.ForeignKeyConstraint(["paid_by_user_id"], ["users.id"]),
        sa.ForeignKeyConstraint(["payment_method_id"], ["payment_methods.id"], ondelete="SET NULL"),
        sa.ForeignKeyConstraint(["split_profile_id"], ["split_profiles.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_recurring_expenses_id"), "recurring_expenses", ["id"], unique=False)
    op.create_index(op.f("ix_recurring_expenses_category_id"), "recurring_expenses", ["category_id"], unique=False)
    op.create_index(op.f("ix_recurring_expenses_split_profile_id"), "recurring_expenses", ["split_profile_id"], unique=False)
    op.create_index(op.f("ix_recurring_expenses_paid_by_user_id"), "recurring_expenses", ["paid_by_user_id"], unique=False)

    # ------------------------------------------------------------------
    # incomes
    # ------------------------------------------------------------------
    op.create_table(
        "incomes",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("description", sa.String(), nullable=False),
        sa.Column("amount", sa.Numeric(12, 2), nullable=False),
        sa.Column("income_date", sa.Date(), nullable=False),
        sa.Column("notes", sa.String(), nullable=True),
        sa.Column("user_id", sa.Integer(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=True),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_incomes_id"), "incomes", ["id"], unique=False)
    op.create_index(op.f("ix_incomes_income_date"), "incomes", ["income_date"], unique=False)
    op.create_index(op.f("ix_incomes_user_id"), "incomes", ["user_id"], unique=False)


def downgrade() -> None:
    # Drop in reverse dependency order

    op.drop_table("incomes")

    op.drop_index(op.f("ix_recurring_expenses_paid_by_user_id"), table_name="recurring_expenses")
    op.drop_index(op.f("ix_recurring_expenses_split_profile_id"), table_name="recurring_expenses")
    op.drop_index(op.f("ix_recurring_expenses_category_id"), table_name="recurring_expenses")
    op.drop_index(op.f("ix_recurring_expenses_id"), table_name="recurring_expenses")
    op.drop_table("recurring_expenses")

    op.drop_index(op.f("ix_targets_user_id"), table_name="targets")
    op.drop_index(op.f("ix_targets_id"), table_name="targets")
    op.drop_table("targets")

    op.drop_index(op.f("ix_notification_preferences_user_id"), table_name="notification_preferences")
    op.drop_index(op.f("ix_notification_preferences_id"), table_name="notification_preferences")
    op.drop_table("notification_preferences")

    op.drop_index(op.f("ix_device_tokens_token"), table_name="device_tokens")
    op.drop_index(op.f("ix_device_tokens_user_id"), table_name="device_tokens")
    op.drop_index(op.f("ix_device_tokens_id"), table_name="device_tokens")
    op.drop_table("device_tokens")

    op.drop_index("idx_splits_expense_due_date", table_name="expense_splits")
    op.drop_index("idx_splits_user_due_date", table_name="expense_splits")
    op.drop_index(op.f("ix_expense_splits_due_date"), table_name="expense_splits")
    op.drop_index(op.f("ix_expense_splits_user_id"), table_name="expense_splits")
    op.drop_index(op.f("ix_expense_splits_expense_id"), table_name="expense_splits")
    op.drop_index(op.f("ix_expense_splits_id"), table_name="expense_splits")
    op.drop_table("expense_splits")

    op.drop_index(op.f("ix_expenses_split_profile_id"), table_name="expenses")
    op.drop_index(op.f("ix_expenses_category_id"), table_name="expenses")
    op.drop_index(op.f("ix_expenses_paid_by_user_id"), table_name="expenses")
    op.drop_index(op.f("ix_expenses_expense_date"), table_name="expenses")
    op.drop_index(op.f("ix_expenses_id"), table_name="expenses")
    op.drop_table("expenses")

    op.drop_index(op.f("ix_split_profile_users_user_id"), table_name="split_profile_users")
    op.drop_index(op.f("ix_split_profile_users_profile_id"), table_name="split_profile_users")
    op.drop_index(op.f("ix_split_profile_users_id"), table_name="split_profile_users")
    op.drop_table("split_profile_users")

    op.drop_index(op.f("ix_split_profiles_is_active"), table_name="split_profiles")
    op.drop_index(op.f("ix_split_profiles_id"), table_name="split_profiles")
    op.drop_table("split_profiles")

    op.drop_index(op.f("ix_categories_is_active"), table_name="categories")
    op.drop_index(op.f("ix_categories_id"), table_name="categories")
    op.drop_table("categories")

    # Remove self-referential FKs from users before dropping payment_methods
    op.drop_constraint("fk_users_preferred_balance_method", "users", type_="foreignkey")
    op.drop_constraint("fk_users_preferred_payment_method", "users", type_="foreignkey")

    op.drop_index(op.f("ix_payment_methods_user_id"), table_name="payment_methods")
    op.drop_index(op.f("ix_payment_methods_id"), table_name="payment_methods")
    op.drop_table("payment_methods")

    op.drop_index(op.f("ix_users_is_active"), table_name="users")
    op.drop_index(op.f("ix_users_email"), table_name="users")
    op.drop_index(op.f("ix_users_id"), table_name="users")
    op.drop_table("users")
