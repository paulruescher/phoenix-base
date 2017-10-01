defmodule App.Mixfile do
  use Mix.Project

  def project do
    [
      app: :app,
      version: "0.0.1",
      elixir: "~> 1.5",

      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      elixirc_paths: elixirc_paths(Mix.env),
      preferred_cli_env: [espec: :test],

      start_permanent: Mix.env == :prod,

      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {App.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:httpoison, "~> 0.13"},
      {:ja_serializer, "~> 0.12.0"},
      {:apex,        "~> 0.7"},

      # Auth
      {:facebook, "~> 0.9"},
      {:extwitter, "~> 0.8"},
      {:oauth2, "~> 0.9"},
      {:guardian, "~> 1.0-beta"},
      {:comeonin, "~> 4.0"},
      {:bcrypt_elixir, "~> 0.12"},

      # Quality
      {:credo,    "~> 0.8", only: [:dev, :test]},

      # Testing
      {:espec,         "~> 1.2", only: :test},
      {:espec_phoenix, "~> 0.6", only: :test},
      {:espec_phoenix_helpers, "~> 0.3", only: :test},

      {:mix_test_watch, "~> 0.3", only: :dev, runtime: false},
      {:ex_machina,  "~> 2.0"},
      {:faker, "~> 0.7"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.seed": "run priv/repo/seeds.exs",
      "ecto.setup": [
        "ecto.create",
        "ecto.migrate",
        "ecto.seed"
      ],
      "ecto.reset": [
        "ecto.drop",
        "ecto.setup"
      ],
      "test": [
        "ecto.create --quiet",
        "ecto.migrate",
        "test"
      ],
      "quality": [
        "test",
        "espec --exclude=context_tag:external_services",
        "credo --strict"
      ]
    ]
  end
end
