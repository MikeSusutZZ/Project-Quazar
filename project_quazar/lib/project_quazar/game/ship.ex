defmodule Ship do
  @moduledoc """
  Contains all ship-related functionality.

  Composed of:
  - Kinematics (Movable component: x/y position, velocity & angle),
  - Maximum & Current health,
  - Bullet damage
  """

  defstruct [:kinematics, :max_health, :health, :bullet_dmg]

  @doc "Creates a new `Ship` at x,y. Health sets maximum and current health, and bullet_dmg sets damage"
  def new_ship(px, py, angle, health, bullet_dmg) do
    %__MODULE__{
      kinematics: Movable.new_movable(px, py, 0, 0, angle),
      max_health: health,
      health: health,
      bullet_dmg: bullet_dmg
    }
  end

  def random_ship(bounding_width, bounding_height) do
    {random_x, random_y} = {random_between(0, bounding_width), random_between(0, bounding_height)}
    angle = random_angle()
    Ship.new_ship(random_x, random_y, angle, 100, 10) # default health (100) and bullet_dmg (10) right now
  end

  # Spawn within bounds
  def random_between(min, max), do: :rand.uniform(max - min + 1) + min

  # Ships spawn angled at multiples of 90degrees
  def random_angle do
    angles = [0, :math.pi() / 2, :math.pi(), 3 * :math.pi() / 2]
    Enum.random(angles)
  end


  defimpl Movable.Motion, for: __MODULE__ do
    @doc "Moves the ship according to its current XY position, acceleration, & velocity"
    def move(%@for{kinematics: old_position} = ship_data) do
      new_pos = Movable.Motion.move(old_position)
      %@for{ ship_data | kinematics: new_pos }
    end

    @doc "Accelerates the ship in its current direction"
    def accelerate(%@for{kinematics: old_acceleration} = ship_data, amount) do
      new_acceleration = Movable.Motion.accelerate(old_acceleration, amount)
      %@for{ ship_data | kinematics: new_acceleration }
    end

    @doc "Decelerate ship in opposite direction of motion"
    def decelerate(%@for{kinematics: old_values} = ship_data, amount) do
      # returns the decelerated ship with decrease velocity
      new_values = Movable.Motion.decelerate(old_values, amount)
      %@for{ ship_data | kinematics: new_values}
    end

    def rotate(%@for{kinematics: old_rotation} = ship_data, rad, :cw) do
      new_rotation = Movable.Motion.rotate(old_rotation, rad, :cw)
      %@for{ ship_data | kinematics: new_rotation }
    end

    @doc """
    Rotates ship either clockwise or counter-clockwise in radians.
    Pass `:cw` for clockwise, `:ccw` for counter-clockwise
    """
    def rotate(%@for{kinematics: old_rotation} = ship_data, rad, :ccw) do
      new_rotation = Movable.Motion.rotate(old_rotation, rad, :ccw)
      %@for{ ship_data | kinematics: new_rotation }
    end

    @doc "Gets the current X/Y position and angle"
    def get_pos(%@for{kinematics: position}) do
      Movable.Motion.get_pos(position)
    end
  end

  @doc "Applies a set amount of damage to the provided ships health"
  def take_damage(%__MODULE__{health: old_health} = ship_data, amount) do
    new_health = cond do
      old_health <= 0 -> 0
      (old_health - amount) <= 0 -> 0
      true -> (old_health - amount)
    end
    %__MODULE__{ ship_data | health: new_health }
  end

  @doc "Returns whether the passed ship is alive (>0 health)"
  def alive?(%__MODULE__{health: health}) do
    health > 0
  end

  @doc "Respawns the ship at a provided position and angle (in radians)"
  def respawn(%__MODULE__{max_health: new_health} = ship_data, px, py, angle) do
    new_pos = Movable.new_movable(px, py, 0, 0, angle)
    %__MODULE__{ ship_data | health: new_health, kinematics: new_pos }
  end
end
