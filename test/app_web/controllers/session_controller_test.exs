defmodule AppWeb.SessionControllerTest do
  use AppWeb.ConnCase, json_api: true
  alias App.Accounts

  @moduletag :json_api

  @create_attrs %{email: "some email", password: "password"}

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  describe "create session" do
    setup [:create_user]

    test "does log in user with valid credentials", %{conn: conn} do
      conn = post conn, session_path(conn, :create),
        email: "some email",
        password: "password"

      assert json_response(conn, 200)["data"]["attributes"]["jwt"]
    end

    test "does not log in user with invalid credentials", %{conn: conn} do
      conn = post conn, session_path(conn, :create),
        email: "some email",
        password: "incorrect_password"

      assert response(conn, 403) == ""
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
