defmodule Monitor.Repo.Migrations.CreateService do
  use Ecto.Migration

  def change do
    create table(:services) do
      add :name, :string
      add :email, :string
      add :status, :string
      add :request_url, :string
      add :expected_response, :string
      add :server_id, references(:servers, on_delete: :nothing)

      timestamps
    end
    create index(:services, [:server_id])

  end
end
