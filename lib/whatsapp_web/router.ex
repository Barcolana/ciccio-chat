defmodule WhatsappWeb.Router do
  use WhatsappWeb, :router

  import WhatsappWeb.UserAuth

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)

    plug(:put_root_layout, html: {WhatsappWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(WhatsappWeb.UserAuth, :fetch_current_user)
    plug(:fetch_current_scope_for_user)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", WhatsappWeb do
    pipe_through(:browser)

    get("/", PageController, :home)
  end

  # Other scopes may use custom stacks.
  # scope "/api", WhatsappWeb do
  #   pipe_through :api
  # end

  ## Authentication routes

  scope "/", WhatsappWeb do
    pipe_through([:browser, :require_authenticated_user])

    live_session :require_authenticated_user,
      on_mount: [{WhatsappWeb.UserAuth, :require_authenticated}] do
      live("/users/settings", UserLive.Settings, :edit)
      live("/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email)
    end

    post("/users/update-password", UserSessionController, :update_password)
  end

  scope "/", WhatsappWeb do
    pipe_through([:browser])

    live_session :current_user,
      on_mount: [{WhatsappWeb.UserAuth, :mount_current_scope}] do
      live("/users/register", UserLive.Registration, :new)
      live("/users/log-in", UserLive.Login, :new)
      live("/users/log-in/:token", UserLive.Confirmation, :new)
      live("/rooms", RoomLive.Index, :index)
      live("/rooms/new", RoomLive.Form, :new)
      live("/rooms/:id", RoomLive.Show, :show)
      live("/rooms/:id/edit", RoomLive.Form, :edit)
    end

    post("/users/log-in", UserSessionController, :create)
    delete("/users/log-out", UserSessionController, :delete)
  end

  if Application.compile_env(:whatsapp, :dev_routes) do
    scope "/dev" do
      pipe_through(:browser)

      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end
end
