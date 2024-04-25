defmodule Player do
  require Protocol

  @moduledoc """
  Stores all player-related functionality.
  A player is composed of:
  - a name (string),
  - a ship (created from the `Ship` module),
  - score (int)
  """

  # Player name, `Ship`, & current score.
  @derive Jason.Encoder
  defstruct [:name, :ship, :score, :inputs]

  Protocol.derive(Jason.Encoder, MapSet)

  @doc "Creates a new player with a given name and ship (created from `Ship` module)"
  def new_player(name, ship, bounds) do
    case Ship.random_ship(ship.type, ship.bullet_type, bounds) do
      {:error, err} -> {:error, err}
      ship -> %__MODULE__{name: name, ship: ship, score: 0, inputs: MapSet.new()}
    end
  end

  @doc "Increments the score by an amount."
  def inc_score(%__MODULE__{score: old_score} = player_data, amount) do
    if(amount < 0, do: raise(ArgumentError, message: "Invalid increment amount"))
    %__MODULE__{player_data | score: old_score + amount}
  end

  @doc "Increments the players ship health by a specified amount."
  def inc_health(%__MODULE__{} = player_data, amount) do
    %__MODULE__{player_data | ship: Ship.inc_health(player_data.ship, amount)}
  end

  @doc "Resets the players current score."
  def reset_score(%__MODULE__{} = player_data) do
    %__MODULE__{player_data | score: 0}
  end

  @doc "Returns whether the player is alive or not. (> 0 health, or ship destroyed)"
  def alive?(%__MODULE__{ship: ship}) do
    Ship.alive?(ship)
  end

  @doc "Kills the player's ship by setting health to 0."
  def kill_ship(player) do
    ship = player.ship
    updated_ship = Map.put(ship, :health, 0)
    Map.put(player, :ship, updated_ship)
  end

  @doc "Applies an amount of damage to the ships health."
  def take_damage(%__MODULE__{ship: ship} = player_data, amount) do
    damaged_ship = Ship.take_damage(ship, amount)
    %__MODULE__{player_data | ship: damaged_ship}
  end

  @doc "Respawns the player at a given position and angle (in radians)."
  def respawn(%__MODULE__{ship: ship} = player_data, px, py, angle) do
    respawned_ship = Ship.respawn(ship, px, py, angle)
    %__MODULE__{player_data | score: 0, ship: respawned_ship}
  end

  @doc "Updates the players input mapping values based on the passed value"
  def update_inputs(%__MODULE__{} = player, action, value) do
    # Update the players input map
    new_inputs =
      case value do
        true -> MapSet.put(player.inputs, action)
        false -> MapSet.delete(player.inputs, action)
      end

    # Return the player with new inputs
    %Player{player | inputs: new_inputs}
  end

  defp handle_fire_action(%__MODULE__{ship: ship, name: player_name} = player) do
    case Ship.fire(ship, player_name) do
      {:ok, {updated_ship, bullet}} ->
        GameServer.add_projectile(bullet)
        {:ok, %Player{player | ship: updated_ship}}

      {:error, error_msg} ->
        #IO.puts("Error firing: #{inspect(error_msg)}")
        :error
    end
  end

  @doc "Handles how each player/ship should update every game tick."
  def handle_inputs(%__MODULE__{ship: ship, inputs: inputs} = initial_state, rotation_speed) do
    enabled_inputs = MapSet.to_list(inputs)

    Enum.reduce(enabled_inputs, initial_state, fn input, player ->
      case input do
        :accelerate ->
          Movable.Motion.accelerate(player, ship.acceleration)

        :turn_left ->
          Movable.Rotation.rotate(player, rotation_speed, :ccw)

        :turn_right ->
          Movable.Rotation.rotate(player, rotation_speed, :cw)

        :fire ->
          case handle_fire_action(player) do
            {:ok, updated_player} -> updated_player
            # Keep original player if firing failed
            :error -> player
          end

        :brake ->
          # Use 80% of acceleration speed for brake speed
          brake_speed = ship.acceleration * 0.80
          Movable.Drag.apply_drag(player, brake_speed)

        _ ->
          player
      end
    end)
  end

  defimpl Movable.Motion, for: __MODULE__ do
    @doc "Moves the players ship according to its kinematics"
    def move(%@for{ship: ship} = player_data) do
      %@for{player_data | ship: Movable.Motion.move(ship)}
    end

    @doc "Accelerates the player in their current direction"
    def accelerate(%@for{ship: ship} = player_data, amount) do
      %@for{player_data | ship: Movable.Motion.accelerate(ship, amount)}
    end

    # Gets the current position
    def get_pos(%@for{ship: ship}) do
      Movable.Motion.get_pos(ship)
    end
  end

  defimpl Movable.Drag, for: __MODULE__ do
    @doc "Applies drag to slow down ship until it comes to full rest"
    def apply_drag(%@for{ship: ship} = player_data, amount) do
      %@for{player_data | ship: Movable.Drag.apply_drag(ship, amount)}
    end
  end

  defimpl Movable.Rotation, for: __MODULE__ do
    def rotate(%@for{ship: ship} = player_data, rad, :cw) do
      %@for{player_data | ship: Movable.Rotation.rotate(ship, rad, :cw)}
    end

    @doc """
    Rotates ship either clockwise or counter-clockwise in radians.
    Pass `:cw` for clockwise, `:ccw` for counter-clockwise
    """
    def rotate(%@for{ship: ship} = player_data, rad, :ccw) do
      %@for{player_data | ship: Movable.Rotation.rotate(ship, rad, :ccw)}
    end
  end
end
