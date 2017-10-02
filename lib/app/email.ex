defmodule App.Email do
  @moduledoc """
  Email template functions
  """
  import Bamboo.Email

  def password_reset(user) do
    base_email()
    |> to(user.email)
    |> subject("Password Reset")
    |> html_body("<strong>Welcome</strong>")
    |> text_body("Welcome")
  end

  defp base_email do
    new_email()
    |> from("myapp@example.com")
  end
end
