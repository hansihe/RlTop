defmodule RlTools.Fetcher.ApiUtils do

  alias RLApi.ProcSet
  alias RLApi.Proc.Leaderboard
  alias RLApi.Proc.LeaderboardUsers

  def changeset_from_player_kv({_, player}) do
    fields = %{
      name: player.username, 
      platform: player.platform, 
      full_id: player.full_id, 
      player_id: player.id
    }
    RlTools.Player.changeset(%RlTools.Player{}, fields)
  end

  def get_leaderboards_top_players(session) do
    leaderboards = RlTools.Repo.all(RlTools.Leaderboard)

    procset = Enum.reduce(leaderboards, %ProcSet{}, 
      fn leaderboard, procset -> 
        proc = Leaderboard.make(leaderboard.request_type, 
                                leaderboard.request_id, leaderboard)
        ProcSet.call(procset, proc) 
      end)

    {:ok, response} = RLApi.call_procset(session, procset)
    players = response.procs
              |> Enum.flat_map(fn(proc) -> proc.decoded end)
              |> Enum.map(fn(player) -> {player.full_id, player} end)
              |> Enum.into(%{})

    players
  end

  def player_ranks_proc_from_leaderboard_model(platform, leaderboard, players) do
    LeaderboardUsers.make(
        leaderboard.request_type, platform, 
        leaderboard.request_id, players, leaderboard)
  end

  def get_player_values(platform, session, leaderboards, players) do
    procset = Enum.reduce(leaderboards, %ProcSet{},
      fn leaderboard, procset ->
        ProcSet.call(procset, 
          player_ranks_proc_from_leaderboard_model(platform, leaderboard, players)) end)

    {:ok, response} = RLApi.call_procset(session, procset)

    Enum.map(response.procs, fn(proc) ->
      {proc.id, proc.decoded}
    end)
  end

end
