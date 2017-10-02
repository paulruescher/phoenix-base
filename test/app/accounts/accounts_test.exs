defmodule App.AccountsTest do
  use App.DataCase
  alias Ecto.UUID
  alias App.Accounts

  describe "users" do
    alias App.Accounts.User

    @valid_create_attrs %{email: "some email", password: "password"}
    @update_attrs %{email: "some updated email"}
    @invalid_attrs %{email: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_create_attrs)
        |> Accounts.create_user()

      Map.put(user, :password, nil)
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_create_attrs)
      assert user.email == "some email"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Accounts.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.email == "some updated email"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end

    test "authenticate_user/1 with valid logins returns user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.authenticate_user(user.email, "password")
    end

    test "authenticate_user/1 with invalid logins returns error" do
      user = user_fixture()
      assert {:error, :incorrect_password} ==
        Accounts.authenticate_user(user.email, "wrong_password")
    end

    @tag :must_exec
    test "update_user_password_reset_token/2 with valid data returns user" do
      user = user_fixture()
      token = UUID.generate()

      assert {:ok, %User{} = updated_user} =
        Accounts.update_user_password_reset_token(user, token)
      assert updated_user.password_reset_token == token
    end

    test "update_user_password_reset_token/2 with invalid data returns error" do
      user = user_fixture()

      assert {:error, changeset} =
        Accounts.update_user_password_reset_token(user, "")
      assert changeset.valid? == false
    end

    test "update_user_password/2 with valid data updates password" do
      user = user_fixture()

      assert {:ok, user} = Accounts.update_user_password(user, "new_password")
      assert %User{} = user
      assert Accounts.verify_password("new_password", user.password_hash)
    end

    test "update_user_password/2 with invalid data returns error" do
      user = user_fixture()

      assert {:error, changeset} = Accounts.update_user_password(user, "")
      assert changeset.valid? == false
    end
  end
end
