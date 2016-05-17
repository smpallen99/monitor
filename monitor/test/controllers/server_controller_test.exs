defmodule Monitor.ServerControllerTest do
  use Monitor.ConnCase

  alias Monitor.Server
  @valid_attrs %{email: "some content", name: "some content", status: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, server_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing servers"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, server_path(conn, :new)
    assert html_response(conn, 200) =~ "New server"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, server_path(conn, :create), server: @valid_attrs
    assert redirected_to(conn) == server_path(conn, :index)
    assert Repo.get_by(Server, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, server_path(conn, :create), server: @invalid_attrs
    assert html_response(conn, 200) =~ "New server"
  end

  test "shows chosen resource", %{conn: conn} do
    server = Repo.insert! %Server{}
    conn = get conn, server_path(conn, :show, server)
    assert html_response(conn, 200) =~ "Show server"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, server_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    server = Repo.insert! %Server{}
    conn = get conn, server_path(conn, :edit, server)
    assert html_response(conn, 200) =~ "Edit server"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    server = Repo.insert! %Server{}
    conn = put conn, server_path(conn, :update, server), server: @valid_attrs
    assert redirected_to(conn) == server_path(conn, :show, server)
    assert Repo.get_by(Server, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    server = Repo.insert! %Server{}
    conn = put conn, server_path(conn, :update, server), server: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit server"
  end

  test "deletes chosen resource", %{conn: conn} do
    server = Repo.insert! %Server{}
    conn = delete conn, server_path(conn, :delete, server)
    assert redirected_to(conn) == server_path(conn, :index)
    refute Repo.get(Server, server.id)
  end
end
