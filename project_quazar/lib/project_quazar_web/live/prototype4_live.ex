defmodule ProjectQuazarWeb.Prototype4 do
  use ProjectQuazarWeb, :live_view

  def mount(_params, _session, socket) do
    # Parsing Dummy player list from JSON
    player_list = %{
      "players" => [
        %{
          "name" => "Player1",
          "score" => 1200,
          "ship" => %{
            "kinematics" => %{"px" => 100, "py" => 150},
            "max_health" => 100,
            "current_health" => 80,
            "bullet_type" => "laser"
          }
        }
      ]
    }

    # Assume single player for simplicity
    player = player_list["players"] |> List.first()

    game_board = fetch_game_board_data()

    socket =
      socket
      |> assign(:player, player)
      |> assign(:game_board, game_board)

    {:ok, socket}
  end

  def handle_event("start_move", %{"key" => key}, socket) do
    IO.inspect("#{key} pressed")
    player = socket.assigns.player

    new_kinematics =
      case key do
        "w" -> %{player["ship"]["kinematics"] | "py" => player["ship"]["kinematics"]["py"] - 10}
        "a" -> %{player["ship"]["kinematics"] | "px" => player["ship"]["kinematics"]["px"] - 10}
        "s" -> %{player["ship"]["kinematics"] | "py" => player["ship"]["kinematics"]["py"] + 10}
        "d" -> %{player["ship"]["kinematics"] | "px" => player["ship"]["kinematics"]["px"] + 10}
        _ -> player["ship"]["kinematics"]
      end

    updated_player = Map.put(player, "ship", Map.put(player["ship"], "kinematics", new_kinematics))

    {:noreply, assign(socket, :player, updated_player)}
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
    # Replace with real data fetching logic
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
