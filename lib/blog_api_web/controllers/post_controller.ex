defmodule BlogApiWeb.PostController do
  require Logger
  use BlogApiWeb, :controller
  alias BlogApi.{Repo, Post, Paginator}
  use BlogApiWeb.Controller.ErrorHandler
	import Ecto.Query, only: [from: 2]


  def index(conn, %{"user_id" => user_id}) do
    # IO.inspect (param)
    with {:ok, posts} <- Post.all_by_user(user_id) do
      render(conn, "posts.json", posts: posts)
    else
      {:error, :nopost} ->
        render(conn, "posts.json", posts: [])
    end
  end

  def paginated(conn, %{"page" => page}) do
    {page, _} = Integer.parse(page)
    posts =
        from p in Post,
        join: u in assoc(p, :user),
        preload: [user: u]
        # select: [p.id, p.title, p.content]

    paginated_post = Paginator.paginate(posts, page)

    Logger.debug paginated_post
    render conn, "paginate.json", paginated: paginated_post
  end

  def create(conn, %{"user_id" => _user_id, "title" => _title, "content" => _content} = param) do

    with {:ok, changeset} <- {:ok, Post.creation_changeset(%Post{}, param)},
         {:ok, changeset} <- Repo.validate_changeset(changeset),
         {:ok, %Post{} = _post} <- Repo.insert(changeset) do
          render(conn, "ok.json", msg: "post created successfully")
    else
      # TODO: enclose below matching to function? (handle_creation_error/1 maybe?)
      error ->
        handle_creation_errors(conn, error)
    end
  end

  def show(conn, %{"user_id" => user_id, "id" => post_id}) do
    with {:ok, post} <- Post.post_by_user(user_id, post_id)
    do
      render(conn, "posts.json", posts: post)
    else
      _ ->
        render(conn, "error.json", msg: "no post found")
    end
  end

  def delete(conn,  %{"user_id" => user_id, "id" => post_id}) do
    case Post.delete(user_id, post_id) do
      :ok ->
        render(conn, "ok.json", msg: "post deleted successfully")
      :error ->
        render(conn, "error.json", msg: "failed deleting post. are u sure this post exists?")
    end
  end

end
