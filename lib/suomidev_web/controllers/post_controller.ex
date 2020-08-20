defmodule SuomidevWeb.PostController do
  use SuomidevWeb, :controller

  alias Suomidev.Submissions
  alias Suomidev.Submissions.Submission
  alias Suomidev.Accounts.User

  @pagination_limit 30

  plug Hammer.Plug,
       [
         rate_limit: {"post:write", 60_000 * 30, 10},
         by: {:conn, &SuomidevWeb.Helpers.rate_limit_by_current_user/1}
       ]
       when action in [:create, :update, :delete]

  def index(conn, %{"page" => page}) do
    IO.inspect(System.get_env("GITHUB_CLIENT_ID"))

    pagination =
      Submissions.paginate_posts(
        conn.assigns.current_user,
        limit: @pagination_limit,
        page: String.to_integer(page)
      )

    conn
    |> assign(:posts, pagination.results)
    |> assign(:has_more, pagination.has_more)
    |> assign(:next, pagination.next)
    |> assign(:prev, pagination.prev)
    |> render("index.html")
  end

  def index(conn, _params) do
    pagination =
      Submissions.paginate_posts(
        conn.assigns.current_user,
        limit: @pagination_limit,
        page: 1
      )

    conn
    |> assign(:posts, pagination.results)
    |> assign(:has_more, pagination.has_more)
    |> assign(:next, pagination.next)
    |> assign(:prev, pagination.prev)
    |> render("index.html")
  end

  def new(%{assigns: %{current_user: %User{}}} = conn, _params) do
    changeset = Submissions.change_submission(%Submission{})

    conn
    |> assign(:changeset, changeset)
    |> render("new.html")
  end

  def new(conn, _params) do
    conn
    |> put_flash(:error, "Sinun pitää olla kirjautunut sisään, jotta voit kirjoittaa posteja.")
    |> redirect(to: Routes.post_path(conn, :index))
  end

  def create(conn, %{"submission" => post_params}) do
    with :ok <-
           Bodyguard.permit(
             Submissions.Policy,
             :create_post,
             conn.assigns.current_user,
             post_params
           ),
         {:ok, post} <- Submissions.create_submission(post_params) do
      conn
      |> put_flash(:info, "Posti kirjoitettu onnistuneesti.")
      |> redirect(to: Routes.post_path(conn, :show, post))
    else
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)

      _ ->
        changeset = Submissions.change_submission(%Submission{})

        conn
        |> put_flash(
          :error,
          "Sinun pitää olla kirjautunut sisään, jotta voit kirjoittaa posteja."
        )
        |> redirect(to: Routes.post_path(conn, :new), changeset: changeset)
    end
  end

  def show(conn, %{"id" => id, "path" => path}) do
    post = Submissions.get_submission_as_current_user!(id, conn.assigns.current_user)
    comment_changeset = Submissions.change_submission(%Submission{})

    comments =
      Submissions.paginate_comments_for_post(path, conn.assigns.current_user,
        limit: @pagination_limit,
        page: 1
      )

    conn
    |> assign(:post, post)
    |> assign(:comment_changeset, comment_changeset)
    |> assign(:comments, comments.results)
    |> assign(:path, path)
    |> render("show.html")
  end

  def show(conn, %{"id" => id, "page" => page}) do
    post = Submissions.get_submission_as_current_user!(id, conn.assigns.current_user)

    pagination =
      Submissions.paginate_comments_for_post(id, conn.assigns.current_user,
        limit: @pagination_limit,
        page: String.to_integer(page)
      )

    comment_changeset = Submissions.change_submission(%Submission{})

    conn
    |> assign(:post, post)
    |> assign(:comments, pagination.results)
    |> assign(:has_more, pagination.has_more)
    |> assign(:next, pagination.next)
    |> assign(:prev, pagination.prev)
    |> assign(:comment_changeset, comment_changeset)
    |> render("show.html")
  end

  def show(conn, %{"id" => id}) do
    post = Submissions.get_submission_as_current_user!(id, conn.assigns.current_user)

    pagination =
      Submissions.paginate_comments_for_post(id, conn.assigns.current_user,
        limit: @pagination_limit,
        page: 1
      )

    comment_changeset = Submissions.change_submission(%Submission{})

    conn
    |> assign(:post, post)
    |> assign(:comments, pagination.results)
    |> assign(:has_more, pagination.has_more)
    |> assign(:next, pagination.next)
    |> assign(:prev, pagination.prev)
    |> assign(:comment_changeset, comment_changeset)
    |> render("show.html")
  end

  def edit(%{assigns: %{current_user: %User{}}} = conn, %{"id" => id}) do
    post = Submissions.get_submission!(id)
    changeset = Submissions.change_post_submission(post)

    conn
    |> assign(:update, true)
    |> assign(:post, post)
    |> assign(:changeset, changeset)
    |> render("edit.html")
  end

  def edit(conn, _params) do
    conn
    |> put_flash(:error, "Sinun pitää olla kirjautunut sisään jotta voit muokata posteja.")
    |> redirect(to: Routes.post_path(conn, :index))
  end

  def update(conn, %{"id" => id, "submission" => post_params}) do
    post = Submissions.get_submission!(id)

    with :ok <-
           Bodyguard.permit(
             Submissions.Policy,
             :update_post,
             conn.assigns.current_user,
             post_params
           ),
         {:ok, post} <- Submissions.update_post_submisison(post, post_params) do
      conn
      |> put_flash(:info, "Post updated successfully.")
      |> redirect(to: Routes.post_path(conn, :show, post))
    else
      {:error, changeset} ->
        render(conn, "edit.html", post: post, changeset: changeset)

      _ ->
        conn
        |> put_flash(:error, "Sinun pitää olla kirjautunut sisään, jotta voit muokata posteja.")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Submissions.get_submission!(id)

    with :ok <-
           Bodyguard.permit(Submissions.Policy, :delete_post, conn.assigns.current_user, post),
         {:ok, _post} <- Submissions.delete_submission(post) do
      conn
      |> put_flash(:info, "Posti poistettu onnistuneesti.")
      |> redirect(to: Routes.post_path(conn, :index))
    else
      _ ->
        conn
        |> put_flash(:error, "Postia ei pysty poistamaan.")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end
end
