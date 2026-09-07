import Config

config :live_board,
  ecto_repos: [LiveBoard.Repo]

config :live_board, LiveBoard.Repo,
  migration_timestamps: [type: :utc_datetime]

config :live_board,
  generators: [timestamp_type: :utc_datetime]

config :live_board, LiveBoardWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: LiveBoardWeb.ErrorHTML, json: LiveBoardWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: LiveBoard.PubSub,
  live_view: [signing_salt: "cenius-live-salt"]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
