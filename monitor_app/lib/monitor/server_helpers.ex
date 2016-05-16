defmodule Monitor.ServerHelpers do
  def do_noreply(state), do: {:noreply, state}
  def do_reply(state, reply), do: {:reply, reply, state}
end
