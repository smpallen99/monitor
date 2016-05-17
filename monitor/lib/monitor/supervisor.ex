defmodule Monitor.Supervisor do
  @moduledoc """
  The main supervisor.

  This supervisor is responsible for starting the Phoenix workers. As well,
  it supports starting the transient ServerSmSupervisor.
  """
  use Supervisor
  require Logger
  alias Monitor.ServerSmSupervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Starts a new ServerSm indirectly, by starting the it's ServerSmSupervisor.

  By starting the transient ServerSmSupervisor, the ServerSm will be started from
  it's initialization.
  """
  def start_server_sm(server_id) do
    id = "server_supervisor_#{server_id}"
    start_worker(__MODULE__, id,
      supervisor(ServerSmSupervisor, [server_id], id: id, restart: :transient))
  end

  def init([]) do
    children = [
      # Start the endpoint when the application starts
      supervisor(Monitor.Endpoint, []),
      # Start the Ecto repository
      supervisor(Monitor.Repo, []),

      worker(Monitor.Registry, []),
    ]

    opts = [strategy: :one_for_one]
    supervise(children, opts)
  end

  @doc """
  Child start helper that handles starting transient workers that have been
  previously stopped.

  """
  def start_worker(name, id, child_spec) do
    case Supervisor.start_child(name, child_spec) do
      {:error, :already_present} ->
        case Supervisor.delete_child(name, id) do
          :ok ->
            Supervisor.start_child(name, child_spec)
          _ ->
            Supervisor.restart_child(name, id)
        end
      other ->
        other
    end
  end

end
