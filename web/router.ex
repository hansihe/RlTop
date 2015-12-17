defmodule RlTools.Router do
  use RlTools.Web, :router

  def put_empty_title(conn, _), do: conn |> assign(:title, nil)

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_empty_title
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", RlTools do
    pipe_through :browser # Use the default browser stack

    get "/", LeaderboardPageController, :index
    get "/leaderboard/:leaderboard_id", LeaderboardPageController, :leaderboard
    get "/player/:platform/:player_id", PlayerStatsPageController, :index
    get "/player/lookup", PlayerLookupPageController, :index
    post "/player/lookup", PlayerLookupPageController, :lookup
  end

  scope "/api", RlTools do
    pipe_through :api

    get "/player/:platform/:player_id/values/:leaderboards", PlayerValuesController, :player_values
  end

  # Other scopes may use custom stacks.
  # scope "/api", RlTools do
  #   pipe_through :api
  # end
end
