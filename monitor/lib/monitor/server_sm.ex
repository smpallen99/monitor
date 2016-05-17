defmodule Monitor.ServerSm do
  @moduledoc """
  The Server worker process.

  Responsible for timing updates from a server and notifying if there server
  stops pinging.

  At this point, the only notification that has been implemented is a channel
  broadcast to the client, displaying the offline status.

  This module can be extended to send other notifications like email, text, etc.
  """
  use GenServer
  require Logger
  import Monitor.ServerHelpers
  alias Monitor.{Repo, Server, Service, Registry, ServerSm, ServiceSm}

  @watchdog 15000

  defmodule State do
    defstruct active?: false, id: nil, services: [], timer_ref: nil
  end

  #############
  # Public API

  def start_link(id) do
    GenServer.start_link(__MODULE__, [id])
  end

  @doc """
  The API indicating that the server has pinged the web service.

  This indicates that the server is still alive.
  """
  def ping(pid),
    do: GenServer.cast(pid, :ping)

  @doc """
  The API to stop the server_sm process.
  """
  def stop(pid),
    do: GenServer.cast(pid, :stop)

  #############
  # Callbacks

  def init([id]) do
    Registry.put :server, id, self()

    # defer starting the services until this process initialization finishes
    GenServer.cast self(), :init
    {:ok, %State{id: id}}
  end


  # Handle the initialization.
  # This needs to run after `init` completes since it uses the Supervisor
  # to start the services. If run from `init`, a deadlock situation occurs.
  def handle_cast(:init, state) do
    services =
      Repo.get!(Server, state.id)
      |> Repo.preload(:services)
      |> Server.set_status(true)
      |> Repo.update!
      |> start_services
    %State{state | services: services}
    |> do_noreply
  end

  def handle_cast(:stop, state) do
    {:stop, :normal, state}
  end

  def handle_cast(:ping, state) do
    server = Repo.get!(Server, state.id)
    case server.status do
      "inactive" ->
        state
      other ->
        cond do
          state.active? and (other == "offline") ->
            Repo.update!(Server.set_status(server, true))
          not state.active? and (other == "online")
            Repo.update!(Server.set_status(server, false))
          true ->
            nil
        end
        start_timer(state)
        |> struct(active?: true)
    end
    |> do_noreply
  end

  def handle_info({:timeout, _, :watchdog_timeout}, state) do
    stop(self())
    server = Repo.get!(Server, state.id)
    case server.status do
      "online" ->
        Repo.update!(Server.set_status(server, false))
        start_timer(state)
      "offline" ->
        start_timer(state)
      _ -> state
    end
    |> struct(active?: false)
    |> do_noreply
  end

  def terminate(reason, state) do
    Registry.delete(:server, state.id)

    Repo.get!(Server, state.id)
    |> Server.set_status(false)
    |> Repo.update!

    Repo.get!(Server, state.id)
    |> Repo.preload(:services)
    |> shutdown_services(state)

    # I don't think the deferred execution is needed here...
    spawn fn ->
      :timer.sleep(1000)
      Registry.get(:server_sup, state.id)
      |> Supervisor.stop

      Registry.delete(:server_sup, state.id)
    end
  end

  #############
  # Private Helpers

  defp shutdown_services(server, state) do
    for service <- server.services do
      Registry.get(:service, service.id)
      |> ServiceSm.stop()
    end
  end

  defp start_timer(state) do
    cancel_timer(state)
    timer_ref = :erlang.start_timer @watchdog, self(), :watchdog_timeout
    %State{state | timer_ref: timer_ref}
  end

  defp cancel_timer(%State{timer_ref: nil} = state), do: state
  defp cancel_timer(%State{timer_ref: timer_ref} = state) do
    :erlang.cancel_timer timer_ref
    %State{state | timer_ref: nil}
  end

  defp start_services(%Server{status: "inactive"} = server) do
    for service <- server.services do
      service.id
    end
  end
  defp start_services(server) do
    for service <- server.services do
      start_service(server, service)
    end
  end

  defp start_service(_, %Service{status: "inactive", id: id}) do
    id
  end
  defp start_service(server, %Service{id: id}) do
    Registry.get(:server_sup, server.id)
    |> Monitor.ServerSmSupervisor.start_service_sm(id)
    id
  end
end
