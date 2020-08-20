defmodule SuomidevWeb.PostView do
  use SuomidevWeb, :view

  def title("show.html", assigns) do
    assigns.post.title <> " -"
  end

  def title("new.html", _assigns) do
    "Kirjoita uusi postaus -"
  end

  def title("edit.html", _assigns) do
    "Muokkaa kommenttia -"
  end

  def title(_template, _assigns) do
    nil
  end
end
