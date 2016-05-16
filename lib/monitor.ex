defmodule Monitor do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the endpoint when the application starts
      supervisor(Monitor.Endpoint, []),
      # Start the Ecto repository
      supervisor(Monitor.Repo, []),
      # Here you could define other workers and supervisors as children
      # worker(Monitor.Worker, [arg1, arg2, arg3]),
      worker(Monitor.Registry, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Monitor.Supervisor]
    Supervisor.start_link(children, opts)
    |> init_status
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Monitor.Endpoint.config_change(changed, removed)
    :ok
  end

  def init_status(sup_result) do
    import Ecto.Query
    alias Monitor.{Repo, Server, Service}

    from(s in Server, where: s.status == "online", update: [set: [status: "offline"]])
    |> Repo.update_all([])
    from(s in Service, where: s.status == "online", update: [set: [status: "offline"]])
    |> Repo.update_all([])

    sup_result
  end
end
