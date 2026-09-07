import Config

if config_env() == :prod do
  db_path =
    System.get_env("DATABASE_PATH", "priv/repo/live_board_prod.db")
    |> then(fn p ->
      if String.starts_with?(p, "/"), do: p, else: Path.join(System.get_env("RELEASE_ROOT", File.cwd!()), p)
    end)

  config :live_board, LiveBoard.Repo,
    adapter: Ecto.Adapters.SQLite3,
    database: db_path,
    pool_size: String.to_integer(System.get_env("POOL_SIZE", "5"))

  if db_url = System.get_env("DATABASE_URL") do
    config :live_board, LiveBoard.Repo, url: db_url
  end

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise "SECRET_KEY_BASE is required in production. Generate with: mix phx.gen.secret"

  port = String.to_integer(System.get_env("PORT", "4000"))

  config :live_board, LiveBoardWeb.Endpoint,
    http: [ip: {0, 0, 0, 0}, port: port],
    check_origin: false,
    secret_key_base: secret_key_base,
    server: true
end
