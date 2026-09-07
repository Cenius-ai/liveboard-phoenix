defmodule LiveBoardWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :live_board

  socket "/live", Phoenix.LiveView.Socket

  plug Plug.Static,
    at: "/",
    from: :live_board,
    gzip: false,
    only: LiveBoardWeb.static_paths()

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session,
    store: :cookie,
    key: "_live_board_key",
    signing_salt: "cenius-salt",
    same_site: "Lax"

  plug LiveBoardWeb.Router
end
