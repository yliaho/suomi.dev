defmodule SuomidevWeb.PageController do
  use SuomidevWeb, :controller

  def index(conn, _params) do
    conn
    |> redirect(to: Routes.post_path(conn, :index))
  end

  def signup(conn, _params) do
    conn
    |> render("signup.html")
  end
end
