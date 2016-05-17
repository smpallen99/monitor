defmodule Monitor.Registry do
  @moduledoc """
  Simple registry for managing pid lookups.
  """

  @default %{server: %{}, service: %{}, server_sup: %{}}

  def start_link do
    Agent.start_link(fn -> @default end, name: __MODULE__)
  end

  def get do
    Agent.get __MODULE__, fn(state) -> state end
  end

  @doc """
  Get the pid for a specific key.

  ## Examples:

      Monitor.Registry.get(:server, 1)
  """
  def get(key, id) do
    Agent.get __MODULE__, fn(state) -> state[key][id] end
  end

  def put(key, id, pid) do
    Agent.cast __MODULE__, fn(state) -> Map.put(state, key, Map.put(state[key], id, pid)) end
  end

  def clear do
    Agent.cast __MODULE__, fn(_) -> @default end
  end

  def delete(key, id) do
    Agent.cast __MODULE__, fn(state) -> Map.put(state, key, Map.delete(state[key], id)) end
  end
end
