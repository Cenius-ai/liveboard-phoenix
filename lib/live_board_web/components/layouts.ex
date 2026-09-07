defmodule LiveBoardWeb.Layouts do
  @moduledoc """
  App layout components.
  """
  use LiveBoardWeb, :html

  attr :flash, :map, default: %{}
  attr :current_user, :any, default: nil

  def root(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="en" class="dark">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="csrf-token" content={Plug.CSRFProtection.get_csrf_token()} />
        <title>LiveBoard</title>
        <link rel="icon" type="image/svg+xml" href={"/assets/favicon.svg"} />
        <link phx-track-static rel="stylesheet" href={"/assets/app.css"} />
        <script src={"/assets/phoenix.min.js"}>
        </script>
        <script src={"/assets/phoenix_live_view.min.js"}>
        </script>
        <script defer phx-track-static type="text/javascript" src={"/assets/app.js"}>
        </script>
      </head>
      <body class="bg-[--background] text-[--foreground] font-mono antialiased min-h-screen">
        <nav class="h-12 flex items-center justify-between px-4 border-b border-[--border] bg-[--card] sticky top-0 z-50">
          <div class="flex items-center gap-4">
            <a href={"/dashboard"} class="text-[--accent] font-bold no-underline">
              &gt; liveboard
            </a>
            <%= if @current_user do %>
              <span class="text-[--muted-foreground] text-xs hidden sm:inline">
                ── <kbd class="px-1 py-0.5 text-[10px] bg-[--secondary] border border-[--border] rounded">⌘K</kbd> command palette
              </span>
            <% end %>
          </div>
          <div class="flex items-center gap-3 text-xs">
            <%= if @current_user do %>
              <span class="text-[--muted-foreground]">
                $ <span class="text-[--foreground]"><%= @current_user.username %></span>
              </span>
              <a href={"/settings"} class="text-[--muted-foreground] hover:text-[--foreground] transition-colors duration-150">
                ┌ settings ┐
              </a>
              <a href={"/users/log_out"} data-method="delete" class="text-[--destructive] hover:text-red-400 transition-colors duration-150">
                ┌ logout ┐
              </a>
            <% else %>
              <a href={"/register"} class="text-[--muted-foreground] hover:text-[--foreground] transition-colors duration-150">
                ┌ register ┐
              </a>
              <a href={"/login"} class="text-[--accent] hover:text-[--foreground] transition-colors duration-150">
                ┌ login ┐
              </a>
            <% end %>
          </div>
        </nav>

        <%= if @flash["error"] do %>
          <div class="max-w-4xl mx-auto mt-4 px-4">
            <div class="border border-[--destructive] bg-[--destructive]/10 text-[--destructive] px-4 py-2 text-xs font-mono" role="alert">
              ┌ ERROR ┐ <%= @flash["error"] %>
            </div>
          </div>
        <% end %>
        <%= if @flash["info"] do %>
          <div class="max-w-4xl mx-auto mt-4 px-4">
            <div class="border border-[--accent] bg-[--accent]/10 text-[--accent] px-4 py-2 text-xs font-mono" role="alert">
              ┌ INFO ┐ <%= @flash["info"] %>
            </div>
          </div>
        <% end %>

        <%= @inner_content %>
      </body>
    </html>
    """
  end

  attr :flash, :map, default: %{}
  attr :current_user, :any, default: nil

  def app(assigns) do
    ~H"""
    <main class="max-w-7xl mx-auto px-4 py-6">
      <%= @inner_content %>
    </main>
    """
  end
end
