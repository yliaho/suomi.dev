defmodule Suomidev.Markdown do
  alias Earmark.Options

  @spec as_safe_html(binary()) :: binary()
  def as_safe_html(markdown) do
    case Earmark.as_html(markdown, %Options{smartypants: false}) do
      {:ok, html_doc, _} ->
        HtmlSanitizeEx.basic_html(html_doc)

      {:error, html_doc, _} ->
        HtmlSanitizeEx.basic_html(html_doc)
    end
  end
end
