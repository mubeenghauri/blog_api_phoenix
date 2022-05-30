defmodule BlogApiWeb.UserPostLive.Index do
  use BlogApiWeb, :live_view
  require Logger
  alias BlogApi.{User, Post}

  def title do
    "Live Users Posts"
  end

  def user_post_link(user_id) do
    "/users/"<>Integer.to_string(user_id)<>"/posts"
  end

  def mount(_params, _session, socket) do
    Post.subscribe()
    socket = assign(socket, users: User.all_with_posts() )
    {:ok, socket}
  end

  # {Post, [:post | _action], _post}
  def handle_info({Post, {:post , _action}, _post}, socket) do
    Logger.debug("[UserPostLive] handling event")
    socket = assign(socket, users: User.all_with_posts())
    {:noreply, socket}
  end

end
