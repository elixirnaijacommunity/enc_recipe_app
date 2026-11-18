defmodule RecipeApp.Repo.Migrations.AddAuthVersionToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :auth_version, :integer, null: false, default: 0
    end
  end
end
