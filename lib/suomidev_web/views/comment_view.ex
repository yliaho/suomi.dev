defmodule SuomidevWeb.CommentView do
  use SuomidevWeb, :view

  def title("show.html", assigns) do
    "Käyttäjän " <> assigns.comment.user.username <> " kommentti -"
  end

  def title("edit.html", _assigns) do
    "Muokkaa kommenttia -"
  end

  def title(_template, _assigns) do
    nil
  end
end
