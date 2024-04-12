defmodule Projectile do
  @moduledoc """
  Projectile data and functions.

  Composed of:
  - Kinematics (Movable component: x-pos, y-pos, x-vel, y-vel, angle),
  - Damage: Damage that the projectile deals
  """

  defstruct [:kinematics, :dmg]

  @doc "Creates a new Projectile with the given kinematic and projectile data."
  def new_projectile(px, py, vx, vy, angle, dmg) do
    %__MODULE__{
      kinematics: Movable.new_movable(px, py, vx, vy, angle),
      dmg: dmg
    }
  end

  defimpl Movable.Motion, for: __MODULE__ do
    @doc "Moves the projectile according to its current XY position, acceleration, & velocity"
    def move(%@for{kinematics: old_position} = projectile_data) do
      new_pos = Movable.Motion.move(old_position)
      %@for{ projectile_data | kinematics: new_pos }
    end

    @doc "Accelerates the projectile in its current direction"
    def accelerate(%@for{kinematics: old_acceleration} = projectile_data, amount) do
      new_acceleration = Movable.Motion.accelerate(old_acceleration, amount)
      %@for{ projectile_data | kinematics: new_acceleration }
    end

    def rotate(%@for{kinematics: old_rotation} = projectile_data, rad, :cw) do
      new_rotation = Movable.Motion.rotate(old_rotation, rad, :cw)
      %@for{ projectile_data | kinematics: new_rotation }
    end

    @doc """
    Rotates projectile either clockwise or counter-clockwise in radians.
    Pass `:cw` for clockwise, `:ccw` for counter-clockwise
    """
    def rotate(%@for{kinematics: old_rotation} = projectile_data, rad, :ccw) do
      new_rotation = Movable.Motion.rotate(old_rotation, rad, :ccw)
      %@for{ projectile_data | kinematics: new_rotation }
    end

    @doc "Gets the current X/Y position and angle"
    def get_pos(%@for{kinematics: position}) do
      Movable.Motion.get_pos(position)
    end
  end
end
