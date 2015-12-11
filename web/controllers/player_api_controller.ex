defmodule RlTools.PlayerValuesController do
  use RlTools.Web, :controller

  def platform_to_atom("steam"), do: :steam
  def platform_to_atom("psn"), do: :psn

  def fetch_player(conn, params) do
    platform = platform_to_atom(String.downcase(conn.params["platform"]))
    player_id = conn.params["player_id"]
    player = RlTools.Repo.one(from(p in RlTools.Player,
        where: p.platform == ^platform and p.player_id == ^player_id))
    case player do
      nil -> conn |> send_resp(404, "Player not found") |> halt
      player -> conn |> assign(:player, player)
    end
  end
  plug :fetch_player

  def get_leaderboard_values(leaderboard, player) do
    Repo.all(from(v in RlTools.LeaderboardValue,
        where: v.player_id == ^player.id
          and v.leaderboard_id == ^leaderboard.id
          and v.has_changed == true,
        order_by: v.time,
        select: {v.time, v.value}))
  end

  def get_json_values_leaderboard(leaderboard, player) do
    values = get_leaderboard_values(leaderboard, player)
    Enum.map(values, fn ({time, value}) ->
      [Ecto.DateTime.to_string(time), value]
    end)
  end

  def player_values(conn, params) do
    leaderboard_api_ids = String.split(params["leaderboards"], ",")
    leaderboards = Repo.all(from(l in RlTools.Leaderboard,
        where: l.api_id in ^leaderboard_api_ids))
    values = Enum.reduce(leaderboards, %{}, fn (leaderboard, acc) ->
      values = get_json_values_leaderboard(leaderboard, conn.assigns.player)
      Map.put(acc, leaderboard.api_id, %{
        values: values,
        current: List.last(values),
        url_id: leaderboard.api_id,
        name: leaderboard.name
      })
    end)

    json conn, %{
      leaderboards: values,
      time_now: Ecto.DateTime.to_string(Ecto.DateTime.utc)
    }
  end
end
