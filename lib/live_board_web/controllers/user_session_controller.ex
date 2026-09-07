defmodule LiveBoardWeb.UserSessionController do
  use LiveBoardWeb, :controller

  alias LiveBoard.Accounts
  alias LiveBoardWeb.UserAuth

  def create(conn, %{"user" => %{"email" => email, "password" => password} = params}) do
    if user = Accounts.get_user_by_email_and_password(email, password) do
      UserAuth.log_in_user(conn, user, params)
    else
      conn
      |> put_flash(:error, "Invalid email or password")
      |> redirect(to: "/login")
    end
  end

  def delete(conn, _params) do
    UserAuth.log_out_user(conn)
  end
end
