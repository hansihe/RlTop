defmodule RlTools.Repo.Migrations.CreateLeaderboard do
  use Ecto.Migration

  def change do
    create table(:leaderboards) do
      add :name, :string
      add :api_id, :string

      add :request_id, :string
      add :request_type, :integer

      timestamps
    end

    create unique_index(:leaderboards, [:api_id])
  end
end
