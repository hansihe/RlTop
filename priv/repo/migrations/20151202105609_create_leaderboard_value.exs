defmodule RlTools.Repo.Migrations.CreateLeaderboardValue do
  use Ecto.Migration

  def change do
    create table(:leaderboardvalues) do
      add :value, :integer
      add :has_changed, :boolean
      add :value_num, :integer
      add :time, :datetime

      add :player_id, references(:players)
      add :leaderboard_id, references(:leaderboards)
      add :fetch_pass_id, references(:fetchpasses)
    end

  end
end
