defmodule BlogApiWeb.UserPostLive.Index do
  use BlogApiWeb, :live_view
  require Logger
  alias BlogApi.{User, Post}

  # use Phoenix.LiveView

  @live_calls 0

  def title do
    "Live Users Posts"
  end

  def live_calls() do
    Logger.info "[UserPostLive] counting #{@live_calls}"
    @live_calls + 1
  end

  def user_post_link(user_id) do
    "/users/"<>Integer.to_string(user_id)<>"/posts"
  end

  # def increment_count do
  #   # @live_calls 4
  #   Module.put_attribute(__MODULE__, :live_calls, live_calls())
  # end

  def mount(_params, _session, socket) do
    Post.subscribe()
    Logger.info "[UserPostLive] Mounting ... #{live_calls()}"

    socket = assign(socket, %{users: User.all_with_posts(), live_calls: live_calls(), count: 0} )
    {:ok, socket}
  end

  # {Post, [:post | _action], _post}
  def handle_info({Post, {:post , _action}, post}, socket) do
    # increment_count()s
    IO.inspect(socket)

    Logger.debug("[UserPostLive] handling event")
    socket = assign(socket, %{users: User.all_with_posts(), live_calls: socket.assigns.live_calls + 1})

    socket =
      send_highlight_event(socket, post.user_id)

    IO.inspect(socket.assigns)
    {:noreply, socket}
  end

  defp send_highlight_event(socket, user_id) do
    socket
    |> push_event("user-updated", %{userid: user_id})
    |> put_flash(:info, "Post added")
  end

  def handle_event("inc", %{"count" => count }, socket ) do
    Logger.debug("[UserPostLive] Handling `inc` call")
    {:noreply, assign(socket, :count, count + 1)}
  end

end
