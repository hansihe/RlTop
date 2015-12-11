defmodule RLApi.Proc.Leaderboard do

  def proc_for_type(:skill), do: "GetSkillLeaderboard"
  def proc_for_type(:stats), do: "GetLeaderboard"

  def extra_args_for_type(:stats), do: ["100"]
  def extra_args_for_type(_), do: []

  def make(type, leaderboard, id \\ nil) do
    %RLApi.Proc{
      proc: proc_for_type(type),
      params: [leaderboard | extra_args_for_type(type)],
      id: id,
      decoder: &decode/1}
  end

  def decode(%RLApi.Proc{} = proc) do
    [_leaderboard_id | players] = proc.response
    decoded_players = Enum.map(players, &RLApi.Proc.Player.from_leaderboard_response/1)
    %{proc | decoded: decoded_players}
  end

end
