defmodule App.FacebookMock do
  def get_access_token(:success) do
    %{
      "access_token" => "ACCESS_TOKEN_MOCK",
      "expires_in" => 5183976,
      "token_type" => "bearer"
    }
  end

  def get_access_token(:failure) do
    %{
      "error" => "get_access_token_error"
    }
  end

  def get_email(:success) do
    {:json, %{
      "email" => "MOCK_USER@EMAIL.COM",
      "id" => "123"
    }}
  end

  def get_email(:failure) do
    {:json, %{
      "error" => "get_email_error"
    }}
  end
end
