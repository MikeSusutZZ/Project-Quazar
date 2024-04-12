defmodule Bullet do
  @moduledoc """
  Handles all bullet-related operations.

  Composed of:
  - Movement vector (utilizing the Movable module: x/y position, x/y velocity),
  - Sender identification,
  - Bullet type
  """

  defstruct sender: nil, kinematics: %Movable{}, type: nil

  @doc "Creates a new bullet with specified attributes."
  def new_bullet(sender, px, py, vx, vy, type) do
    kinematics = Movable.new_movable(px, py, vx, vy, 0)

    %__MODULE__{
      sender: sender,
      kinematics: kinematics,
      type: type
    }
  end

  defimpl Movable.Motion, for: __MODULE__ do
    @doc "Moves the bullet according to its current XY position & velocity"
    def move(%@for{kinematics: old_position} = bullet) do
      new_pos = Movable.Motion.move(old_position)
      %@for{bullet | kinematics: new_pos}
    end

    @doc "Gets the current X/Y position and angle"
    def get_pos(%@for{kinematics: position}) do
      Movable.Motion.get_pos(position)
    end
  end
end
