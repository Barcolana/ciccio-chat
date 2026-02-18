defmodule WhatsappWeb.RoomLive.Show do
  use WhatsappWeb, :live_view

  alias Whatsapp.Chat
  alias Whatsapp.Chat.Message
  alias Whatsapp.Repo

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        💬 {@room.name}
        <:actions>
          <.button navigate={~p"/rooms"}>
            <.icon name="hero-arrow-left" /> Torna alle rooms
          </.button>
        </:actions>
      </.header>

      <%!-- Area messaggi --%>
      <div id="messages" class="flex flex-col gap-2 p-4 h-96 overflow-y-auto bg-gray-50 rounded-lg mb-4">
        <%= for message <- @messages do %>
          <div class={[
            "flex",
            if(message.user_id == @current_scope.user.id, do: "justify-end", else: "justify-start")
          ]}>
            <div class={[
              "max-w-xs px-4 py-2 rounded-lg text-sm",
              if(message.user_id == @current_scope.user.id,
                do: "bg-green-500 text-white",
                else: "bg-white text-gray-800 shadow")
            ]}>
              <%= if message.user_id != @current_scope.user.id do %>
                <p class="font-bold text-xs text-gray-500 mb-1"><%= message.user.email %></p>
              <% end %>
              <p><%= message.body %></p>
              <p class="text-xs opacity-70 mt-1">
                <%= Calendar.strftime(message.inserted_at, "%H:%M") %>
              </p>
            </div>
          </div>
        <% end %>
      </div>

      <%!-- Campo input messaggio --%>
      <form phx-submit="send_message" class="flex gap-2">
        <input
          id="message-input"
          name="body"
          type="text"
          placeholder="Scrivi un messaggio..."
          value={@new_message}
          class="flex-1 border border-gray-300 rounded-full px-4 py-2 focus:outline-none focus:border-green-500"
        />
        <button
          type="submit"
          class="bg-green-500 text-white rounded-full px-6 py-2 hover:bg-green-600"
        >
          Invia
        </button>
      </form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    room = Chat.get_room!(socket.assigns.current_scope, id)

    if connected?(socket) do
      Phoenix.PubSub.subscribe(Whatsapp.PubSub, "room:#{room.id}")
    end

    messages = load_messages(room.id)

    {:ok,
     socket
     |> assign(:page_title, room.name)
     |> assign(:room, room)
     |> assign(:messages, messages)
     |> assign(:new_message, "")}
  end

  @impl true
  def handle_event("send_message", %{"body" => body}, socket) do
    user = socket.assigns.current_scope.user
    room = socket.assigns.room
    body = String.trim(body)

    if body != "" do
      {:ok, message} =
        Repo.insert(%Message{
          body: body,
          room_id: room.id,
          user_id: user.id
        })

      message = Repo.preload(message, :user)

      Phoenix.PubSub.broadcast(
        Whatsapp.PubSub,
        "room:#{room.id}",
        {:new_message, message}
      )

      {:noreply, assign(socket, :new_message, "")}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:new_message, message}, socket) do
    {:noreply, update(socket, :messages, fn messages -> messages ++ [message] end)}
  end

  def handle_info({type, %Whatsapp.Chat.Room{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end

  defp load_messages(room_id) do
    import Ecto.Query

    Repo.all(
      from(m in Message,
        where: m.room_id == ^room_id,
        order_by: [asc: m.inserted_at],
        preload: [:user]
      )
    )
  end
end
