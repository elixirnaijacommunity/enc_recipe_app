defmodule RecipeApp.Repo.Migrations.AddPasswordResetFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :password_reset_token_hash, :string
      add :password_reset_sent_at, :utc_datetime
    end

    create unique_index(:users, [:password_reset_token_hash])
  end
end
