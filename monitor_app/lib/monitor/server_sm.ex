defmodule Monitor.ServerSm do
  use GenServer
  require Logger
  import Monitor.ServerHelpers
  alias Monitor.{Repo, Server, Service, Registry, ServerSm, ServiceSm}

  @watchdog 15000

  defmodule State do
    defstruct active?: false, id: nil, services: [], timer_ref: nil
  end

  def start_link(id) do
    GenServer.start_link(__MODULE__, [id])
  end

  def pong(pid),
    do: GenServer.cast(pid, :pong)

  def stop(pid),
    do: GenServer.cast(pid, :stop)

  def init([id]) do
    Registry.put :server, id, self()
    GenServer.cast self(), :init
    {:ok, %State{id: id}}
  end

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

  def terminate(reason, state) do
    Registry.delete(:server, state.id)

    Repo.get!(Server, state.id)
    |> Server.set_status(false)
    |> Repo.update!

    Repo.get!(Server, state.id)
    |> Repo.preload(:services)
    |> shutdown_services(state)

    spawn fn ->
      :timer.sleep(1000)
      Registry.get(:server_sup, state.id)
      |> Supervisor.stop

      Registry.delete(:server_sup, state.id)
    end
  end

  defp shutdown_services(server, state) do
    for service <- server.services do
      Registry.get(:service, service.id)
      |> ServiceSm.stop()
    end
  end

  def handle_cast(:pong, state) do
    server = Repo.get!(Server, state.id)
    # Logger.debug "pong from #{state.id}, active?: #{state.active?}, status: #{server.status}"
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
    Logger.info "starting services for server #{server.id}"
    for service <- server.services do
      start_service(server, service)
    end
  end

  defp start_service(_, %Service{status: "inactive", id: id}) do
    id
  end
  defp start_service(server, %Service{id: id}) do
    Logger.info "starting service for server #{server.id}, id: #{id}"
    # require IEx
    # IEx.pry
    Registry.get(:server_sup, server.id)
    |> Monitor.ServerSmSupervisor.start_service_sm(id)
    id
  end
end
