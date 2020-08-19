defmodule Suomidev.Submissions do
  @moduledoc """
  The Submissions context.
  """

  import Ecto.Query, warn: false
  alias Suomidev.Repo
  alias Suomidev.Accounts.User

  alias Suomidev.Submissions.Submission

  @pagination_limit 2

  defdelegate authorize(action, user, params), to: Suomidev.Submissions.Policy

  def list_submissions do
    Repo.all(Submission)
  end

  def list_user_submissions(:posts, %User{id: user_id}) do
    Repo.all(
      from submission in Submission,
        where: submission.user_id == ^user_id and submission.type == "post",
        limit: 5,
        order_by: submission.inserted_at
    )
    |> Repo.preload(:user)
  end

  def list_user_submissions(:comments, %User{id: user_id}) do
    Repo.all(
      from submission in Submission,
        where: submission.user_id == ^user_id and submission.type == "comment",
        limit: 5,
        order_by: submission.inserted_at
    )
    |> Repo.preload(:user)
  end

  def available_submissions do
    from submission in Submission,
      where: is_nil(submission.flag)
  end

  def available_posts() do
    from submission in subquery(available_submissions()),
      where: submission.type == "post"
  end

  def available_comments() do
    from submission in subquery(available_submissions()),
      where: submission.type == "comment"
  end

  def submission_type_as_current_user(user_id, submission_type) do
    query = fn ->
      case submission_type do
        "post" ->
          available_posts()

        "comment" ->
          available_comments()

        "all" ->
          available_submissions()
      end
    end

    from submission in subquery(query.()),
      left_join: like in assoc(submission, :likes),
      on: like.user_id == ^user_id,
      select:
        merge(submission, %{
          current_user_liked: fragment("CASE WHEN ? IS NOT NULL THEN true ELSE false END", like)
        })
  end

  def list_posts do
    Repo.all(from(submission in subquery(available_posts())))
  end

  def paginate_posts(current_user, opts) do
    limit = (opts[:limit] || @pagination_limit) + 1
    offset = limit * (opts[:page] - 1)
    current_user_id = if current_user, do: current_user.id, else: -1

    results =
      Repo.all(
        from submission in subquery(submission_type_as_current_user(current_user_id, "post")),
          order_by:
            fragment(
              """
                (COALESCE(?, 0) + 1) / POW(((EXTRACT(EPOCH FROM NOW()) - EXTRACT(EPOCH FROM ?)) / 3600) + 2, 1.8) DESC
              """,
              submission.cache_like_count,
              submission.inserted_at
            ),
          preload: [:user],
          limit: ^limit,
          offset: ^offset
      )

    %{
      results: results,
      has_more: length(results) > opts[:limit],
      next: opts[:page] + 1,
      prev: opts[:page] - 1
    }
  end

  def get_submission!(id), do: Repo.get!(Submission, id) |> Repo.preload(:user)

  def get_submission(id), do: Repo.get(Submission, id)

  def get_submission_as_current_user!(id, %User{} = user) do
    Repo.one!(
      from submission in subquery(submission_type_as_current_user(user.id, "all")),
        where: submission.id == ^id,
        preload: [:user]
    )
  end

  def get_submission_as_current_user!(id, nil) do
    get_submission!(id)
  end

  def paginate_comments_for_post(post_id, user, opts \\ [limit: 5, page: 1]) do
    limit = (opts[:limit] || @pagination_limit) + 1
    offset = limit * (opts[:page] - 1)

    depth = String.split(post_id, ".") |> length()
    max_depth = depth + 6
    user_id = if user, do: user.id, else: -1

    results =
      Repo.all(
        from comment in Submission,
          left_join: like in assoc(comment, :likes),
          on: like.user_id == ^user_id,
          where:
            fragment("? <@ text2ltree(?)", comment.path, ^post_id) and
              fragment(
                "nlevel(?) <= ?",
                comment.path,
                ^max_depth
              ),
          preload: [:user],
          order_by:
            fragment(
              """
                nlevel(?),
                (COALESCE(?, 0) + 1) / POW(((EXTRACT(EPOCH FROM NOW()) - EXTRACT(EPOCH FROM ?)) / 3600) + 2, 1.8) DESC
              """,
              comment.path,
              comment.cache_like_count,
              comment.inserted_at
            ),
          limit: ^limit,
          offset: ^offset,
          select:
            merge(comment, %{
              current_user_liked:
                fragment("CASE WHEN ? IS NOT NULL THEN true ELSE false END", like),
              score:
                fragment(
                  """
                  (COALESCE(?, 0) + 1) / POW(((EXTRACT(EPOCH FROM NOW()) - EXTRACT(EPOCH FROM ?)) / 3600) + 2, 1.8)
                  """,
                  comment.cache_like_count,
                  comment.inserted_at
                ),
              more_comment:
                fragment(
                  """
                    (SELECT
                      COUNT(*)
                    FROM
                      submissions child
                    WHERE
                      ? = child.parent_id)
                  """,
                  comment.id
                )
            })
      )
      |> gen_comment_tree(String.split(post_id, ".") |> List.last() |> String.to_integer())

    %{
      results: results,
      has_more: length(results) > opts[:limit],
      next: opts[:page] + 1,
      prev: opts[:page] - 1
    }
  end

  @doc """
  Creates post submission
  """
  def create_submission(attrs) do
    IO.write("POST")

    %Submission{}
    |> Submission.changeset(
      Map.put(
        attrs,
        "content_html",
        Suomidev.Markdown.as_safe_html(attrs["content_md"])
      )
    )
    |> Repo.insert()
  end

  @doc """
  Creates comment submission
  """
  def create_submission(parent_id, attrs) do
    IO.write("COMMENT")

    if parent = get_submission(parent_id) do
      path = if parent.path, do: "#{parent.path}.#{parent.id}", else: "#{parent.id}"

      case %Submission{}
           |> Submission.changeset(
             Map.merge(attrs, %{
               "content_html" => Suomidev.Markdown.as_safe_html(attrs["content_md"] || ""),
               "path" => path,
               "parent_id" => parent_id
             })
           )
           |> Repo.insert() do
        {:ok, struct} ->
          spawn(fn ->
            inc_cache_count(struct.path.labels, :cache_comment_count, 1)
          end)

          {:ok, struct}

        {:error, changeset} ->
          {:error, changeset}
      end
    else
      IO.write("NO PARENT?")
      {:no_parent, "parent submissions is unavailable"}
    end
  end

  def update_submission(%Submission{} = submission, attrs) do
    submission
    |> Submission.changeset(
      Map.merge(attrs, %{
        "content_html" => Suomidev.Markdown.as_safe_html(attrs["content_md"] || "")
      })
    )
    |> Repo.update()
  end

  def delete_submission(%Submission{} = submission) do
    Repo.delete(submission)
  end

  def change_submission(%Submission{} = submission, attrs \\ %{}) do
    Submission.changeset(submission, attrs)
  end

  def gen_comment_tree(comments, parent_id \\ 0) do
    comments
    |> Enum.sort(&(&1.score >= &2.score))
    |> Enum.filter(fn comment ->
      String.to_integer(List.last(comment.path.labels)) == parent_id
    end)
    |> Enum.map(fn comment ->
      comment
      |> Map.merge(%{
        children: gen_comment_tree(comments, comment.id)
      })
    end)
  end

  def inc_cache_count(id, :cache_like_count, value) do
    Repo.update_all(
      from(submission in Submission,
        where: submission.id == ^id
      ),
      inc: [cache_like_count: value]
    )
  end

  def inc_cache_count(path_labels, :cache_comment_count, value) do
    post_id = List.first(path_labels)
    parent_id = if post_id == List.last(path_labels), do: "-1", else: List.last(path_labels)

    Repo.update_all(
      from(submission in Submission,
        where: submission.id == ^post_id or submission.id == ^parent_id
      ),
      inc: [cache_comment_count: value]
    )
  end
end
