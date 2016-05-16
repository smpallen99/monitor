defmodule Monitor.ViewHelpers do
  import Phoenix.HTML.Tag

  def fetch_all(model) when is_atom(model) do
    Monitor.Repo.all model
  end
  def fetch_all(model) when is_map(model) do
    fetch_all model.__struct__
  end

  def status_class("inactive"), do: "bg-warning"
  def status_class("online"), do: "bg-success"
  def status_class("offline"), do: "bg-danger"

  def display_status(model) do
    content_tag :span, class: "status " <> status_class(model.status) do
      model.status
    end
  end
end
