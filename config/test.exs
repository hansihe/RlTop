use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :rl_tools, RlTools.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :rl_tools, RlTools.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "rl_tools_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
