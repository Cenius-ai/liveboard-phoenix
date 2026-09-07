defmodule LiveBoardWeb.UserRegistrationController do
  use LiveBoardWeb, :controller

  alias LiveBoard.Accounts
  alias LiveBoardWeb.UserAuth

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        UserAuth.log_in_user(conn, user)

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Registration failed. Please check the form for errors.")
        |> put_session(:registration_changeset_errors, changeset_errors(changeset))
        |> redirect(to: "/register")
    end
  end

  defp changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
