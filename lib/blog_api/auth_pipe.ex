defmodule BlogApi.Guardian.AuthPipeline do

  use Guardian.Plug.Pipeline, otp_app: :blog_api,
  module: BlogApi.Guardian,
  error_handler: BlogApiWeb.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource

end
