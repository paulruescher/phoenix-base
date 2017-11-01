defmodule App.Auth.Facebook do
  @moduledoc """
  Provides an abstraction layer over the facebook.ex module
  """

  def get_access_token_by_code(%{"code" => code} = params) do
    case request_access_token(code) do
      %{"access_token" => access_token} ->
        {:ok, Map.put(params, "access_token", access_token)}

      _ ->
        {:error, {:unauthorized, %{code: ["Error with code"]}}}
    end
  end

  def get_email_by_access_token({:ok, %{"access_token" => token} = params}) do
    case request_email(token) do
      %{"email" => email} ->
        {:ok, Map.put(params, "email", email)}

      _ ->
        {:error, {:unauthorized, %{access_token: ["Error with access_token"]}}}
    end
  end
  def get_email_by_access_token({:error, opts}), do: {:error, opts}

  def authorize_url!() do
    Application.get_env(:facebook, :oauth_url)
    <> "?client_id=#{Application.get_env(:facebook, :appid)}"
    <> "&redirect_uri=#{Application.get_env(:facebook, :redirect_uri)}"
    <> "&scope=#{Application.get_env(:facebook, :scope)}"
  end

  defp request_access_token(code) do
    Facebook.accessToken(
      Application.get_env(:facebook, :appid),
      Application.get_env(:facebook, :secret),
      Application.get_env(:facebook, :redirect_uri),
      code
    )
  end

  defp request_email(access_token) do
    [fields: "email"]
    |> Facebook.me(access_token)
    |> elem(1)
  end
end
