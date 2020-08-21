defmodule SuomidevWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use SuomidevWeb, :controller
      use SuomidevWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: SuomidevWeb

      import Plug.Conn
      import SuomidevWeb.Gettext
      alias SuomidevWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/suomidev_web/templates",
        namespace: SuomidevWeb

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      def create_head(opts \\ [title: "suomi.dev", description: "Devausta suomalaisittain. Liity mukaan keskusteluun!"]) do
        %{
          title: String.trim(opts[:title]),
          meta: [
            # Standard
            %{name: "description", content: String.trim(opts[:description])},

            # Open Graph
            %{name: "og:title", content: String.trim(opts[:title])},
            %{name: "og:description", content: String.trim(opts[:description])},
            %{name: "og:site_name", content: "suomi.dev"},
            %{name: "og:locale", content: "fi_FI"},

            # Twitter
            %{name: "twitter:card", content: "summary"},
            %{name: "twitter:creator", content: "@Yliaho_"},
            %{name: "twitter:title", content: String.trim(opts[:title])},
            %{name: "twitter:description", content: String.trim(opts[:description])}
          ]
        }
      end

      # Include shared imports and aliases for views
      unquote(view_helpers())
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import SuomidevWeb.Gettext
    end
  end

  defp view_helpers do
    quote do
      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View

      import SuomidevWeb.ErrorHelpers
      import SuomidevWeb.Gettext
      alias SuomidevWeb.Router.Helpers, as: Routes
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
