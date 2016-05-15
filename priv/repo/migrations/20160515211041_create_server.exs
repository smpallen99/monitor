defmodule Monitor.Repo.Migrations.CreateServer do
  use Ecto.Migration

  def change do
    create table(:servers) do
      add :name, :string
      add :email, :string
      add :status, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps
    end
    create index(:servers, [:user_id])

  end
end
