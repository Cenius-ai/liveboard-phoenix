defmodule LiveBoardWeb.UserSessionLive do
  use Phoenix.LiveView, layout: {LiveBoardWeb.Layouts, :app}

  @doc false
  def init(opts), do: opts

  @impl true
  def mount(_params, _session, socket) do
    if socket.assigns.current_user do
      {:ok, redirect(socket, to: "/dashboard")}
    else
      {:ok, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-md mx-auto mt-16 px-4">
      <div class="border border-[--border] bg-[--card] p-6">
        <h1 class="text-lg font-bold text-[--accent] mb-1 font-mono">
          &gt; login
        </h1>
        <p class="text-[--muted-foreground] text-xs mb-6 font-mono">
          ┌ authenticate to continue ┐
        </p>

        <form action={"/users/log_in"} method="post" class="flex flex-col gap-4">
          <input type="hidden" name="_csrf_token" value={Plug.CSRFProtection.get_csrf_token()} />
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
              autocomplete="current-password"
              class="bg-[--background] border border-[--border] text-xs font-mono px-3 py-2 focus:outline-none focus:ring-2 focus:ring-[--ring] text-[--foreground] placeholder:text-[--muted-foreground]/50"
            />
          </div>
          <div class="flex items-center gap-2">
            <input type="checkbox" name="user[remember_me]" id="remember_me" value="true" class="accent-[--accent]" />
            <label for="remember_me" class="text-xs text-[--muted-foreground] font-mono cursor-pointer">
              remember me
            </label>
          </div>
          <button type="submit" class="inline-flex items-center justify-center font-mono text-xs bg-[--primary] text-[--on-primary] border border-[--primary] px-3 py-1.5 hover:brightness-110 transition-all duration-150 w-full">
            ┌ login ┐
          </button>
        </form>

        <div class="mt-4 pt-4 border-t border-[--border] text-xs text-[--muted-foreground] font-mono">
          <p class="mb-1 text-[--accent]">
            ┌ DEMO CREDENTIALS ┐
          </p>
          <p>Email: <span class="text-[--foreground]">cenius@cenius.ai</span></p>
          <p>Password: <span class="text-[--foreground]">cenius</span></p>
        </div>

        <div class="mt-4 text-xs text-[--muted-foreground] font-mono">
          <a href={"/register"} class="text-[--accent] hover:text-[--foreground] transition-colors duration-150">
            ┌ create account ┐
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
