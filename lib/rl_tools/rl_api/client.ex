
defmodule RLApi do

  @error_regex ~r/^\w+ ERROR/

  @login_path "/login105/"
  def login_url(%RLApi.Session{baseUrl: base}), do: base <> @login_path

  @proc_path "/callproc105/"
  def proc_url(%RLApi.Session{baseUrl: base}), do: base <> @proc_path

  def login(%RLApi.Session{} = session) do
    params = [
      "PlayerName": session.playerName,
      "PlayerID": session.playerId,
      "Platform": session.platform,
      "BuildID": session.buildId]
    headers = [
      "User-Agent": "RLTools (contact: hansihe on reddit)",
      "Content-Type": "application/x-www-form-urlencoded",
      "LoginSecretKey": session.loginSecret]
    %{body: body, headers: headers} = 
        HTTPoison.post!(login_url(session), "&" <> URI.encode_query(params), headers)
    if body == "1" do
      {:ok, %{session | authed: true, sessionId: headers["SessionID"]}}
    else
      {:error, body}
    end
  end
  def login!(session) do
    {:ok, resp} = login(session)
    resp
  end

  def call_procset(%RLApi.Session{} = session, %RLApi.ProcSet{} = procset) do
    IO.inspect "Call ProcSet"
    query = RLApi.ProcSet.to_query(procset)
    headers = [{:"Content-Type", "application/x-www-form-urlencoded"} | RLApi.Session.request_headers(session)]
    response = HTTPoison.post!(proc_url(session), query, headers)
    if Regex.match?(@error_regex, response.body) do
      {:error, response.body}
    else
      {:ok, RLApi.ProcSet.handle_response(procset, response.body)}
    end
  end

  def test() do
    proc = RLApi.Proc.LeaderboardUsers.make(:skill, :steam, "10", ["76561198004966749"])
    #proc2 = %RLApi.Proc{proc: "GetSkillLeaderboard", params: ["10"]}
    proc2 = RLApi.Proc.Leaderboard.make(:skill, "10")
    #GetSkillLeaderboardRankForUsersSteam
    RLApi.Session.make_from_config 
    |> RLApi.login!
    |> RLApi.call_procset(%RLApi.ProcSet{} 
    |> RLApi.ProcSet.call(proc)
    |> RLApi.ProcSet.call(proc2))
  end

end
