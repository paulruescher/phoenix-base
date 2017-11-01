defmodule App.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Comeonin.Bcrypt
  alias App.Repo
  alias App.Accounts.User
  alias App.Auth.Facebook

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user by clause

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_by(email: "existing.user@email.com")
      %User{}

      iex> get_by(email: "non.existent.user@email.com")
      nil

  """
  def get_by(clauses), do: Repo.get_by(User, clauses)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{email: email, access_token: access_token})
      {:ok, %User{}}

      iex> create_user(%{email: email, password: password})
      {:ok, %User{}}

      iex> create_user(%{})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{})
  def create_user(%{email: _, access_token: _} = attrs) do
    %User{}
    |> User.facebook_changeset(attrs)
    |> Repo.insert()
  end

  def create_user(attrs) do
    %User{}
    |> User.password_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a users password.

  Use this specific function to abstract away the necessity of knowing which
  changeset to use.

  ## Examples

      iex> update_user(user, :password, new_value)
      {:ok, %User{}}

      iex> update_user(user, :password, invalid_value)
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, %{password: _} = attrs) do
    user
    |> User.password_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a users password reset token.

  Use this specific function to abstract away the necessity of knowing which
  changeset to use.

  ## Examples

      iex> update_user(user, %{password_reset_token: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{password_reset_token: invalid_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, %{password_reset_token: _} = attrs) do
    user
    |> User.password_reset_changeset(attrs)
    |> Repo.update()
  end

  def update_user(%User{} = user, %{access_token: _} = attrs) do
    user
    |> User.facebook_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  General update user function

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(user, attrs) do
    update_user(user, attrs, &User.changeset/2)
  end

  @doc """
  Updates a user with a given changeset

  ## Examples

      iex> update_user(user, %{field: new_value}, changeset)
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value}, changeset)
      {:error, %Ecto.Changeset{}}

  """
  def update_user(user, attrs, changeset) do
    user
    |> changeset.(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  def get_and_update_or_create_user({:ok, %{
    "email" => email,
    "access_token" => access_token
  }}) do
    case get_by(%{email: email}) do
      user = %User{} -> update_user(user, %{access_token: access_token})

      _ -> create_user(%{"email": email, "access_token": access_token})
    end
  end
  def get_and_update_or_create_user({:error, opts}), do: {:error, opts}

  @doc """
  Authenticate a user.

  See https://developers.facebook.com/docs/facebook-login/access-tokens for
  the proper facebook authentication flow.

  ## Examples

      iex> authenticate_user(%{
        "provider" => "facebook",
        "code" => code
      })
      {:ok, %User{}}

      iex> authenticate_user(%{
        "email" => valid_email,
        "password" => correct_password
      })
      {:ok, %User{}}

      iex> authenticate_user("example@email.com", "incorrect_password")
      {:error, :incorrect_password}

  """
  def authenticate_user(%{"provider" => "facebook"} = params) do
    params
    |> Facebook.get_access_token_by_code
    |> Facebook.get_email_by_access_token
    |> get_and_update_or_create_user
  end

  def authenticate_user(%{"email" => email, "password" => password}) do
    with user = %User{} <- get_by(%{email: email}),
         {:ok} <- verify_password(password, user.password_hash),
    do: {:ok, user}
  end

  defp verify_password(password, password_hash) do
    case Bcrypt.checkpw(password, password_hash) do
      true ->
        {:ok}
      false ->
        {:error, :incorrect_password}
    end
  end
end
