defmodule LiveBoardWeb.DashboardLive do
  use Phoenix.LiveView, layout: {LiveBoardWeb.Layouts, :app}

  @doc false
  def init(opts), do: opts

  alias LiveBoard.Boards
  alias LiveBoard.Boards.Board

  @impl true
  def mount(_params, _session, socket) do
    boards = Boards.list_boards(socket.assigns.current_user.id)
    {:ok,
     socket
     |> assign(:boards, boards)
     |> assign(:show_new_form, false)
     |> assign(:new_board_changeset, Boards.change_board(%Board{}))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex items-center justify-between mb-6">
        <div>
          <h1 class="text-xl font-bold text-[--foreground] font-mono">
            &gt; dashboard
          </h1>
          <p class="text-xs text-[--muted-foreground] mt-1 font-mono">
            ┌ <%= length(@boards) %> board<%= if length(@boards) != 1, do: "s" %> total ┐
          </p>
        </div>
        <button
          phx-click="toggle_new"
          class="text-xs font-mono text-[--accent] hover:text-[--foreground] border border-[--border] bg-[--secondary] px-3 py-1.5 transition-colors duration-150"
        >
          ┌ + new board ┐
        </button>
      </div>

      <%= if @show_new_form do %>
        <div class="border border-[--border] bg-[--card] p-4 mb-6">
          <h2 class="text-sm font-bold text-[--accent] mb-3 font-mono">
            ┌ new board ┐
          </h2>
          <form phx-submit="create_board" class="flex flex-col gap-4">
            <div class="flex flex-col gap-1">
              <label class="text-xs text-[--muted-foreground] font-mono">&gt; title</label>
              <input
                type="text"
                name="board[title]"
                placeholder="My Project"
                required
                class="bg-[--background] border border-[--border] text-xs font-mono px-3 py-2 focus:outline-none focus:ring-1 focus:ring-[--ring] text-[--foreground] placeholder:text-[--muted-foreground]/50"
              />
            </div>
            <div class="flex gap-2">
              <button type="submit" class="inline-flex items-center justify-center font-mono text-xs bg-[--primary] text-[--on-primary] border border-[--primary] px-3 py-1.5 hover:brightness-110 transition-all duration-150">
                ┌ create ┐
              </button>
              <button type="button" phx-click="cancel_new" class="text-xs text-[--muted-foreground] hover:text-[--foreground] font-mono transition-colors duration-150">
                ┌ cancel ┐
              </button>
            </div>
          </form>
        </div>
      <% end %>

      <%= if @boards == [] do %>
        <div class="border border-dashed border-[--border] p-12 text-center">
          <p class="text-[--muted-foreground] text-sm font-mono mb-3">
            ┌ no boards yet ┐
          </p>
          <p class="text-[--muted-foreground] text-xs font-mono">
            create your first board to get started
          </p>
        </div>
      <% else %>
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          <%= for board <- @boards do %>
            <a
              href={"/boards/#{board.id}"}
              class="border border-[--border] bg-[--card] p-4 hover:border-[--accent] transition-colors duration-150 block no-underline group"
            >
              <h3 class="text-sm font-bold text-[--foreground] group-hover:text-[--accent] transition-colors duration-150 font-mono">
                &gt; <%= board.title %>
              </h3>
              <div class="mt-2 flex items-center gap-2 text-[10px] text-[--muted-foreground] font-mono">
                <span><%= length(board.columns) %> columns</span>
                <span class="text-[--border]">│</span>
                <% total_cards = Enum.reduce(board.columns, 0, fn col, acc -> acc + length(col.cards) end) %>
                <span><%= total_cards %> cards</span>
              </div>
              <div class="mt-3 flex gap-2">
                <%= for col <- Enum.take(board.columns, 3) do %>
                  <span class="text-[9px] px-1.5 py-0.5 border border-[--border] text-[--muted-foreground] font-mono">
                    <%= col.title %>:<%= length(col.cards) %>
                  </span>
                <% end %>
              </div>
            </a>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  @impl true
  def handle_event("toggle_new", _params, socket) do
    {:noreply, assign(socket, :show_new_form, !socket.assigns.show_new_form)}
  end

  def handle_event("cancel_new", _params, socket) do
    {:noreply, assign(socket, :show_new_form, false)}
  end

  def handle_event("create_board", %{"board" => board_params}, socket) do
    user_id = socket.assigns.current_user.id

    case Boards.create_board(board_params, user_id) do
      {:ok, _board_with_cols} ->
        boards = Boards.list_boards(user_id)
        {:noreply,
         socket
         |> assign(:boards, boards)
         |> assign(:show_new_form, false)
         |> put_flash(:info, "Board created!")}

      {:error, changeset} ->
        {:noreply, assign(socket, :new_board_changeset, changeset)}
    end
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end
end
