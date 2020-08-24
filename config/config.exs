# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :ueberauth, Ueberauth,
  providers: [
    github:
      {Ueberauth.Strategy.Github,
       [
         default_scope: "read:user",
         allow_private_emails: true
       ]}
  ]

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: System.get_env("GITHUB_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET")

config :hammer,
  backend: {
    Hammer.Backend.ETS,
    [
      expiry_ms: 60_000 * 60 * 4,
      cleanup_interval_ms: 60_000 * 45
    ]
  }

config :suomidev,
  ecto_repos: [Suomidev.Repo]

# Configures the endpoint
config :suomidev, SuomidevWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Wmyw/+mtt0JizrLw2zXev1xoLbSNwRLyL7ih9QmB3H3T+sy4Plxg1CDmB3ijx1VE",
  render_errors: [view: SuomidevWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Suomidev.PubSub,
  live_view: [signing_salt: "cTg15NR6"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
