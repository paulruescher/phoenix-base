defmodule AppWeb.PasswordControllerTest do
  use AppWeb.ConnCase
  use Bamboo.Test
  alias Ecto.UUID
  alias App.Accounts

  @moduletag :json_api

  @create_attrs %{
    email: "email@example.com",
    password: "password",
  }

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  describe "password reset flow" do
    setup [:create_user]

    test "send email if user does exist", %{conn: conn, user: user} do
      post conn, password_path(conn, :create),
        email: user.email

      assert_delivered_with(subject: "Password Reset")
    end

    test "does not send email if user does not exist", %{conn: conn} do
      post conn, password_path(conn, :create),
        email: "non-existent-email@example.com"

      assert_no_emails_delivered()
    end

    test "update user with new password", %{conn: conn, user: user} do
      password_reset_token = UUID.generate()
      Accounts.update_user(user, %{password_reset_token: password_reset_token})

      conn = post conn, password_path(conn, :update),
        password_reset_token: password_reset_token,
        password: "new password"

      assert response(conn, 204) == ""
    end

    test "do not update user with invalid password", %{conn: conn, user: user} do
      password_reset_token = UUID.generate()
      Accounts.update_user(user, %{password_reset_token: password_reset_token})

      conn = post conn, password_path(conn, :update),
        password_reset_token: password_reset_token,
        password: ""

      assert response(conn, 403) == ""
    end

    test "do not update user with invalid password_reset_token", %{conn: conn} do
      conn = post conn, password_path(conn, :update),
        password_reset_token: "",
        password: "new password"

      assert response(conn, 403) == ""
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
