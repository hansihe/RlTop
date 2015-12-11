defmodule RLApi.Proc.Player do
  defstruct username: nil, value: nil, platform: nil, id: nil, full_id: nil

  def platform_from_string("Steam"), do: :steam
  def platform_from_string("PSN"), do: :psn
  
  def leaderboard_response_id(:psn, params), do: params["UserName"]
  def leaderboard_response_id(:steam, params), do: params["SteamID"]

  def make_full_id(:psn, id), do: "PSN|" <> id
  def make_full_id(:steam, id), do: "Steam|" <> id

  def from_leaderboard_response(params, platform_override \\ nil) do
    platform = if platform_override == nil do
      platform_from_string(params["Platform"])
    else
      platform_override
    end
    {value, ""} = Integer.parse(params["Value"])
    id = leaderboard_response_id(platform, params)
    %__MODULE__{
      platform: platform,
      value: value,
      username: params["UserName"],
      id: id,
      full_id: make_full_id(platform, id)
    }
  end
end

defmodule RLApi.Proc.Utils do
end
