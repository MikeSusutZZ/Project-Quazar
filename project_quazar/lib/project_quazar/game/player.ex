defmodule Player do
  @moduledoc """
  Stores all player-related functionality.
  A player is composed of:
  - a name (string),
  - a ship (created from the `Ship` module),
  - score (int)
  """

  # Player name, `Ship`, & current score.
  defstruct [:name, :ship, :score]

  @doc "Creates a new player with a given name and ship (created from `Ship` module)"
  def new_player(name, ship) do
    %__MODULE__{name: name, ship: ship, score: 0}
  end

  @doc "Increments the score by an amount."
  def inc_score(%__MODULE__{score: old_score} = player_data, amount) do
    if(amount < 0, do: raise(ArgumentError, message: "Invalid increment amount"))
    %__MODULE__{ player_data | score: (old_score + amount) }
  end

  @doc "Resets the players current score."
  def reset_score(%__MODULE__{} = player_data) do
    %__MODULE__{ player_data | score: 0 }
  end

  @doc "Returns whether the player is alive or not. (> 0 health, or ship destroyed)"
  def alive?(%__MODULE__{ship: ship}) do
    Ship.alive?(ship)
  end

  @doc "Applies an amount of damage to the ships health."
  def take_damage(%__MODULE__{ship: ship} = player_data, amount) do
    damaged_ship = Ship.take_damage(ship, amount)
    %__MODULE__{ player_data | ship: damaged_ship }
  end

  @doc "Respawns the player at a given position and angle (in radians)."
  def respawn(%__MODULE__{ship: ship} = player_data, px, py, angle) do
    respawned_ship = Ship.respawn(ship, px, py, angle)
    %__MODULE__{ player_data | score: 0, ship: respawned_ship }
  end
  
  
  def outside_coordinates?(%__MODULE__{ship: ship}, coords) do
    Ship.outside_coordinates?(ship, coords)
  end

  defimpl Movable.Motion, for: __MODULE__ do
    @doc "Moves the players ship according to its kinematics"
    def move(%@for{ship: ship} = player_data) do
      %@for{ player_data | ship: Movable.Motion.move(ship) }
    end

    @doc "Accelerates the player in their current direction"
    def accelerate(%@for{ship: ship} = player_data, amount) do
      %@for{ player_data | ship: Movable.Motion.accelerate(ship, amount) }
    end

    # Gets the current position
    def get_pos(%@for{ship: ship}) do
      Movable.Motion.get_pos(ship)
    end
  end
  
  defimpl Movable.Drag, for: __MODULE__ do
    @doc "Applies drag to slow down ship until it comes to full rest"
    def apply_drag(%@for{ship: ship} = player_data, amount) do
      %@for{ player_data | ship: Movable.Drag.apply_drag(ship, amount) }
    end
  end
  
  defimpl Movable.Rotation, for: __MODULE__ do
    def rotate(%@for{ship: ship} = player_data, rad, :cw) do
      %@for{ player_data | ship: Movable.Rotation.rotate(ship, rad, :cw) }
    end

    @doc """
    Rotates ship either clockwise or counter-clockwise in radians.
    Pass `:cw` for clockwise, `:ccw` for counter-clockwise
    """
    def rotate(%@for{ship: ship} = player_data, rad, :ccw) do
      %@for{ player_data | ship: Movable.Rotation.rotate(ship, rad, :ccw) }
    end
  end
end
