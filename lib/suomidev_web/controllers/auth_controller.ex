defmodule SuomidevWeb.AuthController do
  use SuomidevWeb, :controller
  alias Ueberauth.Strategy.Helpers
  alias Suomidev.Accounts

  plug(Ueberauth)

  def request(conn, _params) do
    render(conn, "request.html", callback_url: Helpers.callback_url(conn))
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Olet kirjautunut ulos.")
    |> clear_session()
    |> redirect(to: Routes.page_path(conn, :index))
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Virhe tapahtui kirjautuessa sisään.")
    |> redirect(to: Routes.page_path(conn, :index))
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    attrs = %{
      email: auth.info.email,
      username: auth.info.nickname,
      provider: Atom.to_string(auth.provider),
      token: auth.credentials.token
    }

    case Accounts.get_or_create_user(attrs) do
      {:ok, struct} ->
        conn
        |> put_session(:current_user, struct)
        |> configure_session(renew: true)
        |> put_flash(:info, "Tervetuloa, #{struct.username}!")
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, _} ->
        conn
        |> put_flash(:error, "Virhe tapahtui kirjautuessa sisään.")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end
end
