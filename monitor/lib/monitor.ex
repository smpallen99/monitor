defmodule Monitor do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Monitor.Supervisor.start_link
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
