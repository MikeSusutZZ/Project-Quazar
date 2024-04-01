defmodule ProjectQuazar.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ProjectQuazarWeb.Telemetry,
      ProjectQuazar.Repo,
      {DNSCluster, query: Application.get_env(:project_quazar, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ProjectQuazar.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ProjectQuazar.Finch},
      # Start a worker by calling: ProjectQuazar.Worker.start_link(arg)
      # {ProjectQuazar.Worker, arg},
      # Start to serve requests, typically the last entry
      ProjectQuazarWeb.Endpoint,
      GameServer
    ]

    :ets.new(GameState, [:named_table, :public])

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ProjectQuazar.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ProjectQuazarWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
