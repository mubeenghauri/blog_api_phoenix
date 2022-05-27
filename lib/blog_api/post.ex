defmodule BlogApi.Post do
  use Ecto.Schema
  alias BlogApi.{Repo, Post, User}
  require Logger
  import Ecto.Changeset
	import Ecto.Query, only: [from: 2]


  # note to self: adding the suffix 'a' gives a list of atom
  @required_registration_fields ~w(content title user_id)a

  @derive {Jason.Encoder, only: [:id, :title, :content, :user]}
  schema "posts" do
    field :content, :string
    field :title, :string
    field :user_id, :integer

    belongs_to :user, User, define_field: :false

    timestamps()
  end

  @doc false
  def creation_changeset(post, attrs) do
    post
    |> cast(attrs, [:content, :title, :user_id])
    |> validate_required(@required_registration_fields)
    |> validate_length(:content, min: 8)
    |> validate_length(:title, min: 8)
  end

  def changeset(post, attrs) do
    post
    |> cast(attrs, [:content, :title, :user_id ])
    |> validate_length(:content, min: 8)
    |> validate_length(:title, min: 8)
  end

  # def by( params ) do
  #   """
  #     resource = __MODULE__ |> Repo.get etc...
  #     ???
  #   """
  #   post =
  #     Post
  #     |> Repo.get_by( params )

  #   case post do
  #     nil ->
  #       {:error, :nopost}
  #     %BlogApi.Post{} ->
  #       {:ok, post}
  #   end
  # end

  def all_by_user( user_id ) do
    {user_id, _} = Integer.parse(user_id)
    post = Repo.all( from p in "posts",
                    where: p.user_id == ^user_id,
                    select: [:title, :content]  )

    case post do
      nil ->
        {:error, :nopost}
      _ ->
        {:ok, post}
    end
  end

  def post_by_user(user_id, post_id) do
    {user_id, _} = Integer.parse(user_id)
    {post_id, _} = Integer.parse(post_id)
    post = Repo.all( from p in "posts",
                    where: p.user_id == ^user_id,
                    where: p.id == ^post_id,
                    select: [:title, :content])

    case post do
      nil ->
        {:error, :nopost}
      _ ->
        {:ok, post}
    end
  end

  def delete(user_id, post_id) do
    {user_id, _} = Integer.parse(user_id)
    {post_id, _} = Integer.parse(post_id)

    try do
      Post
      |> Repo.get_by!(user_id: user_id, id: post_id)
      |> Repo.delete

      :ok
    rescue
      e ->
        Logger.error "Failed deleting post"
        Logger.error e

        :error
    end
  end

  # defp get_by(queryable, clauses, opts \\ []) do
  #   # use Ecto.Repo
  #   Ecto.Repo.Queryable.all(__MODULE__, Ecto.Repo.query_for_get_by(queryable, clauses), opts)
  # end
end
