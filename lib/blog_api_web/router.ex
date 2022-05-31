defmodule BlogApiWeb.Router do
  # use Phoenix.LiveView.Router
  # import Phoenix.LiveView.Helpers
  # import BlogApiWeb.LiveHelpers
  use BlogApiWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {BlogApiWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end


  scope "/", BlogApiWeb do
    pipe_through :browser

    live "/userpostslive", UserPostLive.Index

    get "/users", UserController, :all_users
    get "/users/:user_id/posts", PostController, :all_posts
  end


  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :jwt_auth do
    plug BlogApi.Guardian.AuthPipeline
  end

  scope "/api", BlogApiWeb do
    pipe_through :api

    post "/signin", AuthController, :authenticate
  end

  scope "/api", BlogApiWeb do
    pipe_through [:api, :jwt_auth]

    # paginated routes
    get "/users/page/:page", UserController, :paginated
    get "/posts/page/:page", PostController, :paginated

    resources "/users", UserController, only: [:index, :show, :create, :update, :delete] do
      resources "/posts", PostController, only: [:index, :show, :create, :update, :delete] do
        resources "/comments", CommentController, [:index, :show, :create, :update, :delete]
      end
    end

  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: BlogApiWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end

# %Plug.Conn{
#   adapter: {Plug.Cowboy.Conn, :...},
#   assigns: %{layout: {BlogApiWeb.LayoutView, "app.html"},
#   posts: [%{content: "This is my second first ever post :)", title: "Second Post"}, %{content: "This is my third Post !!!!", title: "Third Post"}, %{content: "This is post 1 for user 1", title: "My Post 1"}, %{content: "This is post 2 for user 1", title: "My Post 2"}, %{content: "This is post 3 for user 1", title: "My Post 3"}, %{content: "This is post 4 for user 1", title: "My Post 4"}, %{content: "This is post 5 for user 1", title: "My Post 5"}, %{content: "This is post 6 for user 1", title: "My Post 6"}, %{content: "This is post 7 for user 1", title: "My Post 7"}, %{content: "This is post 8 for user 1", title: "My Post 8"}, %{content: "This is post 9 for user 1", title: "My Post 9"}, %{content: "This is post 10 for user 1", title: "My Post 10"}, %{content: "This is post 11 for user 1", title: "My Post 11"}, %{content: "This is post 12 for user 1", title: "My Post 12"}, %{content: "This is post 13 for user 1", title: "My Post 13"}, %{content: "This is post 14 for user 1", title: "My Post 14"}, %{content: "This is post 15 for user 1", title: "My Post 15"}, %{content: "This is post 16 for user 1", title: "My Post 16"}, %{content: "This is post 17 for user 1", title: "My Post 17"}, %{content: "This is post 18 for user 1", title: "My Post 18"}, %{content: "This is post 19 for user 1", title: "My Post 19"}, %{content: "This is post 20 for user 1", title: "My Post 20"}]},
#   body_params: %{},
#   cookies: %{"PGADMIN_LANGUAGE" => "en", "_blog_api_key" => "SFMyNTY.g3QAAAABbQAAAAtfY3NyZl90b2tlbm0AAAAYMk9xb1hMM0hnUldrWXBKalVwUmZqUDRN.TrWUDnPTZlMtD8y3ViCBN-gKS_AYp3IogjIApcdQbWo"},
#   halted: false,
#   host: "localhost",
#   method: "GET",
#   owner: #PID<0.4081.0>,
#   params: %{"user_id" => "1"},
#   path_info: ["users", "1", "posts"],
#   path_params: %{"user_id" => "1"},
#   port: 4000,
#   private: %{BlogApiWeb.Router => {[], %{Plug.Swoosh.MailboxPreview => ["mailbox"]}},
#   :before_send => [#Function<0.16477574/1 in Plug.CSRFProtection.call/2>, #Function<2.17183421/1 in Phoenix.Controller.fetch_flash/2>, #Function<0.77458138/1 in Plug.Session.before_send/2>, #Function<0.23023616/1 in Plug.Telemetry.call/2>],
#   :phoenix_action => :all_posts,
#   :phoenix_controller => BlogApiWeb.PostController,
#   :phoenix_endpoint => BlogApiWeb.Endpoint,
#   :phoenix_flash => %{},
#   :phoenix_format => "html",
#   :phoenix_layout => {BlogApiWeb.LayoutView, :app},
#   :phoenix_request_logger => {"request_logger", "request_logger"},
#   :phoenix_root_layout => {BlogApiWeb.LayoutView, :root},
#   :phoenix_router => BlogApiWeb.Router,
#   :phoenix_template => "index.html",
#   :phoenix_view => BlogApiWeb.PostView,
#   :plug_session => %{"_csrf_token" => "2OqoXL3HgRWkYpJjUpRfjP4M"},
#   :plug_session_fetch => :done},
#   query_params: %{},
#   query_string: "",
#   remote_ip: {127, 0, 0, 1},
#   req_cookies: %{"PGADMIN_LANGUAGE" => "en", "_blog_api_key" => "SFMyNTY.g3QAAAABbQAAAAtfY3NyZl90b2tlbm0AAAAYMk9xb1hMM0hnUldrWXBKalVwUmZqUDRN.TrWUDnPTZlMtD8y3ViCBN-gKS_AYp3IogjIApcdQbWo"},
#   req_headers: [{"accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"}, {"accept-encoding", "gzip, deflate, br"}, {"accept-language", "en-US,en;q=0.9"}, {"connection", "keep-alive"}, {"cookie", "PGADMIN_LANGUAGE=en; _blog_api_key=SFMyNTY.g3QAAAABbQAAAAtfY3NyZl90b2tlbm0AAAAYMk9xb1hMM0hnUldrWXBKalVwUmZqUDRN.TrWUDnPTZlMtD8y3ViCBN-gKS_AYp3IogjIApcdQbWo"}, {"host", "localhost:4000"}, {"referer", "http://localhost:4000/users"}, {"sec-ch-ua", "\" Not A;Brand\";v=\"99\", \"Chromium\";v=\"102\", \"Google Chrome\";v=\"102\""}, {"sec-ch-ua-mobile", "?0"}, {"sec-ch-ua-platform", "\"Linux\""}, {"sec-fetch-dest", "document"}, {"sec-fetch-mode", "navigate"}, {"sec-fetch-site", "same-origin"}, {"sec-fetch-user", "?1"}, {"upgrade-insecure-requests", "1"}, {"user-agent", "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.5005.61 Safari/537.36"}],
#   request_path: "/users/1/posts",
#   resp_body: nil,
#   resp_cookies: %{},
#   resp_headers: [{"cache-control", "max-age=0, private, must-revalidate"}, {"x-request-id", "FvMB6-INQs4p5CIAAHXh"}, {"x-frame-options", "SAMEORIGIN"}, {"x-xss-protection", "1; mode=block"}, {"x-content-type-options", "nosniff"}, {"x-download-options", "noopen"}, {"x-permitted-cross-domain-policies", "none"}, {"cross-origin-window-policy", "deny"}],
#   scheme: :http,
#   script_name: [],
#   secret_key_base: :...,
#   state: :unset,
#   status: nil},
#   posts: [%{content: "This is my second first ever post :)", title: "Second Post"}, %{content: "This is my third Post !!!!", title: "Third Post"}, %{content: "This is post 1 for user 1", title: "My Post 1"}, %{content: "This is post 2 for user 1", title: "My Post 2"}, %{content: "This is post 3 for user 1", title: "My Post 3"}, %{content: "This is post 4 for user 1", title: "My Post 4"}, %{content: "This is post 5 for user 1", title: "My Post 5"}, %{content: "This is post 6 for user 1", title: "My Post 6"}, %{content: "This is post 7 for user 1", title: "My Post 7"}, %{content: "This is post 8 for user 1", title: "My Post 8"}, %{content: "This is post 9 for user 1", title: "My Post 9"}, %{content: "This is post 10 for user 1", title: "My Post 10"}, %{content: "This is post 11 for user 1", title: "My Post 11"}, %{content: "This is post 12 for user 1", title: "My Post 12"}, %{content: "This is post 13 for user 1", title: "My Post 13"}, %{content: "This is post 14 for user 1", title: "My Post 14"}, %{content: "This is post 15 for user 1", title: "My Post 15"}, %{content: "This is post 16 for user 1", title: "My Post 16"}, %{content: "This is post 17 for user 1", title: "My Post 17"}, %{content: "This is post 18 for user 1", title: "My Post 18"}, %{content: "This is post 19 for user 1", title: "My Post 19"}, %{content: "This is post 20 for user 1", title: "My Post 20"}]})
