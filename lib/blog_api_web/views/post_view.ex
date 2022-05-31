defmodule BlogApiWeb.PostView do

  use BlogApiWeb, :view
  use BlogApiWeb.View

  def render("posts.json", %{posts: posts}) do
    %{"data" => posts}
  end

end
