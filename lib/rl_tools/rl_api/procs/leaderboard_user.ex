defmodule RLApi.Proc.LeaderboardUser do

  def proc_for_type(:skill, :steam), do: "GetSkillLeaderboardValueForUserSteam"
  def proc_for_type(:skill, :psn), do: "GetSkillLeaderboardValueForUserPSN"
  def proc_for_type(:stats, :steam), do: "GetLeaderboardValueForUserSteam"
  def proc_for_type(:stats, :psn), do: "GetLeaderboardValueForUserPSN"

  def make(type, platform, leaderboard, user_id, id \\ nil) do
    proc = proc_for_type(type, platform)
    %RLApi.Proc{
      proc: proc,
      params: [user_id, leaderboard],
      id: id,
      decoder: fn(res) -> decode(res, platform) end}
  end

  def decode(%RLApi.Proc{} = proc, platform) do
    IO.inspect proc
  end

end
