defmodule RlTools.Fetcher.DbOperations do

  import Ecto.Query, only: [from: 2]
  import Ecto.Query.API, only: [fragment: 1]
  alias RlTools.Repo

  alias RlTools.FetchPass
  alias RlTools.Player
  alias RlTools.Leaderboard
  alias RlTools.LeaderboardValue
  
  def get_last_fetch_datetime() do
    query = from(f in FetchPass,
        order_by: f.time,
        limit: 1,
        select: f.time)
    last_fetch = Repo.one query
    last_fetch
  end

  def insert_fetch_pass() do
    FetchPass.changeset(%FetchPass{}, %{time: Ecto.DateTime.utc})
    |> Repo.insert
  end

  def get_unfetched_players_for_pass(fetch_pass, platform, limit \\ 100) do
    fetch_pass_id = fetch_pass.id
    #leaderboard_values_query = from(l in LeaderboardValue,
    #    where: l.fetch_pass_id == ^fetch_pass_id)
    #leaderboard_values_query = fragment("select id,fetch_pass_id from leaderboardvalues where fetch_pass_id = ?", fetch_pass_id)
    #query = from(p in Player, 
    #    left_join: l in fragment("select id,fetch_pass_id from leaderboardvalues where fetch_pass_id = ?", ^fetch_pass_id),
    #    on: p.id == l.player_id,
    #    where: is_nil(l.id) and p.platform == ^platform,
    #    limit: ^limit)
    query = from(p in Player,
        where: (p.platform == ^platform)
            and (is_nil(p.latest_fetch_id) or (p.latest_fetch_id != ^fetch_pass_id)),
        limit: ^limit)
    Repo.all(query)
  end

  def upsert_player(%RLApi.Proc.Player{} = player) do
    result = Player.changeset(%Player{}, %{
      name: player.username,
      platform: player.platform,
      full_id: player.full_id,
      player_id: player.id })
    |> Repo.insert

    case result do
      {:ok, player} -> {:ok, result}
      {:error, %{errors: [full_id: "has already been taken"]}} ->
        result = Repo.get_by!(Player, full_id: player.full_id)
        updated = Player.changeset(result, %{
          name: player.username })
        |> Repo.update!
        {:ok, updated}
      {:error, error} -> {:error, error}
    end
  end

  defp has_value_changed(_, nil), do: true
  defp has_value_changed(new_value, last_value), do: new_value != last_value.value

  defp get_value_num(nil), do: 0
  defp get_value_num(last), do: last.value_num + 1

  def register_leaderboard_value(%Leaderboard{} = leaderboard, 
                                 %FetchPass{} = fetch_pass,
                                 %Player{} = player, value) do
    # TODO: Check if one alreay exists (is it needed?)
    {:ok, res} = Repo.transaction(fn ->
      Player.changeset(player, %{
        latest_fetch_id: fetch_pass.id })
      |> Repo.update

      last_value = from(v in LeaderboardValue,
          where: v.player_id == ^player.id and v.leaderboard_id == ^leaderboard.id,
          order_by: v.time,
          limit: 1)
      |> Repo.one

      LeaderboardValue.changeset(%LeaderboardValue{}, %{
        has_changed: has_value_changed(value, last_value),
        value_num: get_value_num(last_value),
        player_id: player.id,
        leaderboard_id: leaderboard.id,
        fetch_pass_id: fetch_pass.id,
        value: value,
        time: Ecto.DateTime.utc })
      |> Repo.insert
    end)
    res
  end

end
