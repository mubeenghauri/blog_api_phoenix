defmodule BlogApiWeb.UserController do
	require Logger
  use BlogApiWeb, :controller
  alias BlogApi.{Repo, User, Guardian, Paginator}
	import Ecto.Query, only: [from: 2]

  @doc"""
   Returns all available users
  """
  def index(conn, _param) do
		users =
	  	User
	  	|> Repo.all

		IO.inspect(users)
		render conn, "users.json", users: users
  end

  def paginated(conn, %{"page" => page}) do
		users =
	  	from u in "users", select: [u.id, u.name, u.email]
    {page, _} = Integer.parse(page)
    paginated_users = Paginator.paginate(users, page)

		IO.inspect(paginated_users)
		render conn, "paginate.json", paginated: paginated_users
  end

  @spec create(Plug.Conn.t(), map) :: Plug.Conn.t()
  def create(conn, %{"name" => name, "email" => email, "password" => password}) do
    IO.puts("Insert ==> #{name} #{email}")

    with {:ok, changeset} <- {:ok, User.creation_changeset( %User{}, %{"name" => name, "email" => email, "password" => password}) },
				 {:ok, ^changeset} <- Repo.validate_changeset(changeset),
				 {:ok, user} <- Repo.insert(changeset),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user)  do
          IO.inspect(user)
          IO.inspect(token)
          # render(conn, "ok.json", msg: "user added successfully")
          render(conn, "jwt.json", jwt: token)
    else
      # validation error tuple, returned by User.validate_changeset/1
			{:errors, errors} -> render(conn, "errors.json", errors: errors)

      {:error, %Ecto.Changeset{} = error} ->
        # when Repo fails, it gives {:error, CHangeset} tuple, handling that here
        Logger.error error
        {:errors, errors} = Repo.validate_changeset(error)
        render(conn, "errors.json", errors: errors)

      {:error, error} ->
        Logger.error error
        render(conn, "error.json", msg: "failed creating user. Reason: #{Atom.to_string(error)}")

      end
  end

  def update(conn,  params) do
    IO.puts("Update ==> #{params["name"]} #{params["email"]}")

    IO.inspect(params)
    %{"id" => userid} = params

    case Map.has_key?(params, "id") do

      true ->
        # IO.inspect(changeset)
        user = User
              |> Repo.get_by!(id: userid)
              |> IO.inspect
              |> User.changeset(params)
              |> IO.inspect
        # |> Repo.update
        # |> IO.inspect
        # |> IO.puts
        case Repo.update user do
          {:ok, struct} ->
            IO.puts "OK Struct"
            IO.inspect(struct)
            render(conn, "ok.json", msg: "updated user with id : #{params["id"]}")
          {:error, changeset} ->
            IO.puts "ERROR Struct"
            IO.inspect(changeset)
            render(conn, "error.json", msg: "failed updating user :(")
        end

      false ->
        render(conn, "error.json", msg: "primary identifier for user not given :(")
    end

    render(conn, "ok.json", msg: "user updated successfully")
  end

	def show(conn, %{"id" => id} ) do
		Logger.debug "[User:show] params :"
		Logger.debug id

		{id, ""} = Integer.parse(id)

		qry = from u in "users",
					where: u.id == ^id,
					select: [u.name, u.email]

		user = qry |> Repo.one
		Logger.debug(user)
		IO.inspect user
		render(conn, "user.json", user: user)
	end

	def delete(conn, %{"id" => id}) do
		{userid, _} = Integer.parse(id)
		try do
			User
			|> Repo.get_by!(id: userid )
			|> IO.inspect
			|> Repo.delete
			# |> IO.inspect
		rescue
			e ->
				Logger.error(e)
				render(conn, "error.json", msg: "user does not exists")
		end
		render(conn, "ok.json", msg: "user deleted successfully")
	end

end
