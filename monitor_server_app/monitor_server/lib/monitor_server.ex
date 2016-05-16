defmodule MonitorServer do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    set_monitor_url

    children = [
      # Define workers and child supervisors to be supervised
      worker(MonitorServer.Server, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MonitorServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp set_monitor_url do
    case System.get_env["MONITOR_ID"] do
      nil ->
        throw "Must pass env variable MONITOR_ID"
      id ->
        url = Application.get_env(:monitor_server, :monitor_url)
        |> String.replace("##MONITOR_ID##", id)
        Application.put_env :monitor_server, :monitor_url, url
    end
  end
end
