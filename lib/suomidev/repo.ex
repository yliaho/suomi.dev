defmodule Suomidev.Repo do
  use Ecto.Repo,
    otp_app: :suomidev,
    adapter: Ecto.Adapters.Postgres

  Postgrex.Types.define(
    Suomidev.PostgresTypes,
    [EctoLtree.Postgrex.Lquery, EctoLtree.Postgrex.Ltree] ++ Ecto.Adapters.Postgres.extensions()
  )
end
