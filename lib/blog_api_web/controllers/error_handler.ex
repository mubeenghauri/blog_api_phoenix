defmodule BlogApiWeb.Controller.ErrorHandler do

  def inject do
    quote do

      def handle_creation_errors(conn, error) do
        case error do
          {:errors, errors} ->
            render(conn, "errors.json", errors: errors)

          {:error, %Ecto.Changeset{} = error } ->
            {:errors, error} = BlogApi.Repo.validate_changeset(error)
            render(conn, "errors.json", errors: error)

          {:error, error} ->
            Logger.error "[Post] Failed creating "
            Logger.error error
            render(conn, "error.json", msg: "Failed creating post")
        end
      end

    end
  end

  defmacro __using__(_) do
    apply(__MODULE__, :inject, [])
  end
end
