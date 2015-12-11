defmodule RlTools.PlayerStatsPageController do
  use RlTools.Web, :controller
  import Ecto.Query, only: [from: 2]

  def platform_to_atom("steam"), do: :steam
  def platform_to_atom("psn"), do: :psn

  def index(conn, params) do
    platform = platform_to_atom(String.downcase(params["platform"]))
    player_id = params["player_id"]
    player = RlTools.Repo.one!(from(p in RlTools.Player, 
        where: p.platform == ^platform and p.player_id == ^player_id))
    IO.inspect player
    render conn, "index.html", %{
      player: player
    }
  end
end
