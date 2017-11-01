defmodule AppWeb.SessionControllerTest do
  use AppWeb.ConnCase, json_api: true
  alias App.Accounts
  alias Ecto.UUID
  import Mock

  @moduletag :json_api

  @create_attrs %{email: "email@example.com", password: "password"}

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  describe "create session" do
    setup [:create_user]

    test "does log in user with valid credentials", %{conn: conn} do
      conn = post conn, session_path(conn, :create),
        email: "email@example.com",
        password: "password"

      assert json_response(conn, 200)["data"]["attributes"]["jwt"]
    end

    test "does not log in user with invalid credentials", %{conn: conn} do
      conn = post conn, session_path(conn, :create),
        email: "email@example.com",
        password: "incorrect_password"

      assert response(conn, 403) == ""
    end

    test "creates and logs in non-existent fb login", %{conn: conn} do
      with_mock Facebook, [accessToken: fn(_, _, _, _) ->
        App.FacebookMock.get_access_token(:success)
      end, me: fn(_, _) ->
        App.FacebookMock.get_email(:success)
      end] do
        conn = post conn, session_path(conn, :create),
          code: UUID.generate(),
          provider: "facebook"

        assert json_response(conn, 200)["data"]["attributes"]["jwt"]
      end
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
