defmodule App.Guardian do
  @moduledoc """
  Serializes and deserializes resources
  """
  use Guardian, otp_app: :app

  alias App.Accounts

  def subject_for_token(%{id: id}, _claims) do
    {:ok, "User:#{id}"}
  end

  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  def resource_from_claims(%{"sub" => "User:" <> sub}) do
    {:ok, Accounts.get_user!(sub)}
  end

  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end
end
