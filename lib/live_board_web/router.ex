defmodule LiveBoardWeb.Router do
  use LiveBoardWeb, :router

  import LiveBoardWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {LiveBoardWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Public live session
  live_session :public,
    on_mount: [{LiveBoardWeb.UserAuth, :default}],
    session: {LiveBoardWeb.UserAuth, :live_session, []} do
    scope "/", LiveBoardWeb do
      pipe_through :browser

      get "/", PageController, :index
      live "/login", UserSessionLive, :new
      live "/register", UserRegistrationLive, :new
    end
  end

  # Authenticated live session
  live_session :authenticated,
    on_mount: [{LiveBoardWeb.UserAuth, :default}],
    session: {LiveBoardWeb.UserAuth, :live_session, []} do
    scope "/", LiveBoardWeb do
      pipe_through [:browser, :require_authenticated_user]

      live "/dashboard", DashboardLive, :index
      live "/boards/:id", BoardLive.Show, :show
      live "/settings", UserSettingsLive, :edit
    end
  end

  # Non-live routes
  scope "/", LiveBoardWeb do
    pipe_through :browser

    post "/users/log_in", UserSessionController, :create
    post "/users/register", UserRegistrationController, :create
  end

  scope "/", LiveBoardWeb do
    pipe_through [:browser, :require_authenticated_user]

    delete "/users/log_out", UserSessionController, :delete
  end
end
