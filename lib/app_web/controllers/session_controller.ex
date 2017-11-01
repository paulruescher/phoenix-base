defmodule AppWeb.SessionController do
  use AppWeb, :controller
  alias App.Guardian.Plug
  alias App.Accounts

  action_fallback AppWeb.FallbackController

  def create(conn, params) do
    case Accounts.authenticate_user(params) do
      {:ok, user} ->
        conn_authed = Plug.sign_in(conn, user)
        jwt = Plug.current_token(conn_authed)

        conn_authed
        |> render("show.json-api", data: %{jwt: jwt, user: user})
      _ ->
        conn
        |> send_resp(403, "")
    end
  end
end
