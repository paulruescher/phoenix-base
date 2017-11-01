defmodule AppWeb.Router do
  use AppWeb, :router

  @doc """
  DEPRECATED
  Pipeline for HTML requests
  """
  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  @doc """
  Pipeline for json-api content-type
  """
  pipeline :api do
    plug JaSerializer.ContentTypeNegotiation
    plug JaSerializer.Deserializer
  end

  @doc """
  Pipeline for authorizing and loading the current user
  """
  pipeline :authorized do
    plug Guardian.Plug.Pipeline,
      module: App.Guardian,
      error_handler: App.Auth

    plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}
    plug Guardian.Plug.EnsureAuthenticated
    plug Guardian.Plug.LoadResource
  end

  scope "/", AppWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/api", AppWeb do
    pipe_through :api

    post "/login", SessionController, :create
    post "/password/forgot", PasswordController, :create
    post "/password/reset", PasswordController, :update

    scope "/" do
      resources "/users", UserController
    end
  end
end
