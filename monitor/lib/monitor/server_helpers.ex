defmodule Monitor.ServerHelpers do
  @moduledoc """
  Helpers I like to use in my GenServers to get ride of those nasty
  return tuples.

  These functions also make it easy to pipe results.

  ## Examples

      def handle_cast({:update, data}, state) do
        %State{state | data: data}
        |> do_noreply
      end
  """

  def do_noreply(state), do: {:noreply, state}
  def do_reply(state, reply), do: {:reply, reply, state}
end
