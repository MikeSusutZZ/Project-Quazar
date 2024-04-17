defmodule ProjectQuazarWeb.PubSubPrototypeLive do
  use ProjectQuazarWeb, :live_view
  alias ProjectQuazar.PubSub

  def render(assigns) do
    ~H"""
    <span id="main" phx-window-keydown="key_down" phx-hook="PubsubPrototype" data-game-state={"#{Jason.encode!(@game_state)}"} data-frames={"#{Jason.encode!(@count)}"}>Pubsub Prototype</span>
    <span phx-window-keyup="key_up"></span>
    """
  end

  def mount(params, _session, socket) do
    Phoenix.PubSub.subscribe(PubSub, "game_state:updates")
    {_, name} = Map.fetch(params, "name")
    IO.inspect(name)
    GamePrototype.add(%{name: name, key: ""})
    updated_socket = assign(socket, name: name, game_state: "", count: "")
    {:ok, updated_socket}
  end

  @impl true
  def handle_event("key_up", %{"key" => key}, socket) when key in ["w", "a", "s", "d"] do
    IO.puts("Live View: #{key}")
    # Call GameServer like "GameServer.func()"
    {:noreply, socket}
  end

  # Ignore other keys
  @impl true
  def handle_event("key_down", %{"key" => key}, socket) do
    GamePrototype.update_user(socket.assigns.name, key)
    {:noreply, socket}
  end

  # Ignore other keys
  @impl true
  def handle_event("key_up", _payload, socket) do
    {:noreply, socket}
  end

  # PubSub game state broadcast handler
  @impl true
  def handle_info({:state_updated, new_state}, socket) do
    IO.puts("Broadcast")
    IO.inspect(socket.assigns)
    {game_state, count} = new_state
    name = socket.assigns.name

    updated_socket =
      socket
      |> update(:name, fn _name -> name end)
      |> update(:game_state, fn _game_state -> game_state end)
      |> update(:count, fn _count -> count end)

    send(self(), :update_client)

    {:noreply, updated_socket}
  end

  def handle_info(:update_client, socket) do
    # Handle the custom message received by the LiveView process
    IO.puts("Received custom message")
    {:noreply, push_event(socket, "update", %{updated: "true"})}
  end

  def terminate(_reason, socket) do
    case socket.assigns.name do
      nil ->
        IO.puts("User left the channel")

      name ->
        IO.puts("#{name} left the channel")
        GamePrototype.remove_user(name)
    end

    :ok
  end
end
