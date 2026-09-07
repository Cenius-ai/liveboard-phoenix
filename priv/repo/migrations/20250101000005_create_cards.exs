defmodule LiveBoard.Repo.Migrations.CreateCards do
  use Ecto.Migration

  def change do
    create table(:cards) do
      add :title, :string, null: false
      add :description, :text
      add :position, :integer, null: false, default: 0
      add :due_date, :utc_datetime
      add :label_color, :string
      add :column_id, references(:columns, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:cards, [:column_id])
  end
end
