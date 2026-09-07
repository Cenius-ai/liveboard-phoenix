defmodule LiveBoard.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LiveBoard.Repo,
      {DNSCluster, query: Application.get_env(:live_board, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: LiveBoard.PubSub},
      LiveBoardWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: LiveBoard.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    LiveBoardWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
