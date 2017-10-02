# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :phoenix, :format_encoders,
  "json-api": Poison

config :mime, :types, %{
  "application/vnd.api+json" => ["json-api"]
}

config :app,
  ecto_repos: [App.Repo]

# Configures the endpoint
config :app, AppWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "t3kMCGYnD8oO4mdgJuDJAOv+P3v4kb8VwAx1vEK55mQf1kbhyBVPQpd1L8VEFD5k",
  render_errors: [view: AppWeb.ErrorView, accepts: ~w(html json json-api)],
  pubsub: [name: App.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :app, App.Guardian,
  issuer: "app",
  secret_key: "6v95qhiGFTmGcVPrNIizcrdYSKVeGArt7SSs/CJlL7ejQRKwMBe5nb88RQbZWvdN"

config :app, App.Mailer,
  adapter: Bamboo.TestAdapter

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
