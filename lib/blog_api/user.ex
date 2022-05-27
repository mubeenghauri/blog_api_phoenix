defmodule BlogApi.User do
  use Ecto.Schema
  require Logger
  import Ecto.Changeset
  alias BlogApi.{User, Post}

  # for password hashing, and validation.
  import Comeonin.Bcrypt, only: [hashpwsalt: 1, checkpw: 2]

  schema "users" do
    field :email, :string
    field :name, :string
    field :password_hash, :string
    field :password, :string, virtual: true

    has_many :posts, {"posts", Post}, foreign_key: :user_id

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


  @doc """
   Generic function to get user by any number of attributes.
   Main purpose for this is to get verbose response in case of
   error, i.e error:reason tuple
  """
  def by( attr ) do
    user =
      User
      |> BlogApi.Repo.get_by( attr )

      case user do
        nil ->
          {:error, :nouser}
        %BlogApi.User{} ->
          {:ok, user}
      end
  end

  def verify_password(%User{} = user, password) do
    if checkpw(password, user.password_hash) do
      {:valid, user}
    else
      {:error, :invalid_password}
    end
  end


end
