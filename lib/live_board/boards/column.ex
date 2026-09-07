defmodule LiveBoard.Boards.Column do
  use Ecto.Schema
  import Ecto.Changeset

  schema "columns" do
    field :title, :string
    field :position, :integer, default: 0
    belongs_to :board, LiveBoard.Boards.Board
    has_many :cards, LiveBoard.Boards.Card, preload_order: [asc: :position]

    timestamps(type: :utc_datetime)
  end

  def changeset(column, attrs) do
    column
    |> cast(attrs, [:title, :position, :board_id])
    |> validate_required([:title, :position])
    |> validate_length(:title, min: 1, max: 50)
    |> foreign_key_constraint(:board_id)
  end
end
