defmodule Movable do
  import :math

  defstruct [:px, :py, :vx, :vy, :angle] # x-coordinate, y-coordinate, x-velocity, y-velocity, orientation in radians

  def new_movable(px, py, vx, vy, angle) do
    %__MODULE__{px: px, py: py, vx: vx, vy: vy, angle: angle}
  end
  # Each tick, this is called to move the ship based on it's velocity
  # p = position, v = velocity, new position = position + vlocity
  def move(%__MODULE__{px: px, py: py, vx: vx, vy: vy, angle: angle}) do
    %__MODULE__{px: px + vx, py: py + vy, vx: vx, vy: vy, angle: angle}
  end

# Using the thrust (hitting W)
# Increases the velocity of the ship in the direction it is facing
  def accelerate(%__MODULE__{px: px, py: py, vx: vx, vy: vy, angle: angle}, acl) do
    vxf = vx + (cos(angle) * acl)
    vyf = vy + (sin(angle) *  acl)
    %__MODULE__{px: px, py: py, vx: vxf, vy: vyf, angle: angle}
  end

  # Clockwise rotation
  def rotate(%__MODULE__{px: px, py: py, vx: vx, vy: vy, angle: angle}, rad, :cw) do
    new_angle = angle - rad |> normalize_angle()
    %__MODULE__{px: px, py: py, vx: vx, vy: vy, angle: new_angle}
  end

  # Counter-clockwise rotation
  def rotate(%__MODULE__{px: px, py: py, vx: vx, vy: vy, angle: angle}, rad, :ccw) do
    new_angle = angle + rad |> normalize_angle()
    %__MODULE__{px: px, py: py, vx: vx, vy: vy, angle: new_angle}
  end

  # Converts angles into an equivalent angle such that 0 <= x <= 2 * PI
  def normalize_angle(angle) do
    upper = 2 * pi()
    cond do
      angle > upper -> angle - upper
      angle < 0 -> angle + upper
      true -> angle
    end
  end

end
