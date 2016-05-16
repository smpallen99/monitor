defmodule Monitor.ServiceSm do
  use GenServer
  require Logger
  import Monitor.ServerHelpers
  alias Monitor.{Repo, Service, Registry}

  @poll_timer 8000

  defmodule State do
    defstruct online?: false, id: nil, timer_ref: nil
  end

  ##########
  # API

  def start_link(id) do
    GenServer.start_link(__MODULE__, [id])
  end

  def enable(pid, enable?),
    do: GenServer.cast(pid, {:enable, enable?})

  def stop(pid), do: GenServer.cast(pid, :stop)

  ##########
  # Callbacks

  def init([id]) do
    Logger.info "ServiceSm starting #{id}"
    Registry.put :service, id, self()
    {:ok, start_poll_timer %State{id: id}}
  end

  def handle_cast({:enable, enable?}, state) do
    ping(state)
    |> do_noreply
  end

  def handle_cast(:stop, state) do
    {:stop, :normal, state}
  end

  def terminate(reason, state) do
    Registry.delete :service, state.id

    Repo.get!(Service, state.id)
    |> Service.set_status(false)
    |> Repo.update!
  end

  def handle_info({:timeout, _ref, :poll_timeout}, state) do
    # Logger.debug "service poll_timeout #{state.id}"
    ping(state)
    |> struct(timer_ref: nil)
    |> start_poll_timer
    |> do_noreply
  end

  def handle_info(msg, state) do
    Logger.debug "unhandled info #{inspect msg}"
    do_noreply state
  end

  ##########
  # Private

  defp ping(state) do
    service = Repo.get!(Service, state.id)
    active = case HTTPoison.get(service.request_url) do
      {:ok, response} ->
        response.body == service.expected_response
      {:error, _} ->
        Logger.debug "service ping error"
        false
    end
    unless active == state.online? do
      Logger.debug "service ping active"
      Repo.update!(Service.set_status(service, active))
      %State{state | online?: active}
    else
      state
    end
    |> start_poll_timer
  end

  defp start_poll_timer(state) do
    stop_poll_timer(state)
    %State{state | timer_ref: :erlang.start_timer(@poll_timer, self(), :poll_timeout)}
  end

  defp stop_poll_timer(%{timer_ref: nil} = state), do: state
  defp stop_poll_timer(%{timer_ref: timer_ref} = state) do
    :erlang.cancel_timer timer_ref
    %State{state | timer_ref: nil}
  end

end
