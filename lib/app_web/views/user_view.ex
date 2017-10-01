defmodule AppWeb.UserView do
  use AppWeb, :view
  use JaSerializer.PhoenixView

  attributes [:email]
end
