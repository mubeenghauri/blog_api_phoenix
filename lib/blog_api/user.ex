defmodule BlogApi.User do
  use Ecto.Schema
  import Ecto.Changeset

  # for password hashing.
  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  require Logger

  schema "users" do
    field :email, :string
    field :name, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    timestamps()
  end

  @doc"""
    To be used only when creating a user,
    Reason for keeping it this way is that we need to require
    all fields at the time for creation. This may not be true
    for when updating etc,
  """
  def creation_changeset(%BlogApi.User{} = user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password])
    |> validate_required([:name, :email, :password])
    # Check that email is valid
    |> validate_format(:email, ~r/@/)
    # Check that password length is > 8
    |> validate_length(:password, min: 8)
    |> unique_constraint(:email)
    |> password_hash
  end

  def changeset(%BlogApi.User{} = user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password])
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 8)
    |> unique_constraint(:email)
    |> password_hash
  end

  def password_hash(changeset) do
    Logger.info "[User] Updating password hash"
    case changeset do
      # only update hash if password is changed
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        Logger.info "[User] Generated password hash for #{pass}"
        changed = put_change(changeset, :password_hash, hashpwsalt(pass))
        IO.inspect(changed)
        changed

      _ ->
        Logger.info "[User] Not Generated password reason: no change"
        IO.inspect(changeset)
        changeset
      end
  end

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

  def get_by_email(%{email: email})

end
