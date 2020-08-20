defmodule Suomidev.Accounts.Policy do
  @behaviour Bodyguard.Policy

  alias Suomidev.Accounts.User

  def authorize(:update_user, %User{} = current_user, %User{} = user) do
    if current_user.id == user.id do
      true
    else
      false
    end
  end

  def authorize(_, _, _), do: false
end
