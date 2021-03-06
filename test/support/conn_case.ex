defmodule AppWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common datastructures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      import AppWeb.Router.Helpers

      # The default endpoint for testing
      @endpoint AppWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(App.Repo)
    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(App.Repo, {:shared, self()})
    end

    conn = Phoenix.ConnTest.build_conn()
    |> put_accept_header(tags[:json_api])

    {:ok, conn: conn}
  end

  defp put_accept_header(conn, nil), do: conn
  defp put_accept_header(conn, _) do
    conn
    |> Plug.Conn.put_req_header("accept", "application/vnd.api+json")
    |> Plug.Conn.put_req_header("content-type", "application/vnd.api+json")
  end
end
