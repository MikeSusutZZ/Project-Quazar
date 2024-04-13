defmodule Bullet do
  @moduledoc """
  Handles all bullet-related operations.

  Composed of:
  - Movement vector (utilizing the Movable module: x/y position, x/y velocity),
  - Sender identification,
  - Bullet type
  """

  @doc "Defines the complete struct for a bullet"
  defstruct sender: nil, kinematics: %Movable{}, type: nil, damage: 0, tick_wait: 0, speed: 0

  @doc "Bullet type specifications"
  @bullet_types %{
    heavy: %{damage: 35, tick_wait: 30, speed: 0},
    medium: %{damage: 20, tick_wait: 22, speed: 2},
    light: %{damage: 10, tick_wait: 15, speed: 5}
  }

  @doc "Creates a new bullet with specified attributes."
  def new_bullet(sender, px, py, vx, vy, angle, type) do
    {:ok, attributes} ->
        kinematics = Movable.new_movable(px, py, vx, vy, angle)
        %__MODULE__{
          sender: sender,
          type: type,
          kinematics: kinematics,
          damage: attributes.damage,
          tick_wait: attributes.tick_wait,
          speed: attributes.speed
        }
      :error ->
        {:error, "Invalid bullet type: #{type}"}
  end

  @doc "Implements the Movable.Motion protocol for the bullet"
  defimpl Movable.Motion, for: __MODULE__ do
    @doc "Moves the bullet according to its current XY position & velocity"
    def move(%@for{kinematics: old_position} = bullet) do
      new_pos = Movable.Motion.move(old_position)
      %@for{bullet | kinematics: new_pos}
    end

    @doc "Accelerates the bullet when it was shot"
    def accelerate(%@for{kinematics: old_acceleration} = bullet, amount) do
      new_acceleration = Movable.Motion.accelerate(old_acceleration, amount)
      %@for{ bullet | kinematics: new_acceleration }
    end

    @doc "Gets the current X/Y position and angle"
    def get_pos(%@for{kinematics: position}) do
      Movable.Motion.get_pos(position)
    end
  end
end
