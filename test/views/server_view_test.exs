defmodule Monitor.ServerViewTest do
  use Monitor.ConnCase, async: true
  alias Monitor.{Repo, User}

  test "user_select" do

    users = [%User{id: 1, name: "User 1", email: "11"}, %User{id: 2, name: "User 2", email: "22"}]
    assert Monitor.ServerView.user_select(users) == ["User 1": 1, "User 2": 2]
  end
end
