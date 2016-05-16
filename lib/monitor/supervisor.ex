defmodule Monitor.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
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
end
