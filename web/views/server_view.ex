defmodule Monitor.ServerView do
  use Monitor.Web, :view

  def user_select(users) do
    for user <- users do
      {String.to_atom(user.name), user.id}
    end
  end

  def user_select do
    Monitor.ViewHelpers.fetch_all(Monitor.User)
    |> user_select
  end
end
