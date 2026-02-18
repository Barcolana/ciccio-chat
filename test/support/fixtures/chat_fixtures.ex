defmodule Whatsapp.ChatFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Whatsapp.Chat` context.
  """

  @doc """
  Generate a room.
  """
  def room_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: "some name"
      })

    {:ok, room} = Whatsapp.Chat.create_room(scope, attrs)
    room
  end
end
