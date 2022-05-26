defmodule BlogApiWeb.AuthController do
  @moduledoc """
    Auth controller, handles validation of credentials when a user is signing in
    Returns auth token if credentials are valid.
  """
  require Logger
  use BlogApiWeb, :controller
  alias BlogApi.{User, Guardian}

  # we dont have any dedicated view for auth controller,
  # nor do we need it, therefore using UserView
  plug :put_view, BlogApiWeb.UserView



  def authenitcate(conn, %{email: email, password: password}) do
    Logger.info "[Authenticate] Validating user with email : #{email}"
    # user = User.get_by_email()
    # case user do
    #   nil ->
    #     # no user against email
    #     false
    #   %User{} ->
    # end

    with {:ok, user} <- User.get_by_email(email: email),
         {:valid, user} <- User.verify_password(user, password),
         {:ok, token, _claim} <- Guardian.encode_and_sign(user) do
          # {:authenticated, token}
          render(conn, "jwt.json", jwt: token)
      else
        {:error, _error} ->
          render(conn, "error.json", msg: "invalid credentials")
    end

  end

end
