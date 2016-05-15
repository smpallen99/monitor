defmodule Monitor.Server do
  use Monitor.Web, :model

  schema "servers" do
    field :name, :string
    field :email, :string
    field :status, :string
    belongs_to :user, Monitor.User
    has_many :services, Monitor.Service

    timestamps
  end

  @required_fields ~w(name  status user_id)
  @optional_fields ~w(email)

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
