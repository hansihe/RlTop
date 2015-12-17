defmodule RlTools.SharedView do
  use RlTools.Web, :view

  def get_leaderboards do
    RlTools.Repo.all(RlTools.Leaderboard)
  end
end
