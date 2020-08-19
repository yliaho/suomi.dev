defmodule Suomidev.Votes.Policy do
  @behaviour Bodyguard.Policy

  alias Suomidev.Accounts.User
  # alias Suomidev.Votes.Like

  def authorize(:create_like, %User{}, _), do: true

  def authorize(:delete_like, %User{}, _), do: true

  def authorize(_, _, _), do: false
end
