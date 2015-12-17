# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :rl_tools, RlTools.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "bGKYxlTACnr7IlUYca/xjlG4sNDxNd/ExDQVqj+SOwX3Bq6zr/ZHqXGzJzhmDYit",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: RlTools.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

config :rl_tools, :rl_api,
  loginSecret: "dUe3SE4YsR8B0c30E6r7F2KqpZSbGiVx",
  callProcKey: "pX9pn8F4JnBpoO8Aa219QC6N7g18FJ0F"

config :quantum, cron: [
  "*/15 * * * *": {"RlTools.Fetcher.Scheduler", :cron_run_fetch}, #&RlTools.Fetcher.Scheduler.cron_run_fetch/0
  "*/2 * * * *": {"RlTools.Fetcher.Scheduler", :cron_keep_session_alive}
]
