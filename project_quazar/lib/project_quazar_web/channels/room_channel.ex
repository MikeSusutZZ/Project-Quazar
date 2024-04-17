defmodule ProjectQuazarWeb.RoomChannel do
  use Phoenix.Channel

  def join("room:lobby", message, socket) do
    # Store the name of the user
    IO.inspect(message)
    {_, name} = Map.fetch(message, "name")
    IO.inspect(name)

    GamePrototype.add(%{name: name, key: ""})

    {:ok, assign(socket, name: name)}
  end

  def handle_in("promote", _value, socket) do
    # Promote to broadcast owner if there isnt one
    if !BroadcastTracker.is_broadcasting() do
      BroadcastTracker.toggle()
      BroadcastTracker.set_owner(socket.assigns.name)
      start_broadcast_timer()
    end

    {:noreply, socket}
  end

  def handle_in("mounted", _value, socket) do
    # Attempt to promote on mount
    IO.inspect(BroadcastTracker.owner())
    IO.inspect(BroadcastTracker.is_broadcasting())

    if !BroadcastTracker.is_broadcasting() do
      BroadcastTracker.toggle()
      BroadcastTracker.set_owner(socket.assigns.name)
      start_broadcast_timer()
    end

    {:noreply, socket}
  end

  def handle_in("keydown", %{"key" => key}, socket) do
    # Updates the user's pressed key
    # Attach the Game Server keydown API calls here. The key's value can be pattern matched.
    GamePrototype.update_user(socket.assigns.name, key)
    {:reply, {:ok, %{message: "Message received."}}, socket}
  end

  # def handle_in("keyup", %{"key" => key}, socket) do
  #   # Resets the user's pressed key on key release.
  #   # Attach the Game Server keyup API calls here. The key's value can be pattern matched.
  #   # Comment out this handler to track most recently pressed keys of all clients

  #   GamePrototype.update_user(socket.assigns.name, "")
  #   {:reply, {:ok, %{message: "Message received."}}, socket}
  # end

  def terminate(_reason, socket) do
    # Clears the broadcast owner when they leave. Another client must be promoted to maintain
    # the broadcasting.
    if socket.assigns.name == BroadcastTracker.owner() do
      IO.puts("Broadcast owner left.")
      BroadcastTracker.toggle()
      BroadcastTracker.set_owner("")
    end

    case socket.assigns.name do
      nil ->
        IO.puts("User left the channel")

      name ->
        IO.puts("#{name} left the channel")
        GamePrototype.remove_user(name)
    end

    :ok
  end

  # Repeated broadcasts. The interval can be adjusted.
  defp start_broadcast_timer() do
    Process.send_after(self(), :broadcast_hello, 1000)
  end

  def handle_info(:broadcast_hello, socket) do
    # The game state broadcasting happens here.
    # IO.puts("Broadcast interval...")
    IO.inspect(BroadcastTracker.owner())
    IO.inspect(BroadcastTracker.is_broadcasting())
    # IO.inspect(self())
    {users, count} = GamePrototype.get_users()
    broadcast!(socket, "broadcast", %{})
    broadcast!(socket, "user_state", %{users: users, count: count})
    start_broadcast_timer()
    {:noreply, socket}
  end
end
