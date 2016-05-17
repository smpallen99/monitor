defmodule MonitorServer.Server do
  use GenServer
  require Logger

  @timer 5000

  def start_link do
    GenServer.start_link __MODULE__, []
  end

  def init(_) do
    Logger.debug "starting up"
    :timer.send_interval @timer, self(), :timeout
    ping_server
    {:ok, nil}
  end

  def handle_info(:timeout, msg) do
    ping_server
    {:noreply, nil}
  end

  defp ping_server do
    Logger.debug "ping_server"
    url = Application.get_env(:monitor_server, :monitor_url)
    case HTTPoison.get url do
      {:ok, _} -> :ok
      {:error, error} ->
        Logger.debug "error: #{inspect error}"
    end
  end
end
