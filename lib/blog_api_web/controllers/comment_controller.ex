defmodule BlogApiWeb.CommentController do
	require Logger
  use BlogApiWeb, :controller
  alias BlogApi.{Repo, Comment, Post}
  use BlogApiWeb.Controller.ErrorHandler

  def index(conn, %{"user_id" => poster_id, "post_id" => post_id}) do
    # render(conn, "ok.json", msg: "yay")
    with {:ok, true} <- {:ok, Post.is_valid(%{user_id: poster_id, post_id: post_id}) } do
      comments =
        Comment.all_by([post_id: post_id])

      render(conn, "comments.json", comments: comments )
    else
      _ -> render(conn, "error.json", msg: "invalid post")
    end

  end

  def create(conn, %{"user_id" => poster_id, "post_id" => post_id, "content" => content, "commenter" => commenter_id }) do
    with {:ok, true}      <- {:ok, Post.is_valid(%{user_id: poster_id, post_id: post_id})},
         {:ok, changeset} <- {:ok, Comment.creation_changeset(%Comment{}, %{"content" => content, "post_id" => post_id, "user_id" => commenter_id})},
         {:ok, changeset} <- Repo.validate_changeset(changeset),
         {:ok, %Comment{} = _comment} <- Repo.insert(changeset) do
        render(conn, "ok.json", msg: "commeent added successfully")
    else
      {:ok, false} -> render(conn, "error.json", msg: "invalid post")

      errors ->
        handle_creation_errors(conn, errors)
    end
  end

  def show(conn, %{"user_id" => poster_id, "post_id" => post_id, "id" => comment_id }) do
    case Post.is_valid(%{user_id: poster_id, post_id: post_id}) do
      true ->
        comments = Comment.all_by([id: comment_id, post_id: post_id, user_id: poster_id])
        render(conn, "comments.json", comments: comments)

      false ->
          render(conn, "error.json", msg: "invalid post" )
    end
  end

  def update(conn, %{"user_id" => poster_id, "post_id" => post_id, "id" => comment_id, "content" => content }) do
    case Post.is_valid(%{user_id: poster_id, post_id: post_id}) do
      true ->
        try do
          Comment.update( [id: comment_id, post_id: post_id, user_id: poster_id], %{content: content} )
        rescue
          _ ->
            render(conn, "error.json", msg: "failed updating comment")
        end

      false ->
        render(conn, "error.json", msg: "failed updating comment. invalid post")

    end
  end

  def delete(conn, %{"user_id" => poster_id, "post_id" => post_id, "id" => comment_id}) do
    case Post.is_valid(%{user_id: poster_id, post_id: post_id}) do
      true ->
        try do
          Comment.delete([id: comment_id, post_id: post_id, user_id: poster_id])
        rescue
          _ ->
            render(conn, "error.json", msg: "failed updating comment.")
        end

      false ->
        render(conn, "error.json", msg: "failed updating comment. invalid post")
    end
  end

end
