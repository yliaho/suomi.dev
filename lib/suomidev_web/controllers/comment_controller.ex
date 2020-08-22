defmodule SuomidevWeb.CommentController do
  use SuomidevWeb, :controller

  alias Suomidev.Submissions
  alias Suomidev.Submissions.Submission
  alias Suomidev.Accounts.User
  alias SuomidevWeb.Helpers

  plug Hammer.Plug,
       [
         rate_limit: {"comment:write", 60_000 * 30, 10},
         by: {:session, :current_user, &Helpers.get_user_id/1}
       ]
       when action in [:create, :update, :delete, :edit]

  plug Bodyguard.Plug.Authorize,
       [
         policy: Submissions,
         action: &action_name/1,
         user: {SuomidevWeb.Plugs.Session, :get_current_user},
         params: {__MODULE__, :get_params},
         fallback: SuomidevWeb.FallbackController
       ]
       when action in [:create, :update, :delete, :edit]

  def index(conn, _params) do
    comments = Submissions.list_submissions()
    render(conn, "index.html", comments: comments)
  end

  def new(%{assigns: %{current_user: %User{}}} = conn, _params) do
    changeset = Submissions.change_submission(%Submission{})
    render(conn, "new.html", changeset: changeset)
  end

  def new(conn, _params) do
    conn
    |> put_flash(
      :error,
      "Sinun pitää olla kirjautunut sisään, jotta voit kirjoittaa kommentteja."
    )
    |> redirect(to: Routes.page_path(conn, :index))
  end

  def create(
        conn,
        %{
          "submission" => comment_params,
          "parent_id" => parent_id,
          "root_id" => root_id
        }
      ) do
    post =
      Submissions.get_submission_as_current_user!(
        root_id,
        conn.assigns.current_user
      )

    comments =
      Submissions.paginate_comments_for_post(
        root_id,
        conn.assigns.current_user
      )

    comment_changeset = Submissions.change_submission(%Submission{})

    case Submissions.create_submission(parent_id, comment_params) do
      {:ok, _comment} ->
        conn
        |> put_flash(:info, "Kommentti kirjoitettu onnistuneesti.")
        |> assign(:post, post)
        |> assign(:comments, comments)
        |> assign(:comment_changeset, comment_changeset)
        |> redirect(to: Routes.post_path(conn, :show, post))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Kommenttia ei pysty kirjoittamaan!")
        |> assign(:post, post)
        |> assign(:comments, comments)
        |> assign(:comment_changeset, changeset)
        |> redirect(to: Routes.post_path(conn, :show, post))
    end
  end

  def show(conn, %{"id" => id}) do
    comment =
      Submissions.get_submission_as_current_user!(
        id,
        conn.assigns.current_user
      )

    reply_changeset = Submissions.change_submission(%Submission{})

    post =
      List.first(comment.path.labels)
      |> Submissions.get_submission_as_current_user!(conn.assigns.current_user)

    conn
    |> assign(:comment, comment)
    |> assign(:post, post)
    |> assign(:reply_changeset, reply_changeset)
    |> render("show.html")
  end

  def edit(%{assigns: %{current_user: %User{}}} = conn, %{"id" => id}) do
    comment = Submissions.get_submission!(id)
    changeset = Submissions.change_submission(comment)
    render(conn, "edit.html", comment: comment, changeset: changeset)
  end

  def edit(conn, %{"id" => id}) do
    comment = Submissions.get_submission!(id)

    conn
    |> put_flash(:error, "Sinun pitää olla kirjautunut sisään, jotta voit muokata kommentteja.")
    |> redirect(to: Routes.comment_path(conn, :show, comment))
  end

  def update(conn, %{"id" => id, "submission" => comment_params}) do
    comment = Submissions.get_submission!(id)

    case Submissions.update_submission(comment, comment_params) do
      {:ok, comment} ->
        conn
        |> put_flash(:info, "Kommentti muokattu onnistuneesti.")
        |> redirect(to: Routes.comment_path(conn, :show, comment))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", comment: comment, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    comment = Submissions.get_submission!(id)

    case Submissions.delete_submission(comment) do
      {:ok, _comment} ->
        conn
        |> put_flash(:info, "Kommentti poistettu onnistuneesti.")
        |> redirect(to: Routes.page_path(conn, :index))

      _ ->
        conn
        |> put_flash(:error, "Kommenttia ei pysty poistamaan.")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  def get_params(conn) do
    conn.params
  end
end
