defmodule Ship do
  # Kinematics (Movable component: x/y position, velocity & angle), Current health, & Bullet damage
  defstruct [:kinematics, :health, :bullet_dmg]

  def new_ship(px, py, angle, health, bullet_dmg) do
    %Ship{
      kinematics: Movable.new_movable(px, py, 0, 0, angle),
      health: health,
      bullet_dmg: bullet_dmg
    }
  end

  defimpl Movable.Motion, for: Ship do
    # Moves the ship according to its current XY position, acceleration, & velocity
    def move(%Ship{kinematics: old_position} = ship_data) do
      new_pos = Movable.Motion.move(old_position)
      %Ship{ ship_data | kinematics: new_pos }
    end

    # Accelerates the ship in its current direction
    def accelerate(%Ship{kinematics: old_acceleration} = ship_data, amount) do
      new_acceleration = Movable.Motion.accelerate(old_acceleration, amount)
      %Ship{ ship_data | kinematics: new_acceleration }
    end

    # Rotates ship clockwise in degrees (Turns right)
    def rotate(%Ship{kinematics: old_rotation} = ship_data, rad, :cw) do
      new_rotation = Movable.Motion.rotate(old_rotation, rad, :cw)
      %Ship{ ship_data | kinematics: new_rotation }
    end

    # Rotates ship counter-clockwise in degrees (Turns left)
    def rotate(%Ship{kinematics: old_rotation} = ship_data, rad, :ccw) do
      new_rotation = Movable.Motion.rotate(old_rotation, rad, :ccw)
      %Ship{ ship_data | kinematics: new_rotation }
    end
  end

  # Applies a set amount of damage to the provided ships health
  def take_damage(%Ship{health: old_health} = ship_data, amount) do
    %Ship{ ship_data | health: (old_health - amount) }
  end

  # Returns whether the passed ship is alive (>0 health)
  def alive?(%Ship{health: health}) do
    health > 0
  end
end
