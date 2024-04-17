defmodule ProjectQuazarWeb.Prototype4 do
  use ProjectQuazarWeb, :live_view

  @dummy_data %{
    "projectiles" => [
      %{
        "sender" => "p1",
        "kinematics" => %{
          "px" => 202.0,
          "py" => 93.0,
          "vx" => 3.061616997868383e-16,
          "vy" => 5.0,
          "angle" => 1.5707963267948966
        },
        "type" => "light",
        "damage" => 10,
        "tick_wait" => 15,
        "speed" => 5,
        "radius" => 1
      }
    ],
    "players" => [
      %{
        "name" => "p1",
        "ship" => %{
          "kinematics" => %{
            "px" => 197,
            "py" => 83,
            "vx" => 0,
            "vy" => 0,
            "angle" => 1.5707963267948966
          },
          "max_health" => 150,
          "health" => 150,
          "type" => "destroyer",
          "radius" => 4,
          "acceleration" => 0.5,
          "bullet_type" => "light"
        },
        "score" => 1300
      }
    ]
  }

  # Function to retrieve a player by name
  def get_player(name) do
    Enum.find(@dummy_data["players"], fn player -> player["name"] == name end)
  end

  # Function to retrieve player position (px, py)
  def get_player_position(name) do
    player = get_player(name)
    kinematics = player["ship"]["kinematics"]
    {kinematics["px"], kinematics["py"]}
  end

  # Function to retrieve player bullet type
  def get_player_bullet_type(name) do
    player = get_player(name)
    player["ship"]["bullet_type"]
  end

  # Function to retrieve bullet positions by sender
  def get_bullet_positions(sender) do
    Enum.filter_map(
      @dummy_data["projectiles"],
      fn projectile -> projectile["sender"] == sender end,
      fn projectile -> {projectile["kinematics"]["px"], projectile["kinematics"]["py"]} end
    )
  end

  # Function to retrieve player rotation (angle)
  def get_player_rotation(name) do
    player = get_player(name)
    player["ship"]["kinematics"]["angle"]
  end

  # Function to retrieve bullet rotation (angle) by sender
  def get_bullet_rotation(sender) do
    Enum.map(filter_projectiles_by_sender(sender), & &1["kinematics"]["angle"])
  end

  defp filter_projectiles_by_sender(sender) do
    Enum.filter(@dummy_data["projectiles"], fn projectile -> projectile["sender"] == sender end)
  end

  def mount(_params, _session, socket) do
    # Assume single player for simplicity
    player = @dummy_data["players"] |> List.first()

    # Assign dummy data to socket
    socket =
      assign(socket,
        players: @dummy_data["players"],
        projectiles: @dummy_data["projectiles"],
        game_board: fetch_game_board_data()
      )

    {:ok, socket}
  end

  def handle_event("start_move", %{"key" => key}, socket) do
    players = update_player_position(socket.assigns.players, key)
    {:noreply, assign(socket, players: players)}
  end

  def handle_event("stop_move", %{"key" => key}, socket) do
    IO.inspect("#{key} released")
    {:noreply, socket}
  end

  def handle_event("shoot", _value, socket) do
    projectiles = update_projectiles(socket.assigns.projectiles)
    {:noreply, assign(socket, projectiles: projectiles)}
  end

  defp update_player_position(players, key) do
    # Example implementation
    Enum.map(players, fn player ->
      kinematics = player["ship"]["kinematics"]

      new_kinematics =
        case key do
          "w" -> Map.update!(kinematics, "py", &(&1 - 10))
          "a" -> Map.update!(kinematics, "px", &(&1 - 10))
          "s" -> Map.update!(kinematics, "py", &(&1 + 10))
          "d" -> Map.update!(kinematics, "px", &(&1 + 10))
          _ -> kinematics
        end

      update_in(player, ["ship", "kinematics"], fn _ -> new_kinematics end)
    end)
  end

  defp update_projectiles(projectiles) do
    Enum.map(projectiles, fn projectile ->
      kinematics = projectile["kinematics"]
      new_px = kinematics["px"] + kinematics["vx"] * kinematics["speed"]
      new_py = kinematics["py"] + kinematics["vy"] * kinematics["speed"]
      projectile |> put_in(["kinematics", "px"], new_px) |> put_in(["kinematics", "py"], new_py)
    end)
    |> Enum.filter(fn p -> within_bounds?(p["kinematics"]["px"], p["kinematics"]["py"]) end)
  end

  defp within_bounds?(px, py) do
    px >= 0 and px <= 800 and py >= 0 and py <= 800
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
