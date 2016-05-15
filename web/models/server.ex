defmodule Monitor.Server do
  use Monitor.Web, :model

  schema "servers" do
    field :name, :string
    field :email, :string
    field :status, :string
    belongs_to :user, Monitor.User

    timestamps
  end

  @required_fields ~w(name email status)
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
