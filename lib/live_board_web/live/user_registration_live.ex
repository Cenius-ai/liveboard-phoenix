defmodule LiveBoardWeb.UserRegistrationLive do
  use Phoenix.LiveView, layout: {LiveBoardWeb.Layouts, :app}

  @doc false
  def init(opts), do: opts

  alias LiveBoard.Accounts

  @impl true
  def mount(_params, _session, socket) do
    if socket.assigns.current_user do
      {:ok, redirect(socket, to: "/dashboard")}
    else
      {:ok, assign(socket, :changeset, Accounts.change_user_registration(%Accounts.User{}))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-md mx-auto mt-16 px-4">
      <div class="border border-[--border] bg-[--card] p-6">
        <h1 class="text-lg font-bold text-[--accent] mb-1 font-mono">
          &gt; register
        </h1>
        <p class="text-[--muted-foreground] text-xs mb-6 font-mono">
          ┌ create a new account ┐
        </p>

        <form action={"/users/register"} method="post" class="flex flex-col gap-4">
          <input type="hidden" name="_csrf_token" value={Plug.CSRFProtection.get_csrf_token()} />
          <div class="flex flex-col gap-1">
            <label for="user_username" class="text-xs text-[--muted-foreground] font-mono">&gt; username</label>
            <input
              type="text"
              name="user[username]"
              id="user_username"
              placeholder="your_handle"
              required
              autocomplete="username"
              class="bg-[--background] border border-[--border] text-xs font-mono px-3 py-2 focus:outline-none focus:ring-2 focus:ring-[--ring] text-[--foreground] placeholder:text-[--muted-foreground]/50"
            />
          </div>
          <div class="flex flex-col gap-1">
            <label for="user_email" class="text-xs text-[--muted-foreground] font-mono">&gt; email</label>
            <input
              type="email"
              name="user[email]"
              id="user_email"
              placeholder="you@example.com"
              required
              autocomplete="email"
              class="bg-[--background] border border-[--border] text-xs font-mono px-3 py-2 focus:outline-none focus:ring-2 focus:ring-[--ring] text-[--foreground] placeholder:text-[--muted-foreground]/50"
            />
          </div>
          <div class="flex flex-col gap-1">
            <label for="user_password" class="text-xs text-[--muted-foreground] font-mono">&gt; password</label>
            <input
              type="password"
              name="user[password]"
              id="user_password"
              placeholder="········"
              required
              autocomplete="new-password"
              class="bg-[--background] border border-[--border] text-xs font-mono px-3 py-2 focus:outline-none focus:ring-2 focus:ring-[--ring] text-[--foreground] placeholder:text-[--muted-foreground]/50"
            />
          </div>
          <button type="submit" class="inline-flex items-center justify-center font-mono text-xs bg-[--primary] text-[--on-primary] border border-[--primary] px-3 py-1.5 hover:brightness-110 transition-all duration-150 w-full">
            ┌ create account ┐
          </button>
        </form>

        <div class="mt-4 text-xs text-[--muted-foreground] font-mono">
          <a href={"/login"} class="text-[--accent] hover:text-[--foreground] transition-colors duration-150">
            ┌ already have an account? login ┐
          </a>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end
end
