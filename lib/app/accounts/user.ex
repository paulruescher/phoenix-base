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

    timestamps()
  end

  @doc """
  Generic user changeset

  ## Examples

      iex> changeset(%User{}, %{email: user@example.com})
      #Ecto.Changeset<action: nil, changes: %{email: "email@example.com"},
      errors: [], data: #App.Accounts.User<>, valid?: true>

  """
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_required([:email])
    |> unique_constraint(:email)
  end

  @doc """
  User creation changeset

  ## Examples

      iex> changeset(%User{}, %{email: user@example.com, password: "password"})
      #Ecto.Changeset<action: nil, changes: %{email: "email@example.com"},
      errors: [], data: #App.Accounts.User<>, valid?: true>

  """
  def create_changeset(%User{} = user, attrs) do
    user
    |> changeset(attrs)
    |> cast(attrs, [:password])
    |> put_password_hash()
    |> validate_required([:password_hash])
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
