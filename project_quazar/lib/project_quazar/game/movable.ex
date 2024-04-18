defmodule Movable do
  import :math

  defprotocol Motion do
    @doc "Moves an object based on its current velocity/acceleration"
    def move(data)
    @doc "Accelerates an object in its current direction"
    def accelerate(data, acl)
    @doc "Gets an object's x/y position and angle"
    def get_pos(data)
  end

  defprotocol Rotation do
    @doc "Rotates an object clockwise in radians"
    def rotate(data, rad, cw_or_ccw)
  end

  defprotocol Drag do
    @doc "Decelerates an object with constant drag in opposite direction of current velocity"
    def apply_drag(data, dcl)
  end

  @derive Jason.Encoder
  # x-coordinate, y-coordinate, x-velocity, y-velocity, orientation in radians
  defstruct [:px, :py, :vx, :vy, :angle]

  def new_movable(px, py, vx, vy, angle) do
    %__MODULE__{px: px, py: py, vx: vx, vy: vy, angle: angle}
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

  defimpl Movable.Motion, for: Movable do
    # Each tick, this is called to move the ship based on it's velocity
    # p = position, v = velocity, new position = position + vlocity
    def move(%Movable{px: px, py: py, vx: vx, vy: vy, angle: angle}) do
      %Movable{px: px + vx, py: py + vy, vx: vx, vy: vy, angle: angle}
    end

    # Using the thrust (hitting W)
    # Increases the velocity of the ship in the direction it is facing
    def accelerate(%Movable{px: px, py: py, vx: vx, vy: vy, angle: angle}, acl) do
      vxf = vx + cos(angle) * acl
      vyf = vy - sin(angle) * acl
      %Movable{px: px, py: py, vx: vxf, vy: vyf, angle: angle}
    end

    # Gets the current position
    def get_pos(%Movable{px: x, py: y, angle: angle}) do
      %{x: x, y: y, angle: angle}
    end
  end

  defimpl Movable.Drag, for: __MODULE__ do
    # Function to apply constant deceleration to the velocity vector
    def apply_drag(%Movable{px: px, py: py, vx: vx, vy: vy, angle: angle}, dcl) do
      # Calculate the magnitude of the velocity vector
      velocity_magnitude = :math.sqrt(vx * vx + vy * vy)

      if velocity_magnitude <= dcl do
        # If the magnitude of velocity is less than or equal to deceleration,
        # set velocity components to zero
        %Movable{px: px, py: py, vx: 0, vy: 0, angle: angle}
      else
        # Calculate the new velocity components after applying deceleration
        {new_vx, new_vy} = reduce_speed(vx, vy, dcl)
        %Movable{px: px, py: py, vx: new_vx, vy: new_vy, angle: angle}
      end
    end

    defp reduce_speed(vx, vy, deceleration) do
      # Calculate the magnitude of the velocity vector
      velocity_magnitude = :math.sqrt(vx * vx + vy * vy)

      # Calculate the angle of the velocity vector
      angle = :math.atan2(vy, vx)

      # Calculate the new magnitude after deceleration
      new_velocity_magnitude = velocity_magnitude - deceleration

      # Calculate the new velocity components
      new_vx = new_velocity_magnitude * :math.cos(angle)
      new_vy = new_velocity_magnitude * :math.sin(angle)

      {new_vx, new_vy}
    end
  end

  defimpl Movable.Rotation, for: __MODULE__ do
    # Clockwise rotation
    def rotate(%Movable{px: px, py: py, vx: vx, vy: vy, angle: angle}, rad, :cw) do
      new_angle = (angle - rad) |> Movable.normalize_angle()
      %Movable{px: px, py: py, vx: vx, vy: vy, angle: new_angle}
    end

    # Counter-clockwise rotation
    def rotate(%Movable{px: px, py: py, vx: vx, vy: vy, angle: angle}, rad, :ccw) do
      new_angle = (angle + rad) |> Movable.normalize_angle()
      %Movable{px: px, py: py, vx: vx, vy: vy, angle: new_angle}
    end
  end
end
