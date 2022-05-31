defmodule BlogApiWeb.Router do
  use BlogApiWeb, :router

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
