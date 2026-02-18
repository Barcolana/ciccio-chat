defmodule Whatsapp.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field(:body, :string)
    belongs_to(:room, Whatsapp.Chat.Room)
    belongs_to(:user, Whatsapp.Accounts.User)

    timestamps(type: :utc_datetime)
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [:body, :room_id, :user_id])
    |> validate_required([:body, :room_id, :user_id])
  end
end
