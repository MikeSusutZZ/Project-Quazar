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
    # IO.inspect(name)
    GameServer.remove_player(name)
    GameServer.spawn_player(name, :destroyer, :light)
    Phoenix.PubSub.subscribe(PubSub, "game_state:updates")
    updated_socket = assign(socket, name: name, game_state: "", count: "")
    {:ok, updated_socket}
  end

  # Key Down event from Browser
  @impl true
  def handle_event("key_down", %{"key" => key}, socket) do
    IO.puts("Key Down: #{key}")
    player_name = socket.assigns.name

    case String.downcase(key) do
      "w" -> GameServer.accelerate_pressed(player_name)
      "s" -> GameServer.brake_pressed(player_name)
      "d" -> GameServer.turn_right_pressed(player_name)
      "a" -> GameServer.turn_left_pressed(player_name)
      " " -> GameServer.fire_pressed(player_name)
      _ -> :ok
    end

    {:noreply, socket}
  end

  # Key Up event from Browser
  @impl true
  def handle_event("key_up", %{"key" => key}, socket) do
    player_name = socket.assigns.name
    key = String.downcase(key)
    IO.puts("Key Up: #{key}")
    IO.inspect(key)

    case key do
      "w" ->
        GameServer.accelerate_released(player_name)

      "s" ->
        GameServer.brake_released(player_name)

      "d" ->
        GameServer.turn_right_released(player_name)

      "a" ->
        GameServer.turn_left_released(player_name)

      " " ->
        GameServer.fire_released(player_name)

      _ ->
        :ok
    end

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
    name = socket.assigns.name
    IO.puts("#{name} left the game.")
    GameServer.remove_player(name)
    :ok
  end
end
