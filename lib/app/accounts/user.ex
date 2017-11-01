defmodule App.Accounts.User do
  @moduledoc """
  User model.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias App.Accounts.User
  alias Comeonin.Bcrypt

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :password_reset_token, :string
    field :access_token, :string

    timestamps()
  end

  @doc """
  Generic user changeset

  ## Examples

      iex> changeset(%User{}, %{email: user@example.com})
      %Ecto.Changeset{}

  """
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_required([:email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end

  @doc """
  Changeset for creating/updating a users password
  """
  def facebook_changeset(%User{} = user, attrs) do
    user
    |> changeset(attrs)
    |> cast(attrs, [:access_token])
    |> validate_required([:access_token])
  end

  def password_changeset(%User{} = user, attrs) do
    user
    |> changeset(attrs)
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 5)
    |> put_password_hash()
    |> validate_required([:password_hash])
    |> put_change(:password_reset_token, nil)
  end

  @doc """
  Changeset for updating a users
  """
  def password_reset_changeset(%User{} = user, attrs) do
    user
    |> changeset(attrs)
    |> cast(attrs, [:password_reset_token])
    |> validate_required([:password_reset_token])
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end
end
