defmodule FrontendWeb.CircleLive do
  use FrontendWeb, :live_view

  def mount(_params, _session, socket) do
    initial_x = 100
    initial_y = 100
    json_pos = %{x: initial_x, y: initial_y}
    player_status = %{health: 100, isAlive: true}
    json_pos = Map.merge(json_pos, player_status)
    game_board = fetch_game_board_data()

    socket =
      socket
      |> assign(:circle_pos, json_pos)
      |> assign(:game_board, game_board)

    {:ok, socket}
  end

  def handle_event("start_move", %{"key" => key}, socket) do
    IO.inspect("#{key} pressed")
    IO.inspect(socket.assigns.circle_pos)

    new_pos =
      case key do
        # Move up
        "w" -> %{x: socket.assigns.circle_pos.x, y: socket.assigns.circle_pos.y - 10}
        # Move left
        "a" -> %{x: socket.assigns.circle_pos.x - 10, y: socket.assigns.circle_pos.y}
        # Move down
        "s" -> %{x: socket.assigns.circle_pos.x, y: socket.assigns.circle_pos.y + 10}
        # Move right
        "d" -> %{x: socket.assigns.circle_pos.x + 10, y: socket.assigns.circle_pos.y}
        _ -> socket.assigns.circle_pos
      end

    # Merge the extra values back into the new position map
    new_pos = Map.merge(new_pos, Map.drop(socket.assigns.circle_pos, [:x, :y]))

    {:noreply, assign(socket, :circle_pos, new_pos)}
  end

  def handle_event("stop_move", %{"key" => key}, socket) do
    IO.inspect("#{key} released")
    {:noreply, socket}
  end

  def handle_event("shoot", _value, socket) do
    IO.inspect("Pew")
    {:noreply, socket}
  end

  # Helper function to fetch game board data (replace with your implementation)
  defp fetch_game_board_data() do
    # Fetch game board data from JSON or a struct
    # Example: game_board_data = MyApp.GameBoard.fetch_data()
    # For demo purposes, return a static example
    [
      ["X", "O", "X", "O", "X", "O", "X", "O", "X", "O"],
      ["O", "X", "O", "X", "O", "X", "O", "X", "O", "X"],
      ["X", "O", "X", "O", "X", "O", "X", "O", "X", "O"],
      ["O", "X", "O", "X", "O", "X", "O", "X", "O", "X"],
      ["X", "O", "X", "O", "X", "O", "X", "O", "X", "O"],
      ["O", "X", "O", "X", "O", "X", "O", "X", "O", "X"],
      ["X", "O", "X", "O", "X", "O", "X", "O", "X", "O"],
      ["O", "X", "O", "X", "O", "X", "O", "X", "O", "X"],
      ["X", "O", "X", "O", "X", "O", "X", "O", "X", "O"],
      ["O", "X", "O", "X", "O", "X", "O", "X", "O", "X"]
    ]
  end
end
