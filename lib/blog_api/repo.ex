defmodule BlogApi.Repo do
  require Logger

  use Ecto.Repo,
    otp_app: :blog_api,
    adapter: Ecto.Adapters.Postgres

    defp is_valid_changeset?(changeset) do
      %{valid?: valid} = changeset
      valid
    end

    @spec validate_changeset(%{:valid? => any, optional(any) => any}) ::
            {:errors, any} | {:ok, %{:valid? => any, optional(any) => any}}
    def validate_changeset(changeset) do
      case is_valid_changeset?(changeset) do
        true ->
          {:ok, changeset}
        false ->
          {:errors, changeset_error_to_string(changeset)}
      end
    end

    # @spec changeset_error_to_string(Ecto.Changeset.t()) :: Map.t()
    def changeset_error_to_string(changeset) do
      Logger.info "[Repo] Extracting errors from changeset"
      Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
        Enum.reduce(opts, msg, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", to_string(value))
        end)
      end)
      |> Enum.reduce("", fn {k, v}, acc ->
        joined_errors = Enum.join(v, "; ")
        "#{acc}#{k}: #{joined_errors}\n"
      end)
    end

end
