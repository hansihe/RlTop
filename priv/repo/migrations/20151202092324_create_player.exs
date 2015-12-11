defmodule RlTools.Repo.Migrations.CreatePlayer do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :full_id, :string
      add :player_id, :string
      add :platform, :integer
      add :name, :string

      add :latest_fetch_id, :integer

      timestamps
    end

    create unique_index(:players, [:full_id])
  end
end
