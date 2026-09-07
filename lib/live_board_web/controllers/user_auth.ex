defmodule LiveBoardWeb.UserAuth do
  import Plug.Conn
  import Phoenix.Controller

  alias LiveBoard.Accounts

  @remember_me_cookie "_live_board_user_remember_me"
  @remember_me_max_age 60 * 60 * 24 * 60

  @doc """
  Returns the session map for LiveView live_session.
  """
  def live_session(conn) do
    %{"user_token" => get_session(conn, :user_token)}
  end

  @doc """
  Fetches the current user from the session or remember-me cookie.
  """
  def fetch_current_user(conn, _opts) do
    conn = fetch_cookies(conn, signed: [@remember_me_cookie])

    token = get_session(conn, :user_token) || conn.cookies[@remember_me_cookie]

    user =
      if token do
        Accounts.get_user_by_session_token(token)
      end

    conn
    |> assign(:current_user, user)
    |> assign(:user_token, token)
  end

  @doc """
  Requires an authenticated user. Redirects to login if not authenticated.
  """
  def require_authenticated_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "You must log in to access this page.")
      |> redirect(to: "/login")
      |> halt()
    end
  end

  @doc """
  Logs the user in by setting the session and remember-me cookie.
  """
  def log_in_user(conn, user, params \\ %{}) do
    token = Accounts.generate_user_session_token(user)
    user_return_to = get_session(conn, :user_return_to)

    conn
    |> renew_session()
    |> put_session(:user_token, token)
    |> maybe_write_remember_me_cookie(token, params)
    |> redirect(to: user_return_to || "/dashboard")
  end

  defp maybe_write_remember_me_cookie(conn, token, %{"remember_me" => "true"}) do
    put_resp_cookie(conn, @remember_me_cookie, token,
      max_age: @remember_me_max_age,
      http_only: true,
      secure: false,
      same_site: "Lax"
    )
  end

  defp maybe_write_remember_me_cookie(conn, _token, _params), do: conn

  @doc """
  Logs the user out.
  """
  def log_out_user(conn) do
    token = get_session(conn, :user_token)
    if token, do: Accounts.delete_user_session_token(token)

    conn
    |> renew_session()
    |> delete_resp_cookie(@remember_me_cookie)
    |> redirect(to: "/login")
  end

  @doc """
  Refreshes the session.
  """
  def renew_session(conn) do
    conn
    |> configure_session(drop: true)
    |> clear_session()
    |> configure_session(renew: true)
  end

  @doc """
  on_mount hook for LiveViews. Assigns the current_user from the session.
  """
  def on_mount(:default, _params, session, socket) do
    token = session["user_token"]

    user =
      if token do
        Accounts.get_user_by_session_token(token)
      end

    socket =
      if user do
        Phoenix.Component.assign(socket, :current_user, user)
      else
        Phoenix.Component.assign(socket, :current_user, nil)
      end

    {:cont, socket}
  end
end
