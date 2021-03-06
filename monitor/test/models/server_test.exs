defmodule Monitor.ServerTest do
  use Monitor.ModelCase

  alias Monitor.Server

  @valid_attrs %{email: "some content", name: "some content", status: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Server.changeset(%Server{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Server.changeset(%Server{}, @invalid_attrs)
    refute changeset.valid?
  end
end
