defmodule Monitor.ServerSmSupervisor do
  use Supervisor
  require Logger

  def start_link(server_id) do
    Logger.info "#{__MODULE__}.start_link #{inspect server_id}"
    Supervisor.start_link(__MODULE__, [server_id])
  end
  def start_link(opts) do
    IO.puts "....opts: #{inspect opts}"
  end

  def start_service_sm(pid, service_id) do
    Logger.info "sert_service_sm: #{inspect pid}"
    id = "service_sm_#{service_id}"
    Monitor.Supervisor.start_worker(pid, id,
      worker(Monitor.ServiceSm, [service_id], [id: id, restart: :transient]))
  end

  def init([server_id]) do

    Monitor.Registry.put(:server_sup, server_id, self())
    children = [
      worker(Monitor.ServerSm, [server_id], [restart: :transient])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one]
    supervise(children, opts)
  end


end
