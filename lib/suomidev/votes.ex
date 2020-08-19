defmodule Suomidev.Votes do
  import Ecto.Query, warn: false
  alias Suomidev.Repo

  alias Suomidev.Votes.Like
  alias Suomidev.Submissions

  defdelegate authorize(action, user, params), to: Suomidev.Votes.Policy

  def get_like_by(%{"user_id" => user_id, "submission_id" => submission_id}) do
    Repo.one(
      from like in Like,
        where: like.user_id == ^user_id and like.submission_id == ^submission_id
    )
  end

  def create_like(attrs \\ %{}) do
    case get_like_by(attrs) do
      nil ->
        res =
          %Like{}
          |> Like.changeset(attrs)
          |> Repo.insert(on_conflict: :nothing)

        Submissions.inc_cache_count(
          String.to_integer(attrs["submission_id"]),
          :cache_like_count,
          1
        )

        res

      like ->
        {:ok, like}
    end
  end

  def change_like(%Like{} = like, attrs \\ %{}) do
    Like.changeset(like, attrs)
  end

  def delete_like(%{"user_id" => user_id, "submission_id" => submission_id}) do
    case res =
           Repo.delete_all(
             from like in Like,
               where: like.user_id == ^user_id and like.submission_id == ^submission_id
           ) do
      {1, _} ->
        Submissions.inc_cache_count(String.to_integer(submission_id), :cache_like_count, -1)
        res

      _ ->
        nil
        res
    end
  end
end
