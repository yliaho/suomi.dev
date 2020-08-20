defmodule SuomidevWeb.UserView do
  use SuomidevWeb, :view

  def title("show.html", assigns) do
    assigns.user.username <> " -"
  end

  def title("edit.html", assigns) do
    "Käyttäjän " <> assigns.user.username <> " asetukset -"
  end

  def title(_template, _assigns) do
    nil
  end
end
