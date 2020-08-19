import Config

config :suomidev, SuomidevWeb.Endpoint,
  server: true,
  http: [port: {:system, "PORT"}], # Needed for Phoenix 1.2 and 1.4. Doesn't hurt for 1.3.
  url: [host: nil, port: 443]

config :suomidev, Suomidev.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: {:system, "DATABASE_URL"},
  database: "",
  ssl: true,
  pool_size: 9,
  types: Suomidev.PostgresTypes
