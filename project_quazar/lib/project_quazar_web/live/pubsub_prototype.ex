defmodule ProjectQuazarWeb.PubSubPrototypeLive do
  use ProjectQuazarWeb, :live_view
  alias ProjectQuazar.PubSub

  @moduledoc """
  Manages the live interactive view.

  Features:
  - Real-time game state updates using WebSocket (via Phoenix LiveView).
  - Player input handling for movement (keyboard events for 'w', 'a', 's', 'd' keys).
  - Dynamic rendering of game states on an HTML canvas.
  - Subscription to game state updates through Phoenix PubSub.
  """

  @doc "Renders the game canvas and encodes the game state into JSON format."
  def render(assigns) do
    ~H"""
    <canvas id="main" data-game-state={"#{Jason.encode!(@game_state)}"} phx-hook="GameBoardHook">Pubsub Prototype</canvas>
    """
  end

  @doc "Initializes the LiveView, spawns a player, subscribes to PubSub updates, and sets initial socket assignments."
  def mount(params, _session, socket) do
    {_, name} = Map.fetch(params, "name")
    IO.inspect(name)
    GameServer.spawn_player(name, :destroyer, :light)
    Phoenix.PubSub.subscribe(PubSub, "game_state:updates")
    updated_socket = assign(socket, name: name, game_state: "", count: "")
    {:ok, updated_socket}
  end

  @doc "Handles key release events for movement keys ('w', 'a', 's', 'd')."
  @impl true
  def handle_event("key_up", %{"key" => key}, socket) when key in ["w", "a", "s", "d"] do
    IO.puts("Key Up: #{key}")
    # Call GameServer like "GameServer.func()"
    {:noreply, socket}
  end

  # Ignore other keys
  @impl true
  def handle_event("key_down", %{"key" => key}, socket) do
    # GamePrototype.update_user(socket.assigns.name, key)
    IO.puts("Key Down: #{key}")

    case String.downcase(key) do
      "w" -> GameServer.accelerate_player(socket.assigns.name)
      "d" -> GameServer.rotate_player(socket.assigns.name, :ccw)
      "a" -> GameServer.rotate_player(socket.assigns.name, :cw)
      "v" -> GameServer.fire(socket.assigns.name)
      _ -> :ok
    end

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
    # IO.puts("Broadcast")
    # IO.inspect(socket.assigns)
    # IO.inspect(new_state)
    json = Jason.encode!(new_state)
    # IO.puts(json)
    # {game_state, count} = new_state
    name = socket.assigns.name

    updated_socket =
      socket
      |> update(:name, fn _name -> name end)
      |> update(:game_state, fn _game_state -> new_state end)

    send(self(), :update_client)

    {:noreply, updated_socket}
  end

  @doc "Handles custom messages intended for client-side updates."
  def handle_info(:update_client, socket) do
    # Handle the custom message received by the LiveView process
    # IO.puts("Received custom message")
    {:noreply, push_event(socket, "update", %{updated: "true"})}
  end

  @doc "Cleans up after the socket connection is terminated, either by removing the user or logging their departure."
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
