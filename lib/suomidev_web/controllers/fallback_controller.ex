defmodule SuomidevWeb.FallbackController do
  use SuomidevWeb, :controller

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_flash(:error, "Et ole kirjautunut sisään.")
    |> redirect(to: Routes.page_path(conn, :signup))
  end

  def call(conn, _params) do
    conn
    |> put_flash(:error, "Jotain meni pieleen.")
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
