defmodule Menus.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MenusWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:menus, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Menus.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Menus.Finch},
      # Start a worker by calling: Menus.Worker.start_link(arg)
      # {Menus.Worker, arg},
      # Start to serve requests, typically the last entry
      MenusWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Menus.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MenusWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
