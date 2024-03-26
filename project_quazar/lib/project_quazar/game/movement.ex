defmodule Movement do
  import :math

  def struct [:px, :py, :vx, :vy, :angle]

  def move(%__MODULE__{px: px, py: py, vx: vx, vy: vy, angle: angle}) do
    %__MODULE__{px: px + vx, py: py + vy, vx: vx, vy: vy, angle: angle}
  end

  def accelerate(%__MODULE__{px: px, py: py, vx: vx, vy: vy, angle: angle}, acl) do
    vxf = vx + (cos(angle) * acl)
    vyf = vy + (sin(angle) *  acl)
    %__MODULE__{px: px, py: py, vx: vxf, vy: vyf, angle: angle}
  end

  def rotate(%__MODULE__{px: px, py: py, vx: vx, vy: vy, angle: angle}, rad, :cw) do
    new_angle = angle - rad
    if new_angle < 0, do: new_angle + (2 * pi()), else: new_angle
  end

  def rotate(%__MODULE__{px: px, py: py, vx: vx, vy: vy, angle: angle}, rad, :ccw) do
    new_angle = angle - rad
    if new_angle > 2 * pi(), do: new_angle - (2 * pi()), else: new_angle
  end
end
