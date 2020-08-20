defmodule SuomidevWeb.PageView do
  use SuomidevWeb, :view

  def title("signup.html", _assigns) do
    "Liity mukaan -"
  end

  def title(_template, _assigns) do
    nil
  end
end
