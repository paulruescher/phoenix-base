defmodule App.Auth do
  @moduledoc """
  Generic authentication error handler
  """
  import Plug.Conn

  @doc """
  Callback for `plug Guardian.Plug.Pipeline`
  """
  def auth_error(conn, {type, _reason}, _opts) do
    body = Poison.encode!(%{message: to_string(type)})
    send_resp(conn, 401, body)
  end
end
