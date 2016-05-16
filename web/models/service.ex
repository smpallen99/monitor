defmodule Monitor.Service do
  use Monitor.Web, :model

  schema "services" do
    field :name, :string
    field :email, :string
    field :status, :string, default: hd(Monitor.Server.status_options)
    field :request_url, :string
    field :expected_response, :string
    belongs_to :server, Monitor.Server

    timestamps
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(name  status request_url expected_response server_id email))
    |> validate_required([:name, :request_url, :expected_response, :server_id])
    |> validate_inclusion(:status, Monitor.Server.status_options)
  end

  def set_status(service, true) do
    changeset(service, %{status: "online"})
  end
  def set_status(service, false) do
    changeset(service, %{status: "offline"})
  end
end
