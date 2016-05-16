defmodule Monitor.Server do
  use Monitor.Web, :model

  @status_options ~w(inactive offline online)

  schema "servers" do
    field :name, :string
    field :email, :string
    field :status, :string, default: hd(@status_options)
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
    |> validate_inclusion(:status, status_options)
  end

  def status_options, do: @status_options
end
