defmodule LiveBoard.Boards.Board do
  use Ecto.Schema
  import Ecto.Changeset

  schema "boards" do
    field :title, :string
    field :description, :string
    belongs_to :user, LiveBoard.Accounts.User
    has_many :columns, LiveBoard.Boards.Column, preload_order: [asc: :position]

    timestamps(type: :utc_datetime)
  end

  def changeset(board, attrs) do
    board
    |> cast(attrs, [:title, :description, :user_id])
    |> validate_required([:title])
    |> validate_length(:title, min: 1, max: 100)
    |> foreign_key_constraint(:user_id)
  end
end
