defmodule LiveBoardWeb.UserSettingsLive do
  use Phoenix.LiveView, layout: {LiveBoardWeb.Layouts, :app}

  @doc false
  def init(opts), do: opts

  alias LiveBoard.Accounts

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    {:ok,
     socket
     |> assign(:user, user)
     |> assign(:email_changeset, Accounts.change_user_email(user))
     |> assign(:password_changeset, Accounts.change_user_password(user))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto">
      <h1 class="text-xl font-bold text-[--foreground] mb-6 font-mono">
        &gt; settings
      </h1>

      <div class="space-y-6">
        <div class="border border-[--border] bg-[--card] p-6">
          <h2 class="text-sm font-bold text-[--accent] mb-4 font-mono">
            ┌ profile ┐
          </h2>
          <div class="text-xs text-[--muted-foreground] font-mono space-y-1 mb-4">
            <p>username: <span class="text-[--foreground]"><%= @user.username %></span></p>
            <p>email: <span class="text-[--foreground]"><%= @user.email %></span></p>
            <p>joined: <span class="text-[--foreground]"><%= Calendar.strftime(@user.inserted_at, "%Y-%m-%d") %></span></p>
          </div>
        </div>

        <div class="border border-[--border] bg-[--card] p-6">
          <h2 class="text-sm font-bold text-[--accent] mb-4 font-mono">
            ┌ change email ┐
          </h2>
          <form phx-submit="update_email" class="flex flex-col gap-4">
            <div class="flex flex-col gap-1">
              <label class="text-xs text-[--muted-foreground] font-mono">&gt; new email</label>
              <input
                type="email"
                name="user[email]"
                value={@user.email}
                placeholder="you@example.com"
                required
                autocomplete="email"
                class="bg-[--background] border border-[--border] text-xs font-mono px-3 py-2 focus:outline-none focus:ring-2 focus:ring-[--ring] text-[--foreground]"
              />
            </div>
            <button type="submit" class="inline-flex items-center justify-center font-mono text-xs bg-[--primary] text-[--on-primary] border border-[--primary] px-3 py-1.5 hover:brightness-110 transition-all duration-150 self-start">
              ┌ update email ┐
            </button>
          </form>
        </div>

        <div class="border border-[--border] bg-[--card] p-6">
          <h2 class="text-sm font-bold text-[--accent] mb-4 font-mono">
            ┌ change password ┐
          </h2>
          <form phx-submit="update_password" class="flex flex-col gap-4">
            <div class="flex flex-col gap-1">
              <label class="text-xs text-[--muted-foreground] font-mono">&gt; current password</label>
              <input
                type="password"
                name="user[current_password]"
                placeholder="········"
                required
                autocomplete="current-password"
                class="bg-[--background] border border-[--border] text-xs font-mono px-3 py-2 focus:outline-none focus:ring-2 focus:ring-[--ring] text-[--foreground]"
              />
            </div>
            <div class="flex flex-col gap-1">
              <label class="text-xs text-[--muted-foreground] font-mono">&gt; new password</label>
              <input
                type="password"
                name="user[password]"
                placeholder="········"
                required
                autocomplete="new-password"
                class="bg-[--background] border border-[--border] text-xs font-mono px-3 py-2 focus:outline-none focus:ring-2 focus:ring-[--ring] text-[--foreground]"
              />
            </div>
            <button type="submit" class="inline-flex items-center justify-center font-mono text-xs bg-[--primary] text-[--on-primary] border border-[--primary] px-3 py-1.5 hover:brightness-110 transition-all duration-150 self-start">
              ┌ update password ┐
            </button>
          </form>
        </div>

        <div class="border border-[--destructive] bg-[--destructive]/5 p-6">
          <h2 class="text-sm font-bold text-[--destructive] mb-4 font-mono">
            ┌ danger zone ┐
          </h2>
          <p class="text-xs text-[--muted-foreground] mb-3 font-mono">
            deleting your account is permanent and cannot be undone.
          </p>
          <button
            phx-click="delete_account"
            phx-confirm="Are you sure? This is permanent and cannot be undone."
            class="text-xs text-[--destructive] hover:text-red-400 border border-[--destructive] px-3 py-1.5 font-mono transition-colors duration-150"
          >
            ┌ delete account ┐
          </button>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("update_email", %{"user" => %{"email" => email}}, socket) do
    user = socket.assigns.current_user

    case Accounts.update_user_email(user, %{email: email}) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Email updated successfully")
         |> assign(:email_changeset, Accounts.change_user_email(%{user | email: email}))}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_changeset, changeset)}
    end
  end

  def handle_event("update_password", %{"user" => params}, socket) do
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, params["password"], params["current_password"]) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Password updated successfully")
         |> assign(:password_changeset, Accounts.change_user_password(user))}

      {:error, changeset} ->
        {:noreply, assign(socket, :password_changeset, changeset)}
    end
  end

  def handle_event("delete_account", _params, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "Account deletion is disabled in demo mode")
     |> redirect(to: "/dashboard")}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end
end
