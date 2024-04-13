defmodule CollisionHandler do
  @moduledoc """
  Handles collision detection between game entities.
  """

  @doc """
  Checks for collisions between a list of bullets and ships.
  Accepts a list of bullets and a list of ships.
  Returns tuples of collided bullets and ships.
  """
  def check_bullet_ship_collisions(bullets, ships) do
    Enum.flat_map(bullets, fn bullet ->
      Enum.filter(ships, fn ship ->
        bullet_pos = Movable.Motion.get_pos(bullet.kinematics)
        ship_pos = Movable.Motion.get_pos(ship.kinematics)
        collides?(bullet_pos, 1, ship_pos, ship.size) # Assuming bullet size as 1
      end)
      |> Enum.map(fn ship ->
        # Log the collision
        IO.puts("Collision detected between bullet and ship")
        {:bullet_ship_collision, bullet, ship}
      end)
    end)
  end


  # Checks for collision between two circles given their positions and sizes
  # Accepts positions in the format `{x, y}` and sizes
  # Returns true if there is a collision
  defp collides?(%{px: px1, py: py1}, size1, %{px: px2, py: py2}, size2) do
    distance({px1, py1}, {px2, py2}) < (size1 + size2)
  end

  # Calculates the distance between two points
  defp distance({px1, py1}, {px2, py2}) do
    :math.sqrt(:math.pow(px2 - px1, 2) + :math.pow(py2 - py1, 2))
  end

end
