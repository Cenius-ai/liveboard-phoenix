defmodule LiveBoard.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :username, :string
    field :hashed_password, :string
    field :confirmed_at, :utc_datetime
    field :current_password, :string, virtual: true
    field :password, :string, virtual: true

    has_many :boards, LiveBoard.Boards.Board
    has_many :tokens, LiveBoard.Accounts.UserToken

    timestamps(type: :utc_datetime)
  end

  @doc """
  A user changeset for registration.
  """
  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :username, :password])
    |> validate_email()
    |> validate_username()
    |> validate_password()
    |> put_password_hash()
  end

  @doc """
  A user changeset for changing the email.
  """
  def email_changeset(user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_email()
  end

  @doc """
  A user changeset for changing the password.
  """
  def password_changeset(user, attrs) do
    user
    |> cast(attrs, [:password, :current_password])
    |> validate_password()
    |> put_password_hash()
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must be a valid email address")
    |> validate_length(:email, max: 160)
    |> unsafe_validate_unique(:email, LiveBoard.Repo)
    |> unique_constraint(:email)
  end

  defp validate_username(changeset) do
    changeset
    |> validate_required([:username])
    |> validate_format(:username, ~r/^[A-Za-z0-9_-]{3,30}$/,
      message: "must be 3-30 characters: letters, numbers, hyphens, underscores"
    )
    |> validate_length(:username, min: 3, max: 30)
    |> unsafe_validate_unique(:username, LiveBoard.Repo)
    |> unique_constraint(:username)
  end

  defp validate_password(changeset) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 6, max: 80)
  end

  defp put_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, hashed_password: Bcrypt.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset

  @doc """
  Verifies the password.
  """
  def valid_password?(%LiveBoard.Accounts.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _), do: false

  @doc """
  Validates the current password otherwise adds an error.
  """
  def validate_current_password(changeset, password) do
    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end
end
