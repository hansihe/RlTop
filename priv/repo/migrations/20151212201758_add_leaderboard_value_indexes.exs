defmodule RlTools.Repo.Migrations.AddLeaderboardValueIndexes do
  use Ecto.Migration

  def change do
    create index(:leaderboardvalues, [:player_id, :leaderboard_id, :fetch_pass_id])
  end
end
