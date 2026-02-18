defmodule WhatsappWeb.ErrorJSONTest do
  use WhatsappWeb.ConnCase, async: true

  test "renders 404" do
    assert WhatsappWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert WhatsappWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
