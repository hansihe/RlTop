defmodule RLApi.Proc.LeaderboardUsers do

  def proc_for_type(:skill, :steam), do: "GetSkillLeaderboardRankForUsersSteam"
  def proc_for_type(:skill, :psn), do: "GetSkillLeaderboardRankForUsersPSN"
  def proc_for_type(:stats, :steam), do: "GetLeaderboardRankForUsersSteam"
  def proc_for_type(:stats, :psn), do: "GetLeaderboardRankForUsersPSN"

  def padding_for_platform(:steam), do: "0"
  def padding_for_platform(:psn), do: ""

  def make(type, platform, leaderboard, users, id \\ nil) do
    proc = proc_for_type(type, platform)
    padding = padding_for_platform(platform)
    make_raw(proc, platform, padding, leaderboard, users, id)
  end

  defp make_raw(proc, platform, padding, leaderboard, users, id \\ nil) do
    num_users = length(users)
    true = (num_users <= 100)
    users_padded = make_list_len(padding, users, 100 - num_users)
    %RLApi.Proc{
      proc: proc, 
      params: [leaderboard | users_padded], 
      id: id, 
      decoder: fn(res) -> decode(res, platform) end}
  end

  def decode(%RLApi.Proc{} = proc, platform) do
    [_leaderboard_id | data] = proc.response
    decoded_users = Enum.map(data, 
        fn(u) -> RLApi.Proc.Player.from_leaderboard_response(u, platform) end)
    %{proc | decoded: decoded_users}
  end

  defp make_list_len(_, acc, 0), do: acc
  defp make_list_len(ele, acc, n) when n >= 0, do: make_list_len(ele, [ele | acc], n - 1)
end
