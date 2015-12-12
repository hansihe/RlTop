defmodule RlTools.LeaderboardPageController do
  use RlTools.Web, :controller

  def index(conn, _params) do
    leaderboards = Repo.all(RlTools.Leaderboard)
    last_fetch = Repo.one!(from f in RlTools.FetchPass,
        order_by: f.time,
        limit: 1)

    leaderboard_values = for leaderboard <- leaderboards do
      Repo.all(from v in RlTools.LeaderboardValue,
          where: v.leaderboard_id == ^leaderboard.id
            and v.fetch_pass_id == ^last_fetch.id,
          order_by: [desc: v.value],
          limit: 100,
          preload: [:player])
    end

    IO.inspect leaderboard_values

    render conn, "index.html", %{
      leaderboards: leaderboards,
      leaderboard_values: leaderboard_values
    }
  end
end
