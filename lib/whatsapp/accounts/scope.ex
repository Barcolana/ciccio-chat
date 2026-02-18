defmodule Whatsapp.Accounts.Scope do
  @moduledoc """
  Defines the scope of the caller to be used throughout the app.
  """

  alias Whatsapp.Accounts.User
  use Ecto.Schema

  @primary_key false
  embedded_schema do
    field(:user_id, :integer)
    belongs_to(:user, User, define_field: false)
  end

  @doc """
  Creates a scope for the given user.

  Returns nil if no user is given.
  """
  def for_user(%User{} = user) do
    %__MODULE__{user: user, user_id: user.id}
  end

  def for_user(nil), do: nil
end
