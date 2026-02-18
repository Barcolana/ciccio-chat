defmodule Whatsapp.ChatTest do
  use Whatsapp.DataCase

  alias Whatsapp.Chat

  describe "rooms" do
    alias Whatsapp.Chat.Room

    import Whatsapp.AccountsFixtures, only: [user_scope_fixture: 0]
    import Whatsapp.ChatFixtures

    @invalid_attrs %{name: nil}

    test "list_rooms/1 returns all scoped rooms" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      room = room_fixture(scope)
      other_room = room_fixture(other_scope)
      assert Chat.list_rooms(scope) == [room]
      assert Chat.list_rooms(other_scope) == [other_room]
    end

    test "get_room!/2 returns the room with given id" do
      scope = user_scope_fixture()
      room = room_fixture(scope)
      other_scope = user_scope_fixture()
      assert Chat.get_room!(scope, room.id) == room
      assert_raise Ecto.NoResultsError, fn -> Chat.get_room!(other_scope, room.id) end
    end

    test "create_room/2 with valid data creates a room" do
      valid_attrs = %{name: "some name"}
      scope = user_scope_fixture()

      assert {:ok, %Room{} = room} = Chat.create_room(scope, valid_attrs)
      assert room.name == "some name"
      assert room.user_id == scope.user.id
    end

    test "create_room/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Chat.create_room(scope, @invalid_attrs)
    end

    test "update_room/3 with valid data updates the room" do
      scope = user_scope_fixture()
      room = room_fixture(scope)
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Room{} = room} = Chat.update_room(scope, room, update_attrs)
      assert room.name == "some updated name"
    end

    test "update_room/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      room = room_fixture(scope)

      assert_raise MatchError, fn ->
        Chat.update_room(other_scope, room, %{})
      end
    end

    test "update_room/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      room = room_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Chat.update_room(scope, room, @invalid_attrs)
      assert room == Chat.get_room!(scope, room.id)
    end

    test "delete_room/2 deletes the room" do
      scope = user_scope_fixture()
      room = room_fixture(scope)
      assert {:ok, %Room{}} = Chat.delete_room(scope, room)
      assert_raise Ecto.NoResultsError, fn -> Chat.get_room!(scope, room.id) end
    end

    test "delete_room/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      room = room_fixture(scope)
      assert_raise MatchError, fn -> Chat.delete_room(other_scope, room) end
    end

    test "change_room/2 returns a room changeset" do
      scope = user_scope_fixture()
      room = room_fixture(scope)
      assert %Ecto.Changeset{} = Chat.change_room(scope, room)
    end
  end
end
