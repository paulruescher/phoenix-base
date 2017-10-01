defmodule AppWeb.SessionController do
  use AppWeb, :controller
  alias App.Guardian.Plug
  alias App.Accounts

  action_fallback AppWeb.FallbackController

  def create(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        conn_authed = Plug.sign_in(conn, user)
        jwt = Plug.current_token(conn_authed)

        conn_authed
        |> render("show.json-api", data: %{jwt: jwt, user: user})
      {:error, _} ->
        conn
        |> send_resp(401, "")
    end
  end
end
