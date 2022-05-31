defmodule BlogApi.Comment do
  require Logger
  use Ecto.Schema
  import Ecto.Changeset
  alias BlogApi.{User, Post, Repo, Comment}
	import Ecto.Query, only: [from: 2]


  @required_creation_fields ~w(content user_id post_id)a
  @module_attr ~w(content user_id post_id)a

  @derive {Jason.Encoder, only: [:id, :content, :user, :post]}
  schema "comments" do
    field :content, :string
    field :post_id, :integer
    field :user_id, :integer

    belongs_to :user, User, define_field: :false
    belongs_to :post, Post, define_field: :false

    timestamps()
  end

  @doc false
  def creation_changeset(comment, attrs) do
    comment
    |> cast(attrs, @module_attr)
    |> validate_required( @required_creation_fields )
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:post_id)
    |> validate_length(:content, min: 1)
  end

  def changeset(comment, attrs) do
    comment
    |> cast(attrs, @module_attr)
    |> validate_length(:content, min: 1)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:post_id)
  end

  def all_by(clauses) do
    query =
      from m in __MODULE__,
      # where: m.post_id == ^post_id,
      join: u in assoc(m, :user),
      join: p in assoc(m, :post),
      preload: [user: u, post: {p, user: u}]

    # query_with_where = Enum.reduce(clauses, query, fn clause, qry ->
    #   # {filed, op, operand} = clauses
    #   qry |> Ecto.Query.where(^clause)
    # end)

    query_with_where =
      query
      |> Ecto.Query.where(^clauses)

    Logger.debug(query)
    Logger.debug(query_with_where)

    query_with_where
    |> Repo.all

  end

  def update(where, update_clause) do
    Comment
    |> Repo.get_by(where)
    |> Comment.changeset(update_clause)
    |> Repo.update
  end

  def delete(where) do
    Comment
    |> Repo.get_by!(where)
    |> Repo.delete!()
  end


end
