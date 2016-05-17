defmodule Monitor.MonitorChannel do
  @moduledoc """
  Channel uses to update the status information on the client

  Simple channel implementation to push server and service status
  updates to the channel.
  """

  use Phoenix.Channel
  require Logger

  @topic "monitor:updates"

  def join(@topic, _params, socket) do
    {:ok, socket}
  end

  @doc """
  Handle the outdoing messages
  """
  def handle_out(_event, msg, socket) do
    {:reply, {:ok, msg}, socket}
  end

  @doc """
  Default in handler.

  Don't expected any messages in from the client, but added this just in case.
  """
  def handle_in(topic, msg, socket) do
    Logger.warn "handle_in topic: #{topic}, msg: #{inspect msg}"
    {:noreply, socket}
  end

  @def """
  Helper to format and broadcast the status update messages.
  """
  def broadcast(item, data) when item in [:server, :service] do
    Monitor.Endpoint.broadcast @topic, "#{item}:status_update", data
  end

end
