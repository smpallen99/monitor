defmodule Monitor.PageController do
  use Monitor.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
