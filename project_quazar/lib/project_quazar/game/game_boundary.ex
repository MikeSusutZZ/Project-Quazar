defmodule Boundary do
  @moduledoc """
  Handles boundary collision logic.

  All passed boundaries are expected to be from 0 to X, and 0 to Y.

  Currently there are no checks for circle diagonals, only XY boxes.
  """

  # Checks if a passed player is outside of a given X Y boundary. Assumes [0,X] & [0,Y]
  def outside?(%Player{ship: ship}, %{x: _, y: _} = coords) do
    %{x: x, y: y} = Movable.Motion.get_pos(ship)
    outside?(%{x: x, y: y}, coords)
  end

  # Checks if a passed bullet is outside of a given bounds. Assumes [0,X] & [0,Y]
  def outside?(%Bullet{} = bullet, %{x: _, y: _} = coords) do
    %{x: x, y: y} = Movable.Motion.get_pos(bullet)
    outside?(%{x: x, y: y}, coords)
  end

  @doc "Checks if the passed object is (halfway or greater) outside the provided bounds (Assuming from 0 to x, 0 to y)"
  def outside?(%{x: x, y: y}, %{x: max_x, y: max_y}) do
    cond do
      # Check if Player_x is < minimum_x (e.g. [-1, 0] + 1r < 0)
      x < 0 -> true
      # Check if Player_y is < minimum_y (e.g. [0, -1] + 1r < 0)
      y < 0 -> true
      # Check if Player_x is > max_x (e.g. [11, 0] - 1r < 10 for bounds 10)
      x > max_x -> true
      # Check if Player_y is > max_y (e.g. [0, 11] - 1r < 10 for bounds 10)
      y > max_y -> true
      # Player is not outside of the bounds, return false.
      true -> false
    end
  end

  @doc "Does a simple check to see if the Player is within the damage zone"
  def inside_damage_zone?(%Player{ship: ship}, %{x: max_x, y: max_y, damage_zone: damage_zone}) do
    %{x: x, y: y} = Movable.Motion.get_pos(ship)
    # Check if the x, y positions overlap (Do not check radius for better damage_zone feeling at edges)
    cond do
      # Check if Player_x is < minimum_x (e.g. [4, 0] < 5 for damage_zone 5)
      x < 0 + damage_zone -> true
      # Check if Player_y is < minimum_y (e.g. [0, 4] < 5 for damage_zone 5)
      y < 0 + damage_zone -> true
      # Check if Player_x is > max_x (e.g. [11, 0] > 10 for damage_zone 5, max 15)
      x > max_x - damage_zone -> true
      # Check if Player_y is > max_y (e.g. [0, 11] > 10 for damage_zone 5, max 15)
      y > max_y - damage_zone -> true
      # Player is not in damage zone, return false.
      true -> false
    end
  end
end
