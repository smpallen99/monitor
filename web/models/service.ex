defmodule Monitor.Service do
  use Monitor.Web, :model

  schema "services" do
    field :name, :string
    field :email, :string
    field :status, :string
    field :request_url, :string
    field :expected_response, :string
    belongs_to :server, Monitor.Server

    timestamps
  end

  @required_fields ~w(name email status request_url expected_response)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
