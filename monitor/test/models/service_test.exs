defmodule Monitor.ServiceTest do
  use Monitor.ModelCase

  alias Monitor.Service

  @valid_attrs %{email: "some content", expected_response: "some content", name: "some content", request_url: "some content", status: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Service.changeset(%Service{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Service.changeset(%Service{}, @invalid_attrs)
    refute changeset.valid?
  end
end
