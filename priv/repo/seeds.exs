alias LiveBoard.Repo
alias LiveBoard.Accounts.User
alias LiveBoard.Boards.{Board, Column, Card}

# ─────────────────────────────────────
# Idempotent seed: check before insert
# ─────────────────────────────────────

demo_email = "cenius@cenius.ai"
demo_username = "cenius"
demo_password = "cenius"

{:ok, demo_user} =
  case Repo.get_by(User, email: demo_email) do
    nil ->
      %User{}
      |> User.registration_changeset(%{
        email: demo_email,
        username: demo_username,
        password: demo_password
      })
      |> Repo.insert!()
      |> then(&{:ok, &1})

    existing ->
      # Ensure password is correct on re-run
      if !User.valid_password?(existing, demo_password) do
        existing
        |> Ecto.Changeset.change(hashed_password: Bcrypt.hash_pwd_salt(demo_password))
        |> Repo.update!()
      end

      {:ok, existing}
  end

# Seed a second user for multi-tenant demo
second_email = "alice@example.com"
{:ok, _second_user} =
  case Repo.get_by(User, email: second_email) do
    nil ->
      %User{}
      |> User.registration_changeset(%{
        email: second_email,
        username: "alice_dev",
        password: "alice123"
      })
      |> Repo.insert!()
      |> then(&{:ok, &1})

    existing ->
      {:ok, existing}
  end

# ─────────────────────────────────────
# Seed boards for demo user
# ─────────────────────────────────────

board_title = "LiveBoard Launch 🚀"

demo_board =
  case Repo.get_by(Board, title: board_title, user_id: demo_user.id) do
    nil ->
      {:ok, board} =
        %Board{}
        |> Board.changeset(%{title: board_title, description: "Product launch plan for LiveBoard MVP", user_id: demo_user.id})
        |> Repo.insert()

      # Create columns
      cols_data = [
        %{title: "To Do", position: 0, board_id: board.id},
        %{title: "Doing", position: 1, board_id: board.id},
        %{title: "Done", position: 2, board_id: board.id}
      ]

      cols =
        Enum.map(cols_data, fn col_attrs ->
          %Column{}
          |> Column.changeset(col_attrs)
          |> Repo.insert!()
        end)

      [todo, doing, done] = cols

      # Cards for To Do
      todo_cards = [
        %{title: "Set up CI/CD pipeline", description: "Configure GitHub Actions for automated testing and deployment", position: 0, column_id: todo.id, label_color: "blue"},
        %{title: "Write user documentation", description: "Create comprehensive docs for end users and contributors", position: 1, column_id: todo.id, label_color: "purple"},
        %{title: "Design landing page", description: "Figma mockups for the marketing landing page", position: 2, column_id: todo.id, label_color: "yellow"},
        %{title: "Implement card labels", description: "Add color-coded labels to cards for better organization", position: 3, column_id: todo.id, label_color: "orange"},
      ]

      Enum.each(todo_cards, fn attrs ->
        %Card{} |> Card.changeset(attrs) |> Repo.insert!()
      end)

      # Cards for Doing
      doing_cards = [
        %{title: "Build drag-and-drop", description: "SortableJS integration with LiveView hooks for card reordering", position: 0, column_id: doing.id, label_color: "green"},
        %{title: "Real-time sync via PubSub", description: "Broadcast card changes to all connected viewers per board", position: 1, column_id: doing.id, label_color: "blue"},
        %{title: "User authentication flow", description: "Registration, login, logout with bcrypt and session tokens", position: 2, column_id: doing.id, label_color: "red"},
      ]

      Enum.each(doing_cards, fn attrs ->
        %Card{} |> Card.changeset(attrs) |> Repo.insert!()
      end)

      # Cards for Done
      done_cards = [
        %{title: "Project scaffold", description: "Phoenix project with Ecto SQLite3 setup and migrations", position: 0, column_id: done.id, label_color: "green"},
        %{title: "Database schema design", description: "Users, boards, columns, cards with proper associations", position: 1, column_id: done.id, label_color: "green"},
        %{title: "Terminal-mono dark theme", description: "Custom CSS with monospace fonts, box-drawing chars, and cyberpunk palette", position: 2, column_id: done.id, label_color: "purple"},
      ]

      Enum.each(done_cards, fn attrs ->
        %Card{} |> Card.changeset(attrs) |> Repo.insert!()
      end)

      board

    existing ->
      existing
  end

# Seed second board for variety
second_board_title = "Personal Tasks"

_second_board =
  case Repo.get_by(Board, title: second_board_title, user_id: demo_user.id) do
    nil ->
      {:ok, board} =
        %Board{}
        |> Board.changeset(%{title: second_board_title, description: "Personal task tracking", user_id: demo_user.id})
        |> Repo.insert()

      cols_data = [
        %{title: "Backlog", position: 0, board_id: board.id},
        %{title: "This Week", position: 1, board_id: board.id},
        %{title: "Today", position: 2, board_id: board.id},
        %{title: "Completed", position: 3, board_id: board.id}
      ]

      [backlog, this_week, today, completed] =
        Enum.map(cols_data, fn col_attrs ->
          %Column{}
          |> Column.changeset(col_attrs)
          |> Repo.insert!()
        end)

      # Backlog cards
      [
        %{title: "Read 'Designing Data-Intensive Applications'", position: 0, column_id: backlog.id, label_color: "blue"},
        %{title: "Organize bookmarks", position: 1, column_id: backlog.id, label_color: "yellow"},
        %{title: "Renew SSL certificates", position: 2, column_id: backlog.id},
      ] |> Enum.each(fn a -> %Card{} |> Card.changeset(a) |> Repo.insert!() end)

      # This Week cards
      [
        %{title: "Grocery shopping", position: 0, column_id: this_week.id, label_color: "green"},
        %{title: "Fix kitchen sink leak", position: 1, column_id: this_week.id, label_color: "red"},
      ] |> Enum.each(fn a -> %Card{} |> Card.changeset(a) |> Repo.insert!() end)

      # Today cards
      [
        %{title: "Write blog post on LiveView", position: 0, column_id: today.id, label_color: "orange"},
        %{title: "Call dentist for appointment", position: 1, column_id: today.id},
      ] |> Enum.each(fn a -> %Card{} |> Card.changeset(a) |> Repo.insert!() end)

      # Completed
      [
        %{title: "Pay electricity bill", position: 0, column_id: completed.id, label_color: "green"},
        %{title: "Update resume", position: 1, column_id: completed.id, label_color: "purple"},
        %{title: "Backup photos to external drive", position: 2, column_id: completed.id},
      ] |> Enum.each(fn a -> %Card{} |> Card.changeset(a) |> Repo.insert!() end)

      board

    existing ->
      existing
  end

IO.puts("✅ Seeds complete — demo user: #{demo_email} / #{demo_password}")
