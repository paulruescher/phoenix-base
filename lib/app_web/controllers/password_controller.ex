defmodule AppWeb.PasswordController do
  use AppWeb, :controller
  alias Ecto.UUID
  alias App.Accounts
  alias App.Accounts.User
  alias App.Email
  alias App.Mailer

  def create(conn, %{"email" => email}) do
    case Accounts.get_by(%{email: email}) do
      %User{} = user ->
        {:ok, updated_user} =
          Accounts.update_user(user, %{password_reset_token: UUID.generate()})

        updated_user
        |> Email.password_reset()
        |> Mailer.deliver_now

        send_resp(conn, 204, "")
      _ ->
        send_resp(conn, 204, "")
    end
  end

  def update(conn, %{
    "password_reset_token" => password_reset_token,
    "password" => password
  }) do
    case Accounts.get_by(%{password_reset_token: password_reset_token}) do
      %User{} = user ->
        case Accounts.update_user(user, %{password: password}) do
          {:ok, %User{}} ->
            send_resp(conn, 204, "")
          {:error, _} ->
            send_resp(conn, 403, "")
        end
      _ ->
        send_resp(conn, 403, "")
    end
  end
end
