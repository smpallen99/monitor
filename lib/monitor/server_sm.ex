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

  def init([id]) do
    Registry.put :server, id, self()

    services =
      Repo.get!(Server, id)
      |> Repo.preload(:services)
      |> Server.set_status(true)
      |> Repo.update!
      |> start_services

    {:ok, %State{id: id, services: services}}
  end

  def handle_cast(:pong, state) do
    Logger.debug "pong from #{state.id}"
    server = Repo.get!(Server, state.id)
    case server.status do
      "offline" ->
        Repo.update!(Server.set_status(server, false))
        start_timer(state)
      "online" ->
        start_timer(state)
      _ ->
        state
    end
    |> do_noreply
  end

  def handle_info({:timeout, _, :watchdog_timeout}, state) do
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
    for service <- server.services do
      start_service(service)
    end
  end

  defp start_service(%Service{status: "inactive", id: id}) do
    id
  end
  defp start_service(%Service{id: id}) do
    ServiceSm.start_link id, self()
    id
  end
end
