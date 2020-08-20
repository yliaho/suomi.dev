defmodule SuomidevWeb.Plugs.MetaAttrs do
  use SuomidevWeb, :controller
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _params) do
    conn
    |> assign(:meta_attrs, [
      %{name: "title", content: "suomi.dev - suomalaista devausta"}
    ])
  end
end
