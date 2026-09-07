defmodule LiveBoard.Boards do
  @moduledoc """
  The Boards context.
  """

  import Ecto.Query, warn: false
  alias LiveBoard.Repo
  alias LiveBoard.Boards.{Board, Column, Card}

  ## Boards

  @doc """
  Lists boards for a given user.
  """
  def list_boards(user_id) do
    from(b in Board,
      where: b.user_id == ^user_id,
      order_by: [desc: b.updated_at],
      preload: [columns: [:cards]]
    )
    |> Repo.all()
  end

  @doc """
  Gets a single board with columns and cards preloaded.
  """
  def get_board!(id, user_id) do
    from(b in Board,
      where: b.id == ^id and b.user_id == ^user_id,
      preload: [columns: ^from(c in Column, order_by: [asc: c.position], preload: [cards: ^from(cd in Card, order_by: [asc: cd.position])])]
    )
    |> Repo.one!()
  end

  @doc """
  Gets a board by id, scoped to user.
  """
  def get_board(id, user_id) do
    Repo.get_by(Board, id: id, user_id: user_id)
  end

  @doc """
  Creates a board with default columns.
  """
  def create_board(attrs, user_id) do
    attrs = Map.put(attrs, "user_id", user_id)

    Repo.transaction(fn ->
      {:ok, board} =
        %Board{}
        |> Board.changeset(attrs)
        |> Repo.insert()

      default_columns = [
        %{title: "To Do", position: 0, board_id: board.id},
        %{title: "Doing", position: 1, board_id: board.id},
        %{title: "Done", position: 2, board_id: board.id}
      ]

      Enum.each(default_columns, fn col_attrs ->
        %Column{}
        |> Column.changeset(col_attrs)
        |> Repo.insert!()
      end)

      get_board!(board.id, user_id)
    end)
  end

  @doc """
  Updates a board.
  """
  def update_board(%Board{} = board, attrs) do
    board
    |> Board.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a board.
  """
  def delete_board(%Board{} = board) do
    Repo.delete(board)
  end

  @doc """
  Changeset for board form.
  """
  def change_board(%Board{} = board, attrs \\ %{}) do
    Board.changeset(board, attrs)
  end

  ## Columns

  @doc """
  Gets a column by id, verifying it belongs to the given board.
  """
  def get_column!(id) do
    Repo.get!(Column, id) |> Repo.preload(:board)
  end

  @doc """
  Creates a column.
  """
  def create_column(attrs) do
    %Column{}
    |> Column.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a column.
  """
  def update_column(%Column{} = column, attrs) do
    column
    |> Column.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a column.
  """
  def delete_column(%Column{} = column) do
    Repo.delete(column)
  end

  ## Cards

  @doc """
  Gets a card by id.
  """
  def get_card!(id) do
    Repo.get!(Card, id) |> Repo.preload(column: :board)
  end

  @doc """
  Creates a card.
  """
  def create_card(attrs) do
    %Card{}
    |> Card.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a card.
  """
  def update_card(%Card{} = card, attrs) do
    card
    |> Card.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a card.
  """
  def delete_card(%Card{} = card) do
    Repo.delete(card)
  end

  @doc """
  Moves a card to a new column and position atomically.
  """
  def move_card(card_id, new_column_id, new_position, user_id) do
    Repo.transaction(fn ->
      card = Repo.get!(Card, card_id) |> Repo.preload(column: :board)

      # Verify ownership via the column's board
      column = Repo.get!(Column, new_column_id) |> Repo.preload(:board)
      if column.board.user_id != user_id do
        Repo.rollback(:unauthorized)
      end

      # Shift positions in the target column
      from(c in Card,
        where: c.column_id == ^new_column_id and c.position >= ^new_position and c.id != ^card.id
      )
      |> Repo.update_all(inc: [position: 1])

      # Shift positions in the old column (if different)
      if card.column_id != new_column_id do
        from(c in Card,
          where: c.column_id == ^card.column_id and c.position > ^card.position
        )
        |> Repo.update_all(inc: [position: -1])
      end

      # Update the card
      card
      |> Card.changeset(%{column_id: new_column_id, position: new_position})
      |> Repo.update!()
    end)
  end

  @doc """
  Gets the next position for a card in a column.
  """
  def next_card_position(column_id) do
    from(c in Card,
      where: c.column_id == ^column_id,
      select: coalesce(max(c.position), -1) + 1
    )
    |> Repo.one()
  end

  @doc """
  Subscribes to PubSub updates for a board.
  """
  def subscribe(board_id) do
    Phoenix.PubSub.subscribe(LiveBoard.PubSub, "board:#{board_id}")
  end

  @doc """
  Broadcasts a board update to all subscribers.
  """
  def broadcast(board_id, event) do
    Phoenix.PubSub.broadcast(LiveBoard.PubSub, "board:#{board_id}", event)
  end
end
