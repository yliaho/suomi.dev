defmodule SuomidevWeb.Helpers do
  def rate_limit_by_current_user(conn) do
    conn.assigns.current_user.id
  end
end
