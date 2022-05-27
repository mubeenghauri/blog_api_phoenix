defmodule BlogApi.Repo.Migrations.AddForeignKeysToComments do
  use Ecto.Migration

  def change do

    alter table(:comments) do
      add :user_id, references("users", [ on_delete: :delete_all ])
      add :post_id, references("posts", [ on_delete: :delete_all ])
    end

  end
end
