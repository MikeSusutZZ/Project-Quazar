defmodule Boundary do
  @moduledoc """
  Handles boundary collision logic.
  
  All passed boundaries are expected to be from 0 to X, and 0 to Y.
  """
  
  @doc "Checks if a passed player is outside of a given bounds"
  def outside?(%Player{ship: ship}, %{x: _, y: _} = coords) do
    %{x, y} = Movable.Motion.get_pos(ship)
    r = ship.radius
    outside?(%{x: x, y: y, r: r}, coords)
  end
  
  def outside?(%Bullet{} = bullet, %{x: _, y: _} = coords) do
    %{x, y} = Movable.Motion.get_pos(bullet)
    r = 1 # Assuming bullet radius 1
    outside?(%{x: x, y: y, r: r}, coords)
  end
  
  #doc "Checks if the passed circle is outside the provided bounds (Assuming from 0 to x, 0 to y)
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
    end
  end
end