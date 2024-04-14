defmodule Boundary do
  @moduledoc """
  Handles boundary collision logic.

  All passed boundaries are expected to be from 0 to X, and 0 to Y.

  Currently there are no checks for circle diagonals, only XY boxes.
  """

  # Checks if a passed player is outside of a given bounds
  def outside?(%Player{ship: ship}, %{x: _, y: _} = coords) do
    %{x: x, y: y} = Movable.Motion.get_pos(ship)
    r = ship.radius
    outside?(%{x: x, y: y, r: r}, coords)
  end

  # Checks if a passed bullet is outside of a given bounds
  def outside?(%Bullet{} = bullet, %{x: _, y: _} = coords) do
    %{x: x, y: y} = Movable.Motion.get_pos(bullet)
    r = 1 # Assuming bullet radius 1
    outside?(%{x: x, y: y, r: r}, coords)
  end

  @doc "Checks if the passed object is outside the provided bounds (Assuming from 0 to x, 0 to y)"
  def outside?(%{x: x, y: y, r: r}, %{x: max_x, y: max_y}) do
    cond do
      # Check if Player_x + radius is < minimum_x (e.g. [-1, 0] + 1r < 0)
      x + r < 0 -> true
      # Check if Player_y + radius is < minimum_y (e.g. [0, -1] + 1r < 0)
      y + r < 0 -> true
      # Check if Player_x - radius is > max_x (e.g. [11, 0] - 1r < 10 for bounds 10)
      x - r > max_x -> true
      # Check if Player_y - radius is > max_y (e.g. [0, 11] - 1r < 10 for bounds 10)
      y - r > max_y -> true
      # Player is not outside of the bounds, return false.
      true -> false
    end
  end

  @doc "Does a simple check to see if the Players XY is within the damage zone (deadzone)"
  def inside_damage_zone?(%Player{ship: ship}, %{x: max_x, y: max_y, deadzone: deadzone}) do
    %{x: x, y: y} = Movable.Motion.get_pos(ship)
    # Check if the x, y positions overlap (Do not check radius for better deadzone feeling at edges)
    cond do
      # Check if Player_x is < minimum_x (e.g. [4, 0] < 5 for deadzone 5)
      x < 0 + deadzone -> true
      # Check if Player_y is < minimum_y (e.g. [0, 4] < 5 for deadzone 5)
      y < 0 + deadzone -> true
      # Check if Player_x is > max_x (e.g. [11, 0] > 10 for deadzone 5, max 15)
      x > max_x - deadzone -> true
      # Check if Player_y is > max_y (e.g. [0, 11] > 10 for deadzone 5, max 15)
      y > max_y - deadzone -> true
      # Player is not in damage zone, return false.
      true -> false
    end
  end
end
