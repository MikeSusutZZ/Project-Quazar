defmodule ProjectQuazarWeb.Router do
  use ProjectQuazarWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {ProjectQuazarWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", ProjectQuazarWeb do
    pipe_through(:browser)

    live("/", Game)
    # get "/", PageController, :home

    live("/start", StartScreenLive, :show)
    live("/create-ship", CreateShipLive, :show)

    # Frontend Prototype 1
    live("/test", TestLive)

    # Frontend Prototype 2
    live("/prototype-2", Prototype2)

    # Frontend prototype 3
    live("/prototype-3", Prototype3)
  end

  # Other scopes may use custom stacks.
  # scope "/api", ProjectQuazarWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:project_quazar, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: ProjectQuazarWeb.Telemetry)
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end
end
