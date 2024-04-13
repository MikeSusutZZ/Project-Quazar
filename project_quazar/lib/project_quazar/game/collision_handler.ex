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

  @doc """
  Checks for collisions between a list of ships.
  Accepts a list of ships.
  Returns tuples of collided ships.
  """
  def check_ship_ship_collisions(ships) do
    for ship1 <- ships, ship2 <- ships, ship1 != ship2 do
      pos1 = Movable.Motion.get_pos(ship1.kinematics)
      pos2 = Movable.Motion.get_pos(ship2.kinematics)
      if collides?(pos1, ship1.size, pos2, ship2.size) do
        IO.puts("Collision detected between two ships:")
        {:ship_ship_collision, ship1, ship2}
      end
    end
    |> Enum.uniq()
  end

  @doc """
  Public function to be called by the game server to handle all collisions
  Accepts a list of bullets and ships to be checked
  Returns a tuple of lists of updated bullets and ships
  """
  def handle_collisions(bullets, ships) do
    IO.puts("Checking for collisions...")
    # Early exit if there are no entities to check for collisions
    case {bullets, ships} do
      {[], []} ->
        IO.puts("No bullets or ships to check for collisions.")
        {[], []}

      {_, []} ->
        IO.puts("No ships available to collide with bullets.")
        {bullets, []}

      {[], _} when length(ships) == 1 ->
        IO.puts("Only one ship and no bullets; no ship-ship collisions possible.")
        {[], ships}

      {[], _} ->
        IO.puts("Multiple ships but no bullets; checking for ship-ship collisions only.")
        # {[], handle_ship_ship_collisions(ships)}
        {[], handle_ship_ship_collisions()}

      {_ , _} ->
        # Normal case: Handle both bullet-ship and ship-ship collisions
        bullet_ship_collisions = check_bullet_ship_collisions(bullets, ships)
        # {updated_bullets, updated_ships} = handle_bullet_ship_collisions(bullet_ship_collisions, bullets, ships)

        ship_ship_collisions = check_ship_ship_collisions(ships)
        # final_updated_ships = handle_ship_ship_collisions(ship_ship_collisions, ships)
        # {updated_bullets, final_updated_ships}
    end
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

  # Handles bullet-ship collisions.
  # Returns the updated list of bullets after removing those that have collided with ships.
  defp handle_bullet_ship_collisions() do
    # should be provided by Michelle
    IO.puts("Bullet-ship collisions not yet implemented.")
  end

  #  Handles ship-ship collisions
  defp handle_ship_ship_collisions() do
    # should be provided by Michelle
    IO.puts("Ship-ship collisions not yet implemented.")
  end
end
