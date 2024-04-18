defmodule Bullet do
  @moduledoc """
  Handles all bullet-related operations.

  Composed of:
  - Movement vector (utilizing the Movable module: x/y position, x/y velocity),
  - Sender identification,
  - Bullet type
  """

  # Defines the complete struct for a bullet
  @derive Jason.Encoder
  defstruct sender: nil, kinematics: %Movable{}, type: nil, damage: 0, tick_wait: 0, speed: 0, radius: 0

  # Bullet type specifications
  @bullet_types %{
    heavy: %{damage: 35, tick_wait: 30, speed: 1, radius: 2},
    medium: %{damage: 20, tick_wait: 22, speed: 2, radius: 1},
    light: %{damage: 10, tick_wait: 15, speed: 3, radius: 1}
  }

  @doc "Creates a new bullet with specified attributes."
  def new_bullet(sender, px, py, vx, vy, angle, type) do
    case Map.fetch(@bullet_types, type) do
    {:ok, attributes} ->
        bullet_px = px + attributes.radius
        bullet_py = py + attributes.radius
        kinematics = Movable.new_movable(bullet_px, bullet_py, vx, vy, angle)
        {:ok, %__MODULE__{
          sender: sender,
          type: type,
          kinematics: kinematics,
          damage: attributes.damage,
          tick_wait: attributes.tick_wait,
          speed: attributes.speed,
          radius: attributes.radius
        }}
      :error ->
        {:error, "Invalid bullet type: #{type}"}
    end
  end
  
  @doc "Checks if the bullet is of a valid type"
  def valid_type?(type) do
    Map.has_key?(@bullet_types, type)
  end

  # Implements the Movable.Motion protocol for the bullet
  defimpl Movable.Motion, for: __MODULE__ do
    @doc "Moves the bullet according to its current XY position & velocity"
    def move(%@for{kinematics: old_position} = bullet) do
      new_pos = Movable.Motion.move(old_position)
      %@for{bullet | kinematics: new_pos}
    end

    @doc "Accelerates the bullet when it was shot"
    def accelerate(%@for{kinematics: old_acceleration} = bullet, amount) do
      new_acceleration = Movable.Motion.accelerate(old_acceleration, amount)
      %@for{bullet | kinematics: new_acceleration}
    end

    @doc "Gets the current X/Y position and angle"
    def get_pos(%@for{kinematics: position}) do
      Movable.Motion.get_pos(position)
    end
  end
end
