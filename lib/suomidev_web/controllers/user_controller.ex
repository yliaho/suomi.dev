defmodule SuomidevWeb.UserController do
  use SuomidevWeb, :controller

  alias Suomidev.Accounts
  alias Suomidev.Accounts.User
  alias Suomidev.Submissions

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    recent_posts = Submissions.list_user_submissions(:posts, user)
    recent_comments = Submissions.list_user_submissions(:comments, user)

    conn
    |> assign(:user, user)
    |> assign(:recent_posts, recent_posts)
    |> assign(:recent_comments, recent_comments)
    |> render("show.html")
  end

  def edit(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    if conn.assigns.current_user && conn.assigns.current_user.id &&
         conn.assigns.current_user.id == String.to_integer(id) do
      changeset = Accounts.change_user(user)
      render(conn, "edit.html", user: user, changeset: changeset)
    else
      conn
      |> put_flash(:error, "Et voi muokata toisten käyttäjäprofiileja")
      |> redirect(to: Routes.user_path(conn, :show, user))
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    {:ok, _user} = Accounts.delete_user(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: Routes.user_path(conn, :index))
  end
end
