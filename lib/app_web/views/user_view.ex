defmodule AppWeb.UserView do
  use AppWeb, :view
  use JaSerializer.PhoenixView
  alias AppWeb.UserView

  attributes [:email]
end
