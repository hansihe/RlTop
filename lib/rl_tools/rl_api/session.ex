defmodule RLApi.Session do
  defstruct playerName: "Dummy User", playerId: "0", platform: "Steam", buildId: "144590275", 
      loginSecret: nil, callProcKey: nil, db: "BattleCars_Prod", dbVersion: "00.03.0011-00.01.0011",
      baseUrl: "https://psyonix-rl.appspot.com", authed: false, sessionId: nil

  def make_from_config() do
    conf = Application.get_env(:rl_tools, :rl_api)
    %__MODULE__{loginSecret: conf[:loginSecret], callProcKey: conf[:callProcKey]}
  end

  def request_headers(%RLApi.Session{authed: true} = session) do
    [
      "CallProcKey": session.callProcKey,
      "SessionID": session.sessionId,
      "DBVersion": session.dbVersion,
      "DB": session.db
      ]
  end
end
