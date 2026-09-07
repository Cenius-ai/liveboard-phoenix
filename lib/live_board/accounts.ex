defmodule LiveBoard.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias LiveBoard.Repo
  alias LiveBoard.Accounts.{User, UserToken}

  ## User registration

  @doc """
  Registers a new user.
  """
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.
  """
  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs)
  end

  ## Session

  @doc """
  Gets the user by email.
  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: String.downcase(email))
  end

  @doc """
  Gets the user by email and password.
  """
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: String.downcase(email))
    if user && User.valid_password?(user, password), do: user
  end

  @doc """
  Generates a session token for the user.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user by session token.
  """
  def get_user_by_session_token(token) when is_binary(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the session token.
  """
  def delete_user_session_token(token) when is_binary(token) do
    hashed = :crypto.hash(:sha256, token)
    Repo.delete_all(from t in UserToken, where: t.token == ^hashed and t.context == "session")
    :ok
  end

  ## User update

  @doc """
  Gets a user by id.
  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Updates the user email.
  """
  def update_user_email(%User{} = user, attrs) do
    user
    |> User.email_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates the user password.
  """
  def update_user_password(%User{} = user, password, current_password) do
    changeset =
      user
      |> User.password_changeset(%{password: password, current_password: current_password})

    Repo.update(changeset)
  end

  @doc """
  Updates the user profile (username).
  """
  def update_user_profile(%User{} = user, attrs) do
    user
    |> Ecto.Changeset.cast(attrs, [:username])
    |> then(&validate_username_for_profile(&1))
    |> Repo.update()
  end

  defp validate_username_for_profile(changeset) do
    changeset
    |> Ecto.Changeset.validate_required([:username])
    |> Ecto.Changeset.validate_format(:username, ~r/^[A-Za-z0-9_-]{3,30}$/,
      message: "must be 3-30 characters: letters, numbers, hyphens, underscores"
    )
    |> Ecto.Changeset.validate_length(:username, min: 3, max: 30)
    |> Ecto.Changeset.unsafe_validate_unique(:username, LiveBoard.Repo)
    |> Ecto.Changeset.unique_constraint(:username)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.
  """
  def change_user_email(user, attrs \\ %{}) do
    User.email_changeset(user, attrs)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user password.
  """
  def change_user_password(user, attrs \\ %{}) do
    User.password_changeset(user, attrs)
  end
end
