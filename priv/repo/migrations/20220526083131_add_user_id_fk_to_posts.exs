defmodule BlogApi.Repo.Migrations.AddUserIdFkToPosts do
  use Ecto.Migration

  def change do
    # add table(:posts), :user_id, :integer
    # create index("posts", [:name])

    alter table(:posts) do
      add :user_id, references("users", [ on_delete: :delete_all ]) #,with: [user_id: :id
    end
  end
end
