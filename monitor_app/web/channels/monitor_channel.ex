defmodule Monitor.MonitorChannel do

  use Phoenix.Channel
  require Logger

  @topic "monitor:updates"
  def join(@topic, _params, socket) do
    {:ok, socket}
  end

  def handle_out(_event, msg, socket) do
    {:reply, {:ok, msg}, socket}
  end

  def handle_in(topic, msg, socket) do
    Logger.warn "handle_in topic: #{topic}, msg: #{inspect msg}"
    {:noreply, socket}
  end

  def broadcast(item, data) when item in [:server, :service] do
    Logger.info "broadcast: #{item} #{inspect data}"
    Monitor.Endpoint.broadcast @topic, "#{item}:status_update", data
  end

  # def broadcast(topic, message, data) do
  #   Monitor.Endpoint.broadcast topic, message, data
  # end

end
