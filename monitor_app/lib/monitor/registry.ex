defmodule Monitor.Registry do

  @default %{server: %{}, service: %{}}

  def start_link do
    Agent.start_link(fn -> @default end, name: __MODULE__)
  end

  def get do
    Agent.get __MODULE__, fn(state) -> state end
  end

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
