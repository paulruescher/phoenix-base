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

    test "logs in chosen user", %{conn: conn} do
      conn = post conn, session_path(conn, :create), email: "some email", password: "password"

      json_response(conn, 200)["data"]["attributes"]["jwt"]
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
