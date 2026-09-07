defmodule LiveBoardWeb.BoardLive.Show do
  use Phoenix.LiveView, layout: {LiveBoardWeb.Layouts, :app}

  @doc false
  def init(opts), do: opts

  import LiveBoardWeb.CoreComponents
  alias Phoenix.LiveView.JS
  alias LiveBoard.Boards

  @impl true
  def mount(%{"id" => board_id}, _session, socket) do
    if connected?(socket) do
      Boards.subscribe(board_id)
    end

    user_id = socket.assigns.current_user.id
    board = Boards.get_board!(board_id, user_id)

    {:ok,
     socket
     |> assign(:board, board)
     |> assign(:page_title, board.title)
     |> assign(:show_card_form, nil)
     |> assign(:editing_card, nil)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex items-center justify-between mb-6">
        <div>
          <a href="/dashboard" class="text-xs text-[--muted-foreground] hover:text-[--accent] font-mono transition-colors duration-150">
            ┌ back to dashboard ┐
          </a>
          <h1 class="text-xl font-bold text-[--foreground] mt-1 font-mono">
            &gt; <%= @board.title %>
          </h1>
        </div>
        <button
          phx-click="delete_board"
          phx-confirm="Delete this board and all its cards?"
          class="text-xs text-[--destructive] hover:text-red-400 font-mono transition-colors duration-150"
        >
          ┌ delete board ┐
        </button>
      </div>

      <div id="board-columns" class="flex gap-4 overflow-x-auto pb-4 min-h-[60vh]">
        <%= for column <- @board.columns do %>
          <div
            class="flex-shrink-0 w-72 border border-[--border] bg-[--card]/50 flex flex-col"
            id={"column-#{column.id}"}
            data-column-id={column.id}
          >
            <div class="px-3 py-2 border-b border-[--border] flex items-center justify-between">
              <h3 class="text-xs font-bold text-[--foreground] font-mono">
                │ <%= column.title %>
              </h3>
              <span class="text-[10px] text-[--muted-foreground] font-mono">
                <%= length(column.cards) %>
              </span>
            </div>

            <div
              class="flex-1 p-2 flex flex-col gap-2 min-h-[100px]"
              id={"cards-#{column.id}"}
              data-column-id={column.id}
              phx-hook="SortableCards"
            >
              <%= for card <- column.cards do %>
                <div
                  class="border border-[--border] bg-[--card] p-2 cursor-grab active:cursor-grabbing hover:border-[--accent] transition-colors duration-150 group"
                  id={"card-#{card.id}"}
                  data-card-id={card.id}
                  data-column-id={column.id}
                  draggable="true"
                >
                  <div class="flex items-start justify-between gap-1">
                    <span class="text-xs text-[--foreground] font-mono break-words flex-1 min-w-0">
                      <%= card.title %>
                    </span>
                    <div class="flex gap-0.5 opacity-0 group-hover:opacity-100 transition-opacity duration-150 flex-shrink-0">
                      <button
                        phx-click="edit_card"
                        phx-value-card={card.id}
                        class="text-[10px] text-[--muted-foreground] hover:text-[--accent] font-mono leading-none p-0.5"
                        aria-label="Edit card"
                      >
                        ✎
                      </button>
                      <button
                        phx-click="delete_card"
                        phx-value-card={card.id}
                        phx-confirm="Delete this card?"
                        class="text-[10px] text-[--muted-foreground] hover:text-[--destructive] font-mono leading-none p-0.5"
                        aria-label="Delete card"
                      >
                        ✕
                      </button>
                    </div>
                  </div>
                  <%= if card.label_color do %>
                    <div class="mt-1 h-1 w-8 rounded-full"
                         style={"background-color: var(--label-#{card.label_color})"}>
                    </div>
                  <% end %>
                </div>
              <% end %>
            </div>

            <div class="px-2 py-2 border-t border-[--border]">
              <%= if @show_card_form == column.id do %>
                <form phx-submit="create_card" class="flex flex-col gap-2">
                  <input type="hidden" name="column" value={column.id} />
                  <input
                    type="text"
                    name="card[title]"
                    placeholder="Card title..."
                    required
                    class="bg-[--background] border border-[--border] text-xs font-mono px-2 py-1.5 focus:outline-none focus:ring-1 focus:ring-[--ring] placeholder:text-[--muted-foreground]/50 text-[--foreground]"
                    autofocus
                  />
                  <div class="flex gap-1">
                    <button type="submit" class="text-[10px] bg-[--primary] text-[--on-primary] px-2 py-1 font-mono hover:brightness-110 transition-all duration-150">
                      ┌ add ┐
                    </button>
                    <button type="button" phx-click="cancel_card" class="text-[10px] text-[--muted-foreground] hover:text-[--foreground] px-2 py-1 font-mono transition-colors duration-150">
                      ┌ x ┐
                    </button>
                  </div>
                </form>
              <% else %>
                <button
                  phx-click="show_card_form"
                  phx-value-column={column.id}
                  class="w-full text-[10px] text-[--muted-foreground] hover:text-[--accent] font-mono py-1 transition-colors duration-150 text-left"
                >
                  ┌ + add card ┐
                </button>
              <% end %>
            </div>
          </div>
        <% end %>
      </div>

      <%= if @editing_card do %>
        <.modal id="edit-card-modal" show={true} on_cancel={JS.push("cancel_edit")}>
          <h3 class="text-sm font-bold text-[--accent] mb-4 font-mono">
            ┌ edit card ┐
          </h3>
          <form phx-submit="update_card" class="flex flex-col gap-4">
            <input type="hidden" name="card_id" value={@editing_card.id} />
            <div class="flex flex-col gap-1">
              <label class="text-xs text-[--muted-foreground] font-mono">&gt; title</label>
              <input
                type="text"
                name="card[title]"
                value={@editing_card.title}
                required
                class="bg-[--background] border border-[--border] text-xs font-mono px-3 py-2 focus:outline-none focus:ring-2 focus:ring-[--ring] text-[--foreground]"
              />
            </div>
            <div class="flex gap-2">
              <button type="submit" class="inline-flex items-center justify-center font-mono text-xs bg-[--primary] text-[--on-primary] border border-[--primary] px-3 py-1.5 hover:brightness-110 transition-all duration-150">
                ┌ save ┐
              </button>
              <button type="button" phx-click="cancel_edit" class="text-xs text-[--muted-foreground] hover:text-[--foreground] font-mono transition-colors duration-150">
                ┌ cancel ┐
              </button>
            </div>
          </form>
        </.modal>
      <% end %>
    </div>
    """
  end

  @impl true
  def handle_event("show_card_form", %{"column" => column_id}, socket) do
    {:noreply, assign(socket, :show_card_form, String.to_integer(column_id))}
  end

  def handle_event("cancel_card", _params, socket) do
    {:noreply, assign(socket, :show_card_form, nil)}
  end

  def handle_event("create_card", %{"card" => card_params, "column" => column_id}, socket) do
    col_id = String.to_integer(column_id)
    position = Boards.next_card_position(col_id)

    attrs = Map.put(card_params, "position", position)
    attrs = Map.put(attrs, "column_id", col_id)

    case Boards.create_card(attrs) do
      {:ok, _card} ->
        board = Boards.get_board!(socket.assigns.board.id, socket.assigns.current_user.id)
        Boards.broadcast(board.id, {:card_created, board})

        {:noreply,
         socket
         |> assign(:board, board)
         |> assign(:show_card_form, nil)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to create card")}
    end
  end

  def handle_event("edit_card", %{"card" => card_id}, socket) do
    card = Enum.find(
      Enum.flat_map(socket.assigns.board.columns, & &1.cards),
      &(&1.id == String.to_integer(card_id))
    )
    {:noreply, assign(socket, :editing_card, card)}
  end

  def handle_event("cancel_edit", _params, socket) do
    {:noreply, assign(socket, :editing_card, nil)}
  end

  def handle_event("update_card", %{"card" => card_params, "card_id" => card_id}, socket) do
    card = Enum.find(
      Enum.flat_map(socket.assigns.board.columns, & &1.cards),
      &(&1.id == String.to_integer(card_id))
    )

    case Boards.update_card(card, card_params) do
      {:ok, _updated} ->
        board = Boards.get_board!(socket.assigns.board.id, socket.assigns.current_user.id)
        Boards.broadcast(board.id, {:card_updated, board})

        {:noreply,
         socket
         |> assign(:board, board)
         |> assign(:editing_card, nil)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update card")}
    end
  end

  def handle_event("delete_card", %{"card" => card_id}, socket) do
    card = Enum.find(
      Enum.flat_map(socket.assigns.board.columns, & &1.cards),
      &(&1.id == String.to_integer(card_id))
    )

    Boards.delete_card(card)

    board = Boards.get_board!(socket.assigns.board.id, socket.assigns.current_user.id)
    Boards.broadcast(board.id, {:card_deleted, board})

    {:noreply, assign(socket, :board, board)}
  end

  def handle_event("delete_board", _params, socket) do
    board = socket.assigns.board
    Boards.delete_board(board)

    {:noreply,
     socket
     |> put_flash(:info, "Board deleted")
     |> redirect(to: "/dashboard")}
  end

  def handle_event("move_card", %{"card_id" => card_id, "column_id" => column_id, "position" => position}, socket) do
    result = Boards.move_card(
      String.to_integer(card_id),
      String.to_integer(column_id),
      String.to_integer(position),
      socket.assigns.current_user.id
    )

    case result do
      {:ok, _card} ->
        board = Boards.get_board!(socket.assigns.board.id, socket.assigns.current_user.id)
        Boards.broadcast(board.id, {:card_moved, board})
        {:noreply, assign(socket, :board, board)}

      {:error, :unauthorized} ->
        {:noreply, put_flash(socket, :error, "Unauthorized")}

      _ ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:card_created, board}, socket) do
    {:noreply, assign(socket, :board, board)}
  end

  def handle_info({:card_updated, board}, socket) do
    {:noreply, assign(socket, :board, board)}
  end

  def handle_info({:card_deleted, board}, socket) do
    {:noreply, assign(socket, :board, board)}
  end

  def handle_info({:card_moved, board}, socket) do
    {:noreply, assign(socket, :board, board)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end
end
