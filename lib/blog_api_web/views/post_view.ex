defmodule BlogApiWeb.PostView do

  use BlogApiWeb.View

  def render("posts.json", %{posts: posts}) do
    %{"data" => posts}
  end

end
