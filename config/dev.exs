import Config

db_path = System.get_env("DATABASE_PATH", "priv/repo/live_board_dev.db")

config :live_board, LiveBoard.Repo,
  adapter: Ecto.Adapters.SQLite3,
  database: db_path,
  pool_size: 5

if db_url = System.get_env("DATABASE_URL") do
  config :live_board, LiveBoard.Repo, url: db_url
end

config :live_board, LiveBoardWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: String.to_integer(System.get_env("PORT", "4000"))],
  check_origin: false,
  debug_errors: true,
  secret_key_base: System.get_env("SECRET_KEY_BASE", "cenius-dev-key-a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6a1b2c3d4e5f6a7b8c9d0e1f2"),
  server: true

config :live_board, :dev_routes, true
config :logger, :console, format: "[$level] $message\n"
config :phoenix, :stacktrace_depth, 20
