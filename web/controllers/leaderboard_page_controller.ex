defmodule RlTools.LeaderboardPageController do
  use RlTools.Web, :controller

  def leaderboard(conn, %{"leaderboard_id" => id}) do
    leaderboard = RlTools.Repo.one!(from(l in RlTools.Leaderboard,
        where: l.api_id == ^id))
    last_fetch = Repo.one!(from f in RlTools.FetchPass,
        where: not is_nil(f.end),
        order_by: [desc: f.time],
        limit: 1)

    leaderboard_values = Repo.all(from v in RlTools.LeaderboardValue,
        where: v.leaderboard_id == ^leaderboard.id
            and v.fetch_pass_id == ^last_fetch.id,
        order_by: [desc: v.value],
        limit: 100,
        preload: [:player])

    render conn, "leaderboard.html", %{
      leaderboard: leaderboard,
      leaderboard_values: leaderboard_values
    }
  end

  def index(conn, _params) do
    leaderboards = Repo.all(RlTools.Leaderboard)
    last_fetch = Repo.one!(from f in RlTools.FetchPass,
        where: not is_nil(f.end),
        order_by: [desc: f.time],
        limit: 1)

    leaderboard_values = for leaderboard <- leaderboards do
      Repo.all(from v in RlTools.LeaderboardValue,
          where: v.leaderboard_id == ^leaderboard.id
            and v.fetch_pass_id == ^last_fetch.id,
          order_by: [desc: v.value],
          limit: 100,
          preload: [:player])
    end

    render conn, "index.html", %{
      leaderboards: leaderboards,
      leaderboard_values: leaderboard_values
    }
  end
end
