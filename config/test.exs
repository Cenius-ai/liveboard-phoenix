import Config

config :live_board, LiveBoard.Repo,
  adapter: Ecto.Adapters.SQLite3,
  database: "priv/repo/live_board_test.db",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 2

config :live_board, LiveBoardWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4001],
  secret_key_base: "test-secret-key-base-for-testing-only-not-real-a1b2c3d4e5f6",
  server: false

config :logger, level: :warning
