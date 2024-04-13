defmodule Ship do
  @moduledoc """
  Contains all ship-related functionality.

  Composed of:
  - Kinematics (Movable component: x/y position, velocity & angle),
  - Maximum & Current health,
  - Bullet damage
  """

  defstruct [
    :kinematics,
    :max_health,
    :health,
    :type,
    :size,
    :acceleration,
    :bullet_type
  ]

  # Bullet type specifications
  # TODO: adjust size; bullet types
  @ship_types %{
    tank: %{health: 250, acceleration: 0.25, size: 6, bullet_type: :heavy},
    destroyer: %{health: 150, acceleration: 0.5, size: 4, bullet_type: :medium},
    scout: %{health: 100, acceleration: 1, size: 2, bullet_type: :light}
  }

  @doc "Creates a new Ship at x,y. Health sets maximum and current health, and bullet_dmg sets damage"
  def new_ship(px, py, angle, health, type) do
    case Map.fetch(@ship_types, type) do
      {:ok, attributes} ->
        %__MODULE__{
          kinematics: Movable.new_movable(px, py, 0, 0, angle),
          max_health: health,
          health: health,
          type: type,
          size: attributes.size,
          acceleration: attributes.acceleration,
          bullet_type: attributes.bullet_type
        }

      :error ->
        {:error, "Invalid ship type: #{type}"}
    end
  end

  defimpl Movable.Motion, for: __MODULE__ do
    @doc "Moves the ship according to its current XY position, acceleration, & velocity"
    def move(%@for{kinematics: old_position} = ship_data) do
      new_pos = Movable.Motion.move(old_position)
      %@for{ship_data | kinematics: new_pos}
    end

    @doc "Accelerates the ship in its current direction"
    def accelerate(%@for{kinematics: old_acceleration} = ship_data, amount) do
      new_acceleration = Movable.Motion.accelerate(old_acceleration, amount)
      %@for{ship_data | kinematics: new_acceleration}
    end

    def rotate(%@for{kinematics: old_rotation} = ship_data, rad, :cw) do
      new_rotation = Movable.Motion.rotate(old_rotation, rad, :cw)
      %@for{ship_data | kinematics: new_rotation}
    end

    @doc """
    Rotates ship either clockwise or counter-clockwise in radians.
    Pass `:cw` for clockwise, `:ccw` for counter-clockwise
    """
    def rotate(%@for{kinematics: old_rotation} = ship_data, rad, :ccw) do
      new_rotation = Movable.Motion.rotate(old_rotation, rad, :ccw)
      %@for{ship_data | kinematics: new_rotation}
    end

    @doc "Gets the current X/Y position and angle"
    def get_pos(%@for{kinematics: position}) do
      Movable.Motion.get_pos(position)
    end
  end

  @doc "Applies a set amount of damage to the provided ships health"
  def take_damage(%__MODULE__{health: old_health} = ship_data, amount) do
    new_health =
      cond do
        old_health <= 0 -> 0
        old_health - amount <= 0 -> 0
        true -> old_health - amount
      end

    %__MODULE__{ship_data | health: new_health}
  end

  @doc "Returns whether the passed ship is alive (>0 health)"
  def alive?(%__MODULE__{health: health}) do
    health > 0
  end

  @doc "Respawns the ship at a provided position and angle (in radians)"
  def respawn(%__MODULE__{max_health: new_health} = ship_data, px, py, angle) do
    new_pos = Movable.new_movable(px, py, 0, 0, angle)
    %__MODULE__{ship_data | health: new_health, kinematics: new_pos}
  end

  @doc """
  Fires a bullet from the ship, creating a new `Bullet` instance.
  Returns a `Bullet` struct representing the new bullet, or an error if the bullet type is invalid.
  """
  def fire(%__MODULE__{kinematics: kinematics, bullet_type: bullet_type}, player_name) do
    %{px: px, py: py, angle: angle} = Movable.Motion.get_pos(kinematics)

    Bullet.new_bullet(player_name, px, py, angle, bullet_type)
  end
end
