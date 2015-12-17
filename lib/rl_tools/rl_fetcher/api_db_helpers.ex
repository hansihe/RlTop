defmodule RlTools.Fetcher.ApiDbUtils do

  alias RlTools.Fetcher.DbOperations
  alias RlTools.Fetcher.ApiUtils

  def fetch_players(fetch_pass, platform, player_ids) do
    {:ok, session} = RlTools.Fetcher.SessionServer.get_session
    leaderboards = RlTools.Repo.all(RlTools.Leaderboard)
    player_lb_values = ApiUtils.get_player_values(
        platform, session, leaderboards, player_ids)

    for {leaderboard, players} <- player_lb_values do
      for player <- players do
        {:ok, player_model} = DbOperations.upsert_player(player)
        {:ok, value_model} = DbOperations.register_leaderboard_value(
            leaderboard, fetch_pass, player_model, player.value)
        {player_model, value_model}
      end
    end
  end

  def insert_top_players do
    {:ok, session} = RlTools.Fetcher.SessionServer.get_session
    players = ApiUtils.get_leaderboards_top_players(session)

    for {_, player_kv} <- players do
      {:ok, _player} = DbOperations.upsert_player(player_kv)
    end
  end

end
