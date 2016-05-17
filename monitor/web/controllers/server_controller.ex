defmodule Monitor.ServerController do
  use Monitor.Web, :controller
  require Logger

  alias Monitor.{Server, Registry, ServerSm}

  plug :scrub_params, "server" when action in [:create, :update]

  def index(conn, _params) do
    servers =
      from(s in Server, order_by: [asc: s.id], preload: [:user, :services])
      |> Repo.all
    render(conn, "index.html", servers: servers)
  end

  def new(conn, _params) do
    changeset = Server.changeset(%Server{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"server" => server_params}) do
    changeset = Server.changeset(%Server{}, server_params)

    case Repo.insert(changeset) do
      {:ok, _server} ->
        conn
        |> put_flash(:info, "Server created successfully.")
        |> redirect(to: server_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    server = Repo.get!(Server, id) |> Repo.preload([:services, :user])
    render(conn, "show.html", server: server)
  end

  def edit(conn, %{"id" => id}) do
    server = Repo.get!(Server, id)
    changeset = Server.changeset(server)
    render(conn, "edit.html", server: server, changeset: changeset)
  end

  def update(conn, %{"id" => id, "server" => server_params}) do
    server = Repo.get!(Server, id)
    changeset = Server.changeset(server, server_params)

    case Repo.update(changeset) do
      {:ok, server} ->
        conn
        |> put_flash(:info, "Server updated successfully.")
        |> redirect(to: server_path(conn, :show, server))
      {:error, changeset} ->
        render(conn, "edit.html", server: server, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    server = Repo.get!(Server, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(server)

    conn
    |> put_flash(:info, "Server deleted successfully.")
    |> redirect(to: server_path(conn, :index))
  end

  def active(conn, %{"id" => id}) do
    Logger.debug "active request for id: #{inspect id}"
    id = String.to_integer id
    resp = case Repo.get(Server, id) do
      nil ->
        %{response: "invalid id"}
      _ ->
        case Registry.get :server, id do
          nil ->
            Monitor.Supervisor.start_server_sm(id)
            %{response: "service started"}
          pid ->
            ServerSm.ping(pid)
            %{response: "pong"}
        end
    end
    json conn, resp
  end
end
