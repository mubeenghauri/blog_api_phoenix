defmodule BlogApiWeb.CommentView do
  use BlogApiWeb.View

  def render("comments.json", %{comments: comments} ) do
    %{"data" => comments}
  end
end
