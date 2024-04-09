defmodule Ship do
  # Name, Position (x/y position, velocity & angle), Current health, & Bullet damage
  # Not sure if this essentially is the player module, or if the player module contains
  # more/different functionality that I'm not aware of at the moment.
  defstruct [:name, :position, :health, :bullet_dmg]

  def new_ship(name, px, py, angle, health, bullet_dmg) do
    %Ship{name: name, position: Movable.new_movable(px, py, 0, 1, angle), health: health, bullet_dmg: bullet_dmg}
  end

  defimpl Movable.MovableObj, for: Ship do
    # Moves the ship according to its current pos, acceleration, & velocity
    def move(%Ship{name: name, position: position, health: health, bullet_dmg: bullet_dmg}) do
      new_pos = Movable.MovableObj.move(position)
      %Ship{name: name, position: new_pos, health: health, bullet_dmg: bullet_dmg}
    end

    # Accelerates the ship in its current direction
    def accelerate(%Ship{name: name, position: position, health: health, bullet_dmg: bullet_dmg}, acl) do
      new_pos = Movable.MovableObj.accelerate(position, acl)
      %Ship{name: name, position: new_pos, health: health, bullet_dmg: bullet_dmg}
    end

    # Rotates ship clockwise in degrees (Turns right)
    def rotate(%Ship{name: name, position: position, health: health, bullet_dmg: bullet_dmg}, rad, :cw) do
      new_pos = Movable.MovableObj.rotate(position, rad, :cw)
      %Ship{name: name, position: new_pos, health: health, bullet_dmg: bullet_dmg}
    end

    # Rotates ship counter-clockwise in degrees (Turns left)
    def rotate(%Ship{name: name, position: position, health: health, bullet_dmg: bullet_dmg}, rad, :ccw) do
      new_pos = Movable.MovableObj.rotate(position, rad, :ccw)
      %Ship{name: name, position: new_pos, health: health, bullet_dmg: bullet_dmg}
    end
  end

  # Applies a set amount of damage to the provided ships health
  def take_damage(%Ship{name: name, position: position, health: health, bullet_dmg: bullet_dmg}, damage) do
    %Ship{name: name, position: position, health: (health - damage), bullet_dmg: bullet_dmg}
  end

  # Returns whether the passed ship is alive (>0 health)
  def is_alive(%Ship{name: _, position: _, health: health, bullet_dmg: _}) do
    health > 0
  end
end
