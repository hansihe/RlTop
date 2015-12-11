defmodule RlTools.Fetcher.Util do
  def system_time do
    {mega, seconds, ms} = :os.timestamp()
    (mega*1000000 + seconds)*1000 + :erlang.round(ms/1000)
  end
end

defmodule RlTools.Fetcher.SessionServer do
  use GenServer
  import RlTools.Fetcher.Util, only: [system_time: 0]

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
    RLApi.login!(session)
  end

  def update_if_expired({time, session}) do
    if (time + @session_expire_millis) < system_time do
      {system_time, RLApi.Session.make_from_config |> login_session}
    else
      {time, session}
    end
  end

  def handle_call(:get_session, _, state) do
    #IO.inspect state
    state = {time, session} = update_if_expired(state)
    #IO.inspect state
    {:reply, session, state}
  end
end

defmodule RlTools.Fetcher do
end

defmodule RlTools.Fetcher.Scheduler do
  use GenServer

  @fetch_pass_period_millis 1000 * 60 * 30 # Half an hour

  alias RlTools.Fetcher.DbOperations
  alias RlTools.Fetcher.ApiUtils

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, [name: __MODULE__])
  end

  # Called by quantum every time we want to run a fetch.
  # See config file.
  def cron_run_fetch do
    GenServer.cast(__MODULE__, :run_fetch_pass)
  end

  def init(:ok) do
    #last_fetch = DbOperations.get_last_fetch_datetime()
    #IO.inspect last_fetch
    #case last_fetch do
      #  nil -> send(self(), :run_fetch_pass)
      #time -> throw "Implement this" #TODO: Do this properly
      #end
    {:ok, nil}
  end

  def register_leaderboards_top_players do
    session = RlTools.Fetcher.SessionServer.get_session
    players = ApiUtils.get_leaderboards_top_players(session)

    Enum.each(players, fn({_, player_kv}) ->
      {:ok, _player} = DbOperations.upsert_player(player_kv)
    end)
  end


  def fetch_players(fetch_pass, platform) do
    session = RlTools.Fetcher.SessionServer.get_session
    leaderboards = RlTools.Repo.all(RlTools.Leaderboard)
    players = DbOperations.get_unfetched_players_for_pass(fetch_pass, platform)

    unless players == [] do
      player_ids = Enum.map(players, fn(p) -> p.player_id end)

      player_lb_values = RlTools.Fetcher.ApiUtils.get_player_values(
      platform, session, leaderboards, player_ids)

      Enum.each(player_lb_values, fn({leaderboard, players}) ->
        Enum.each(players, fn(player) ->
          {:ok, player_model} = DbOperations.upsert_player(player)
          {:ok, _} = DbOperations.register_leaderboard_value(
          leaderboard, fetch_pass, player_model, player.value)
        end)
      end)

      fetch_players(fetch_pass, platform)
    end
  end

  def handle_cast(:run_fetch_pass, state) do
    {:ok, fetch_pass} = DbOperations.insert_fetch_pass()

    session = RlTools.Fetcher.SessionServer.get_session

    register_leaderboards_top_players()
    fetch_players(fetch_pass, :steam)
    fetch_players(fetch_pass, :psn)

    IO.inspect length(RlTools.Repo.all(RlTools.Player))

    #response = RLApi.call_procset(session, get_leaderboards_top_players(session))
    #IO.inspect response
    {:noreply, state}
  end
end

defmodule RlTools.Fetcher.FetchWorker do
  use GenServer

  def start_link([]) do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def init(:ok) do
    {:ok, nil}
  end
end

defmodule RlTools.Fetcher.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    pool_options = [
      name: {:local, :rl_fetcher_pool},
      worker_module: RlTools.Fetcher.FetchWorker,
      size: 4,
      max_overflow: 0
    ]

    children = [
      worker(RlTools.Fetcher.SessionServer, []),
      :poolboy.child_spec(:rl_fetcher_pool, pool_options, []),
      worker(RlTools.Fetcher.Scheduler, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
