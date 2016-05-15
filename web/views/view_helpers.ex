defmodule Monitor.ViewHelpers do

  def fetch_all(model) when is_atom(model) do
    Monitor.Repo.all model
  end
  def fetch_all(model) when is_map(model) do
    fetch_all model.__struct__
  end

end
