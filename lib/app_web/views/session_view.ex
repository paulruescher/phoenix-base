defmodule AppWeb.SessionView do
  use AppWeb, :view
  use JaSerializer.PhoenixView

  attributes [:jwt]

  def id(%{jwt: jwt}, _conn), do: jwt

  has_one :user,
    serializer: AppWeb.UserView
end
