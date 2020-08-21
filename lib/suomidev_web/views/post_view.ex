defmodule SuomidevWeb.PostView do
  use SuomidevWeb, :view

  def head("show.html", assigns) do
    description = if assigns.post.content_html, do:
      HtmlSanitizeEx.strip_tags(assigns.post.content_html) |> String.slice(0..155), else: assigns.post.title


    create_head(
      title: "#{assigns.post.title} - suomi.dev",
      description: description
    )
  end

  def head("new.html", _assigns) do
    create_head(
      title: "Kirjoita uusi postaus - suomi.dev",
      description: "Kirjoita uusi postaus suomi.dev keskustelupalstalle."
    )
  end

  def head("edit.html", _assigns) do
    create_head(
      title: "Muokkaa kommenttia - suomi.dev",
      description: "Muokkaa kommenttia."
    )
  end

  def head(_, _), do: create_head()
end
