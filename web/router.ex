defmodule RlTools.Router do
  use RlTools.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", RlTools do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/player/:platform/:player_id", PlayerStatsPageController, :index
    get "/leaderboard", LeaderboardPageController, :index
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
