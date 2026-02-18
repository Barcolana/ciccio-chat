defmodule WhatsappWeb.PageController do
  use WhatsappWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
