defmodule BlogApi.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def up do
    create table(:users) do
      add :name, :string
      # add :email, :string
      add :password, :string

      timestamps()
    end
    create unique_index(:users, [:email])

  end


  def down do
    drop table(:users)
  end
end
