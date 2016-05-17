defmodule Monitor.ServiceView do
  use Monitor.Web, :view

  def server_select(servers) do
    for server <- servers do
      {String.to_atom(server.name), server.id}
    end
  end

  def server_select do
    Monitor.ViewHelpers.fetch_all(Monitor.Server)
    |> server_select
  end
end
