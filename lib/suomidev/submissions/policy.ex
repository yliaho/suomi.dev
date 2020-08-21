defmodule Suomidev.Submissions.Policy do
  @behaviour Bodyguard.Policy

  alias Suomidev.Accounts.User

  def authorize(:create, %User{}, _params) do
    true
  end

  def authorize(:update, %User{id: current_user_id}, %{"submission" => %{"user_id" => post_user_id}}) do
    if current_user_id == String.to_integer(post_user_id) do
      true
    else
      false
    end
  end

  def authorize(:delete, %User{id: current_user_id}, %{"submission" => %{"user_id" => post_user_id}}) do
    if current_user_id == String.to_integer(post_user_id) do
      true
    else
      false
    end
  end

  def authorize(_, _, _), do: false
end
