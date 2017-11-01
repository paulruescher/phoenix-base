defmodule App.AccountsTest do
  use App.DataCase
  alias Ecto.UUID
  alias App.Accounts
  alias App.Accounts.User
  import Mock

  @valid_create_attrs %{email: "email@example.com", password: "password"}
  @update_attrs %{email: "updated_email@example.com"}
  @invalid_attrs %{email: nil}

  def user_attrs(attrs \\ %{}) do
    attrs
    |> Enum.into(@valid_create_attrs)
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> user_attrs
      |> Accounts.create_user()

    Map.put(user, :password, nil)
  end

  describe "users" do
    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Accounts.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.email == "updated_email@example.com"
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

    test "update_user(user, %{password_reset_token: _})/2 with valid data returns user" do
      user = user_fixture()
      token = UUID.generate()
      assert {:ok, %User{} = updated_user} =
        Accounts.update_user(user, %{password_reset_token: token})
      assert updated_user.password_reset_token == token
    end

    test "update_user(user, %{password_reset_token: _})/2 with invalid data returns error" do
      user = user_fixture()
      assert {:error, changeset} = Accounts.update_user(user, %{
        "password_reset_token": ""
      })
      assert changeset.valid? == false
    end

    test "update_user(user, %{password: _})/2 with valid data updates password" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.update_user(user, %{
        "password" => "new_password"
      })
    end

    test "update_user(user, %{password: _})/2 with invalid data returns error" do
      user = user_fixture()
      assert {:error, changeset} = Accounts.update_user(user, %{password: ""})
      assert changeset.valid? == false
    end

    test "update_user(user, %{password: _})/2 resets password_reset_token" do
      user = user_fixture()
      token = UUID.generate()
      {:ok, user} =
        Accounts.update_user(user, %{password_reset_token: token})
        |> elem(1)
        |> Accounts.update_user(%{password: "new_password"})

      assert user.password_reset_token == nil
    end
  end

  describe "create user" do
    test "create_user/1 with valid email/password creates a user" do
      assert {:ok, %User{} = user} =
        Accounts.create_user(@valid_create_attrs)
      assert user.email == "email@example.com"
    end

    test "create_user/1 must be passed a valid email (required)" do
      assert {:error, %Ecto.Changeset{} = changeset} =
        Map.put(%{}, :email, "")
        |> user_attrs()
        |> Accounts.create_user()
       assert {"can't be blank", _} = changeset.errors[:email]
    end

    test "create_user/1 must be passed a valid email (format)" do
      assert {:error, %Ecto.Changeset{} = changeset} =
        Map.put(%{}, :email, "example.com")
        |> user_attrs()
        |> Accounts.create_user()
      assert {"has invalid format", _} = changeset.errors[:email]
    end

    test "create_user/1 must be passed a valid password (required)" do
      assert {:error, %Ecto.Changeset{} = changeset} =
        Map.put(%{}, :password, "")
        |> user_attrs()
        |> Accounts.create_user()
       assert {"can't be blank", _} = changeset.errors[:password]
    end

    test "create_user/1 must be passed a valid password (min length)" do
      assert {:error, %Ecto.Changeset{} = changeset} =
        Map.put(%{}, :password, "1234")
        |> user_attrs()
        |> Accounts.create_user()
       assert {_, [_, _, min: 5]} = changeset.errors[:password]
    end

    test "create_user/1 with valid facebook data creates a user" do
      access_token = UUID.generate()
      assert {:ok, %User{} = user} =
        Map.put(%{}, :access_token, access_token)
        |> user_attrs()
        |> Accounts.create_user()
      assert user.email == "email@example.com"
      assert user.access_token == access_token
    end

    test "create_user/1 must be passed an access_token (fb auth))" do
      assert {:error, %Ecto.Changeset{} = changeset} =
        Map.put(%{}, :access_token, "")
        |> user_attrs()
        |> Accounts.create_user()
       assert {"can't be blank", _} = changeset.errors[:access_token]
    end

    test "get_and_update_or_create_user updates existing users access_token" do
      %User{email: email} = user_fixture()
      assert {:ok, opts} = Accounts.get_and_update_or_create_user({:ok, %{
        "email" => email,
        "access_token" => "ACCESS_TOKEN"
      }})
      assert Map.get(opts, :access_token) == "ACCESS_TOKEN"
    end

    test "get_and_update_or_create_user can create user" do
      assert {:ok, opts} = Accounts.get_and_update_or_create_user({:ok, %{
        "email" => "MOCK@EMAIL.COM",
        "access_token" => "ACCESS_TOKEN"}
      })
      assert %{email: "MOCK@EMAIL.COM"} = opts
      assert %{access_token: "ACCESS_TOKEN"} = opts
    end

    test "get_and_update_or_create_user passes along error" do
      error = {:error, "error message"}
      assert  error == Accounts.get_and_update_or_create_user(error)
    end
  end

  describe "authentication" do
    test "authenticate_user/1 with valid email/pass logins returns user" do
      user = user_fixture()
      assert {:ok, %User{}} =
        Accounts.authenticate_user(%{
          "email" => user.email,
          "password" => "password"
        })
    end

    test "authenticate_user/1 with invalid logins returns error" do
      user = user_fixture()
      assert {:error, :incorrect_password} ==
        Accounts.authenticate_user(%{
          "email" => user.email,
          "password" => "wrong_password"
        })
    end

    test "authenticate_user/1 with valid email/access_token logins returns user" do
      with_mock Facebook, [
        accessToken: fn(_, _, _, _) ->
          App.FacebookMock.get_access_token(:success)
        end,
        me: fn(_, _) ->
          App.FacebookMock.get_email(:success)
        end
      ] do
        assert {:ok, %User{}} =
          Accounts.authenticate_user(%{
            "provider" => "facebook",
            "code" => "123456"
          })
      end
    end

    test "authenticate_user/1 with existing email logins returns user" do
      user = user_fixture(%{email: "MOCK_USER@EMAIL.COM"})
      with_mock Facebook, [
        accessToken: fn(_, _, _, _) ->
          App.FacebookMock.get_access_token(:success)
        end,
        me: fn(_, _) ->
          App.FacebookMock.get_email(:success)
        end
      ] do
        assert user.access_token == nil
        assert {:ok, user = %User{}} =
          Accounts.authenticate_user(%{
            "provider" => "facebook",
            "code" => "123456"
          })
        assert user.access_token == "ACCESS_TOKEN_MOCK"
      end
    end

    test "authenticate_user/1 with invalid data returns error" do
      with_mock Facebook, [
        accessToken: fn(_, _, _, _) ->
          App.FacebookMock.get_access_token(:failure)
        end,
        me: fn(_, _) ->
          App.FacebookMock.get_email(:failure)
        end
      ] do
        assert {:error, _} =
          Accounts.authenticate_user(%{
            "provider" => "facebook",
            "code" => "123456"
          })
      end
    end
  end
end
