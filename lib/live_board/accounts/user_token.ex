defmodule LiveBoard.Accounts.UserToken do
  use Ecto.Schema
  import Ecto.Query

  @session_validity_days 60
  @hash_algorithm :sha256

  schema "users_tokens" do
    field :token, :binary
    field :context, :string
    field :sent_to, :string
    belongs_to :user, LiveBoard.Accounts.User

    timestamps(updated_at: false, type: :utc_datetime)
  end

  @doc """
  Generates a token for the user session.
  """
  def build_session_token(user) do
    token = :crypto.strong_rand_bytes(32)
    {token, %LiveBoard.Accounts.UserToken{token: hash_token(token), context: "session", user_id: user.id}}
  end

  @doc """
  Checks if the token is valid and returns the underlying lookup query.
  """
  def verify_session_token_query(token) do
    query =
      from token in token_and_context_query(token, "session"),
        join: user in assoc(token, :user),
        where: token.inserted_at > ago(@session_validity_days, "day"),
        select: user

    {:ok, query}
  end

  defp hash_token(token) do
    :crypto.hash(@hash_algorithm, token)
  end

  defp token_and_context_query(token, context) do
    hashed = hash_token(token)
    from t in LiveBoard.Accounts.UserToken, where: t.token == ^hashed and t.context == ^context
  end

  @doc """
  Gets all tokens for a user.
  """
  def user_and_contexts_query(user, contexts) do
    from t in LiveBoard.Accounts.UserToken,
      where: t.user_id == ^user.id and t.context in ^contexts
  end
end
