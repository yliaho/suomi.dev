defmodule Suomidev.Submissions.Policy do
  @behaviour Bodyguard.Policy

  alias Suomidev.Accounts.User

  def authorize(:create_post, %User{}, _params) do
    true
  end

  def authorize(:update_post, %User{id: current_user_id}, %{"user_id" => post_user_id}) do
    if current_user_id == String.to_integer(post_user_id) do
      true
    else
      false
    end
  end

  def authorize(:delete_post, %User{id: current_user_id}, %{"user_id" => post_user_id}) do
    if current_user_id == String.to_integer(post_user_id) do
      true
    else
      false
    end
  end

  def authorize(:create_comment, %User{}, _params) do
    true
  end

  def authorize(:update_comment, %User{id: current_user_id}, %{"user_id" => comment_user_id}) do
    if current_user_id == String.to_integer(comment_user_id) do
      true
    else
      false
    end
  end

  def authorize(:delete_comment, %User{id: current_user_id}, %{"user_id" => comment_user_id}) do
    if current_user_id == String.to_integer(comment_user_id) do
      true
    else
      false
    end
  end

  def authorize(_, _, _), do: false
end
