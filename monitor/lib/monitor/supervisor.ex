Code.ensure_loaded Monitor.ServerSmSupervisor
defmodule Monitor.Supervisor do
  use Supervisor
  require Logger
  alias Monitor.ServerSmSupervisor

  def start_link do
    Logger.info "#{__MODULE__}.start_link"
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_server_sm(server_id) do
    id = "server_supervisor_#{server_id}"
    {:ok, pid} = start_worker(__MODULE__, id,
      supervisor(ServerSmSupervisor, [server_id], restart: :transient))
    Logger.info "++++++ server_sm_supervisor #{inspect pid}"

    {:ok, pid}
  end

  def init([]) do

    children = [
      # Start the endpoint when the application starts
      supervisor(Monitor.Endpoint, []),
      # Start the Ecto repository
      supervisor(Monitor.Repo, []),

      worker(Monitor.Registry, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one]
    supervise(children, opts)
  end

  def start_worker(name, id, child_spec) do
    Logger.info ".....start_worker name: #{inspect name}, id: #{id}"
    # require IEx
    # IEx.pry
    case Supervisor.start_child(name, child_spec) do
      {:error, :already_present} ->
        Logger.info "#{__MODULE__}.start_worker: restarting #{id}"
        case Supervisor.delete_child(name, id) do
          :ok ->
            Logger.info "#{__MODULE__} Delete and start child id: #{id}"
            Supervisor.start_child(name, child_spec)
          _ ->
            Logger.info "#{__MODULE__} Could not delete child. Restarting child id: #{id}"
            Supervisor.restart_child(name, id)
        end
      other ->
        other
    end
  end

end
