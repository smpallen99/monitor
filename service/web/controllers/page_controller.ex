defmodule Service.PageController do
  use Service.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def ping(conn, _params) do
    json conn, %{response: "pong"}
  end
end
