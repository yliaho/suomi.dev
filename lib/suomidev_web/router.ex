defmodule SuomidevWeb.Router do
  use SuomidevWeb, :router
  require Ueberauth

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(SuomidevWeb.Plugs.Session)
    plug(SuomidevWeb.Plugs.MetaAttrs)
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:fetch_session)
    plug(SuomidevWeb.Plugs.Session)
  end

  scope "/", SuomidevWeb do
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/signup", PageController, :signup)
    resources("/users", UserController)
    resources("/posts", PostController)
    resources("/comments", CommentController)
  end

  scope "/api", SuomidevWeb do
    pipe_through(:api)

    post("/votes/:id", Api.VoteController, :vote_submission)
    delete("/votes/:id", Api.VoteController, :unvote_submission)
  end

  scope "/auth", SuomidevWeb do
    pipe_through(:browser)

    get("/:provider", AuthController, :request)
    get("/:provider/callback", AuthController, :callback)
    post("/:provider/callback", AuthController, :callback)
    post("/logout", AuthController, :delete)
  end

  # Other scopes may use custom stacks.
  # scope "/api", SuomidevWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through(:browser)
      live_dashboard("/dashboard", metrics: SuomidevWeb.Telemetry)
    end
  end
end
