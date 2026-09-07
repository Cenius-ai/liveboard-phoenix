defmodule LiveBoard.Boards.Card do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cards" do
    field :title, :string
    field :description, :string
    field :position, :integer, default: 0
    field :due_date, :utc_datetime
    field :label_color, :string
    belongs_to :column, LiveBoard.Boards.Column

    timestamps(type: :utc_datetime)
  end

  def changeset(card, attrs) do
    card
    |> cast(attrs, [:title, :description, :position, :due_date, :label_color, :column_id])
    |> validate_required([:title])
    |> validate_length(:title, min: 1, max: 200)
    |> validate_inclusion(:label_color, ~w(blue green red yellow purple orange), message: "must be a valid color")
    |> foreign_key_constraint(:column_id)
  end
end
