defmodule Whatsapp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      WhatsappWeb.Telemetry,
      Whatsapp.Repo,
      {Finch, name: Swoosh.Finch},
      {DNSCluster, query: Application.get_env(:whatsapp, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Whatsapp.PubSub},
      # Start a worker by calling: Whatsapp.Worker.start_link(arg)
      # {Whatsapp.Worker, arg},
      # Start to serve requests, typically the last entry
      WhatsappWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Whatsapp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WhatsappWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
