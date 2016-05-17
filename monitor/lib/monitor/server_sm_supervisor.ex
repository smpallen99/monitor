defmodule Monitor.ServerSmSupervisor do
  @moduledoc """
  Supervisor responsible for ServerSm and ServiceSM processes.

  Upon startup, this supervisor starts the ServerSm with the transient
  restart strategy. It also supports dynamically starting ServiceSM processes.

  """
  use Supervisor

  def start_link(server_id) do
    Supervisor.start_link(__MODULE__, [server_id])
  end

  @doc """
  Start a ServiceSM process.
  """
  def start_service_sm(pid, service_id) do
    id = "service_sm_#{service_id}"
    Monitor.Supervisor.start_worker(pid, id,
      worker(Monitor.ServiceSm, [service_id], id: id, restart: :transient))
  end

  def init([server_id]) do

    # Register this supervisor in the registry so we can find the pid later
    Monitor.Registry.put(:server_sup, server_id, self())

    children = [
      worker(Monitor.ServerSm, [server_id], [restart: :transient])
    ]
    opts = [strategy: :one_for_one]
    supervise(children, opts)
  end


end
