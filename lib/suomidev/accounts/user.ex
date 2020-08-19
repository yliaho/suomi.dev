defmodule Suomidev.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :username, :string
    field :email, :string
    field :provider, :string
    field :token, :string
    field :flag, :string
    field :prefers_color_scheme, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :provider, :token, :prefers_color_scheme])
    |> validate_required([:username, :email, :provider, :token])
  end
end
