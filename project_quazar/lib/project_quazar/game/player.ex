defmodule Player do
  @moduledoc """
  Stores all player-related functionality. 
  A player is composed of a name (string), a ship (from Ship module), and score (int)
  """
  
  # Player name, Ship, & current score.
  defstruct [:name, :ship, :score]
  
  # Creates a new player with a given name and ship (created from Ship module)
  def new_player(name, ship) do
    %__MODULE__{name: name, ship: ship, score: 0}
  end
  
  # Increments the score by an amount.
  def inc_score(%__MODULE__{score: old_score} = player_data, amount) do
    if(amount < 0, do: raise(ArgumentError, message: "Invalid increment amount"))
    %__MODULE__{ player_data | score: (old_score + amount) }
  end
  
  # Resets the players current score.
  def reset_score(%__MODULE__{} = player_data) do
    %__MODULE__{ player_data | score: 0 }
  end
  
  # Returns whether this player is alive or not. (> 0 health, or ship destroyed)
  def alive?(%__MODULE__{ship: ship}) do
    if ship == nil do
      false
    else
      Ship.alive?(ship)
    end
  end
  
  # Applies an amount of damage to the ships health. If a ship runs out of health, it is destroyed.
  def take_damage(%__MODULE__{ship: ship} = player_data, amount) do
    damaged_ship = Ship.take_damage(ship, amount)
    if Ship.alive?(damaged_ship) do
      %__MODULE__{ player_data | ship: damaged_ship }
    else # Player has taken too much damage, ship has been destroyed
      %__MODULE__{ player_data | ship: nil }
    end
  end
  
  defimpl Movable.Motion, for: __MODULE__ do
    # Moves the players ship according to its kinematics
    def move(%@for{ship: ship} = player_data) do
      %@for{ player_data | ship: Movable.Motion.move(ship) }
    end

    # Accelerates the player in their current direction
    def accelerate(%@for{ship: ship} = player_data, amount) do
      %@for{ player_data | ship: Movable.Motion.accelerate(ship, amount) }
    end

    # Rotates ship clockwise in degrees (Turns right)
    def rotate(%@for{ship: ship} = player_data, rad, :cw) do
      %@for{ player_data | ship: Movable.Motion.rotate(ship, rad, :cw) }
    end

    # Rotates ship counter-clockwise in degrees (Turns left)
    def rotate(%@for{ship: ship} = player_data, rad, :ccw) do
      %@for{ player_data | ship: Movable.Motion.rotate(ship, rad, :ccw) }
    end
  end
end