defmodule RlTools.Fetcher.Util do
  def system_time do
    {mega, seconds, ms} = :os.timestamp()
    (mega*1000000 + seconds)*1000 + :erlang.round(ms/1000)
  end
end

defmodule RlTools.Fetcher.SessionServer do
  use GenServer
  import RlTools.Fetcher.Util, only: [system_time: 0]
  require Logger

  @session_expire_millis 4000

  def start_link(options \\ [name: __MODULE__]) do
    GenServer.start_link(__MODULE__, :ok, options)
  end

  def get_session(server \\ __MODULE__) do
    GenServer.call(server, :get_session)
  end

  def init(:ok) do
    session = RLApi.Session.make_from_config
    |> login_session
    {:ok, {system_time, session}}
  end

  def login_session(session) do
    RLApi.login(session)
  end

  def update_if_expired({time, session}) do
    if (time + @session_expire_millis) < system_time do
      case RLApi.Session.make_from_config |> login_session do
        {:ok, session} -> {:ok, {system_time, session}}
        {:error, resp} -> 
          Logger.warn "Error in response from RL auth server: " <> resp, response: resp
          {:error, resp}
      end
    else
      {:ok, {time, session}}
    end
  end

  def handle_call(:get_session, _, state) do
    conf = Application.get_env(:rl_tools, :rl_api)
    #case update_if_expired(state) do
      #  {:ok, state = {_, session}} -> {:reply, {:ok, session}, state}
      #{:error, _} -> {:reply, {:error}, state}
      #end
      st = %{RLApi.Session.make_from_config | authed: true,  sessionId: conf[:session_key]}
      {:reply, {:ok, st}, state}
  end
end

defmodule RlTools.Fetcher.Scheduler do
  use GenServer

  alias RlTools.Fetcher.DbOperations
  alias RlTools.Fetcher.ApiUtils

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, [name: __MODULE__])
  end

  # Called by quantum every time we want to run a fetch.
  # Also commonly called from repl for testing.
  # This is safe to call at any time.
  # See config file.
  def cron_run_fetch do
    GenServer.cast(__MODULE__, :run_fetch_pass)
  end

  def cron_keep_session_alive do
    GenServer.cast(__MODULE__, :run_session_keepalive)
  end

  def init(:ok) do
    {:ok, nil}
  end

  def fetch_players_db(fetch_pass, platform) do
    players = DbOperations.get_unfetched_players_for_pass(fetch_pass, platform)
    unless players == [] do
      player_ids = for player <- players, do: player.player_id
      RlTools.Fetcher.ApiDbUtils.fetch_players(fetch_pass, platform, player_ids)
      fetch_players_db(fetch_pass, platform)
    end
  end

  def handle_cast(:run_fetch_pass, state) do
    {:ok, fetch_pass} = DbOperations.insert_fetch_pass()
    {:ok, session} = RlTools.Fetcher.SessionServer.get_session

    RlTools.Fetcher.ApiDbUtils.insert_top_players()
    fetch_players_db(fetch_pass, :steam)
    fetch_players_db(fetch_pass, :psn)

    {:ok, fetch_pass} = DbOperations.end_fetch_pass(fetch_pass)

    IO.inspect length(RlTools.Repo.all(RlTools.Player))

    {:noreply, state}
  end
  def handle_cast(:run_session_keepalive, state) do
    {:ok, session} = RlTools.Fetcher.SessionServer.get_session

    query = "&PlaylistID=0&NumLocalPlayers=1"
    headers = [{:"Content-Type", "application/x-www-form-urlencoded"} | RLApi.Session.request_headers(session)]
    response = HTTPoison.post!(session.baseUrl <> "/Population/UpdatePlayerCurrentGame/", query, headers)
    case response.body do
      "" -> nil # Everything is fine :D
      _ -> throw "Session invalid, please provide new!" # Should probably notify me
    end

    {:noreply, state}
  end
end

defmodule RlTools.Fetcher.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(RlTools.Fetcher.SessionServer, []),
      worker(RlTools.Fetcher.Scheduler, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
