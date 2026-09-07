defmodule LiveBoardWeb.CoreComponents do
  @moduledoc """
  Core UI components for LiveBoard.
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS

  @doc """
  Renders a styled button.
  """
  attr :type, :string, default: "button"
  attr :variant, :string, default: "primary", values: ~w(primary secondary destructive ghost)
  attr :size, :string, default: "md", values: ~w(sm md lg)
  attr :disabled, :boolean, default: false
  attr :rest, :global, include: ~w(form method name value autofocus)
  slot :inner_block, required: true

  def button(assigns) do
    base = "inline-flex items-center justify-center font-mono text-xs border transition-all duration-150 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[--ring] focus-visible:ring-offset-1 focus-visible:ring-offset-[--background] disabled:opacity-50 disabled:cursor-not-allowed"

    variants = %{
      "primary" => "bg-[--primary] text-[--on-primary] border-[--primary] hover:brightness-110 active:brightness-90",
      "secondary" => "bg-[--secondary] text-[--on-secondary] border-[--border] hover:border-[--muted-foreground] active:bg-[--muted]",
      "destructive" => "bg-[--destructive] text-[--on-destructive] border-[--destructive] hover:brightness-110 active:brightness-90",
      "ghost" => "bg-transparent text-[--muted-foreground] border-transparent hover:text-[--foreground] hover:bg-[--secondary]"
    }

    sizes = %{
      "sm" => "px-2 py-1 gap-1",
      "md" => "px-3 py-1.5 gap-1.5",
      "lg" => "px-4 py-2 gap-2 text-sm"
    }

    assigns = assign(assigns,
      base: base,
      variant_class: variants[assigns.variant],
      size_class: sizes[assigns.size]
    )

    ~H"""
    <button
      type={@type}
      disabled={@disabled}
      class={[@base, @variant_class, @size_class]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  @doc """
  Renders a styled text input.
  """
  attr :type, :string, default: "text"
  attr :name, :string, required: true
  attr :value, :any
  attr :placeholder, :string
  attr :label, :string
  attr :error, :string
  attr :rest, :global, include: ~w(autocomplete required min max step pattern disabled readonly)

  def input(assigns) do
    ~H"""
    <div class="flex flex-col gap-1">
      <%= if @label do %>
        <label for={@name} class="text-xs text-[--muted-foreground] font-mono">
          &gt; <%= @label %>
        </label>
      <% end %>
      <input
        type={@type}
        name={@name}
        id={@name}
        value={@value}
        placeholder={@placeholder}
        class={[
          "bg-[--background] border text-xs font-mono px-3 py-2 transition-colors duration-150",
          "focus:outline-none focus:ring-2 focus:ring-[--ring] focus:ring-offset-1 focus:ring-offset-[--background]",
          "placeholder:text-[--muted-foreground]/50",
          if(@error, do: "border-[--destructive]", else: "border-[--border] text-[--foreground]")
        ]}
        {@rest}
      />
      <%= if @error do %>
        <span class="text-[10px] text-[--destructive] font-mono" aria-live="polite">
          ┌ ERROR ┐ <%= @error %>
        </span>
      <% end %>
    </div>
    """
  end

  @doc """
  Renders a flash message.
  """
  attr :kind, :string, required: true
  attr :message, :string, required: true
  attr :rest, :global

  def flash(assigns) do
    ~H"""
    <div class={[
      "border px-4 py-2 text-xs font-mono",
      case @kind do
        :error -> "border-[--destructive] bg-[--destructive]/10 text-[--destructive]"
        :info -> "border-[--accent] bg-[--accent]/10 text-[--accent]"
        _ -> "border-[--border] bg-[--secondary] text-[--foreground]"
      end
    ]} {@rest}>
      <p role="alert"><%= @message %></p>
    </div>
    """
  end

  @doc """
  Renders a simple form.
  """
  attr :for, :any, default: nil
  attr :action, :string
  attr :method, :string, default: "post"
  attr :rest, :global, include: ~w(autocomplete name rel enctype)
  slot :inner_block, required: true

  def simple_form(assigns) do
    ~H"""
    <.form for={@for} action={@action} method={@method} {@rest}>
      <div class="flex flex-col gap-4">
        <%= render_slot(@inner_block) %>
      </div>
    </.form>
    """
  end

  @doc """
  Renders a modal dialog.
  """
  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}
  slot :inner_block, required: true

  def modal(assigns) do
    ~H"""
    <div
      id={@id}
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      class="hidden fixed inset-0 z-[100]"
    >
      <div class="fixed inset-0 bg-black/60 backdrop-blur-sm" phx-click-away={@on_cancel}></div>
      <div class="fixed inset-0 flex items-center justify-center p-4">
        <div class="bg-[--card] border border-[--border] shadow-lg w-full max-w-lg p-6 font-mono">
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </div>
    """
  end

  def show_modal(js \\ %JS{}, id) do
    JS.show(js, to: "##{id}")
  end

  def hide_modal(js \\ %JS{}, id) do
    JS.hide(js, to: "##{id}")
  end
end
