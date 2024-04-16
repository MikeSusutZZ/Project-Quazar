defmodule CollisionHandler do
  @moduledoc """
  Handles collision detection between game entities.
  """

  @doc """
  Checks for collisions between a list of bullets and ships.
  Accepts a list of bullets and a list of players.
  Returns tuples of collided bullets and players.
  """
  def check_bullet_ship_collisions(bullets, players) do
    Enum.flat_map(bullets, fn bullet ->
      Enum.filter(players, fn player ->
        %{x: bullet_x, y: bullet_y} = Movable.Motion.get_pos(bullet.kinematics)
        %{x: ship_x, y: ship_y} = Movable.Motion.get_pos(player.ship.kinematics)
        collides?({bullet_x, bullet_y}, 1, {ship_x, ship_y}, player.ship.radius) # Assuming bullet radius as 1
      end)
      |> Enum.map(fn player ->
        # Log the collision
        IO.puts("Collision detected between bullet and ship")
        {:bullet_ship_collision, bullet, player}
      end)
    end)
  end

  @doc """
  Checks for collisions between a list of players.
  Accepts a list of players.
  Returns tuples of collided players.
  """
  def check_ship_ship_collisions(players) do
    for player1 <- players, player2 <- players, player1 != player2 do
      %{x: ship1_x, y: ship1_y} = Movable.Motion.get_pos(player1.ship.kinematics)
      %{x: ship2_x, y: ship2_y} = Movable.Motion.get_pos(player2.ship.kinematics)
      if collides?({ship1_x, ship1_y}, player1.ship.radius, {ship2_x, ship2_y}, player2.ship.radius) do
        IO.puts("Collision detected between two ships:")
        {:ship_ship_collision, player1, player2}
      end
    end
    |> Enum.uniq()
  end

  @doc """
  Public function to be called by the game server to handle all collisions
  Accepts a list of bullets and ships to be checked
  Returns a tuple of lists of updated bullets and ships
  """
  def handle_collisions(bullets, players) do
    IO.puts("Checking for collisions...")
    # Early exit if there are no entities to check for collisions
    case {bullets, players} do
      {[], []} ->
        IO.puts("No bullets or ships to check for collisions.")
        {[], []}

      {_, []} ->
        IO.puts("No ships available to collide with bullets.")
        {bullets, []}

      {[], _} when length(players) == 1 ->
        IO.puts("Only one ship and no bullets; no ship-ship collisions possible.")
        {[], players}

      {[], _} ->
        IO.puts("Multiple ships but no bullets; checking for ship-ship collisions only.")
        # {[], handle_ship_ship_collisions(players)}
        {[], handle_ship_ship_collisions()}

      {_ , _} ->
        # Normal case: Handle both bullet-ship and ship-ship collisions
        bullet_ship_collisions = check_bullet_ship_collisions(bullets, players)
        {updated_bullets, updated_updated_players} = handle_bullet_ship_collisions(bullet_ship_collisions, bullets, players)

        ship_ship_collisions = check_ship_ship_collisions(players)
        final_updated_ships = handle_ship_ship_collisions(ship_ship_collisions, players)
        {updated_bullets, final_updated_players}
    end
  end


  # Checks for collision between two circles given their positions and radius
  # Accepts positions in the format `{x, y}` and radius
  # Returns true if there is a collision
  defp collides?({px1, py1}, radius1, {px2, py2}, radius2) do
    distance({px1, py1}, {px2, py2}) < (radius1 + radius2)
  end

  # Calculates the distance between two points
  defp distance({px1, py1}, {px2, py2}) do
    :math.sqrt(:math.pow(px2 - px1, 2) + :math.pow(py2 - py1, 2))
  end

  # Handles bullet-ship collisions.
  # Accepts a list of collision tuples, identifies bullets that have hit ships, and applies the corresponding damage.
  # It also updates the score of the shooter in the high scores table.
  # Returns the updated lists of bullets and players after removing those that have collided with ships.
  defp handle_bullet_ship_collisions(collisions, bullets, players) do
    # Collect IDs of bullets that have collided using a Set for faster checks
    collided_bullets = MapSet.new(Enum.map(collisions, fn {_, bullet, _} -> bullet end))
    updated_bullets = Enum.reject(bullets, fn bullet -> MapSet.member?(collided_bullets, bullet) end)

    # Apply damage to ships and update players
    updated_players = Enum.reduce(players, [], fn player, acc ->
      # Find all collisions for this particular player
      player_collisions = Enum.filter(collisions, fn {_, _, collided_player} -> collided_player == player end)

      # Check if this player had any collisions
      if Enum.any?(player_collisions) do
        # Process each collision to apply damage
        updated_player = Enum.reduce(player_collisions, player, fn {_, bullet, _}, acc_player ->
          damaged_player = Player.take_damage(acc_player, bullet.damage)

          # Update the score for the player who fired the bullet
          ProjectQuazar.HighScores.insert_entry(bullet.sender, bullet.damage)

          # Return the updated player
          damaged_player
        end)

        # Only keep the player if their ship is still alive
        if Player.alive?(updated_player) do
          [updated_player | acc]
        else
          acc
        end
      else
        [player | acc] # No collisions for this player, add them back to the list unchanged
      end
    end)

    {updated_bullets, updated_players}
end

  # Processes collisions between ships, each ship's health is reduced by the amount of health the opposing ship has.
  # Accepts a list of collisions and the current list of players, updates the health of each ship involved in collision.
  # Returns an updated list of `Player` structs after applying the collision effects.
  defp handle_ship_ship_collisions(collisions, players) do
    # Sort and remove duplicate collision pairs
    unique_collisions = collisions
    |> Enum.map(fn {:ship_ship_collision, player1, player2} ->
      if player1.name < player2.name, do: {player1, player2}, else: {player2, player1}
    end)
    |> Enum.uniq()

    # Create a damage map for each player based on unique collisions
    damage_map = Enum.reduce(unique_collisions, %{}, fn {player1, player2}, acc ->
      acc
      |> Map.update(player1, player2.ship.health, &(&1 + player2.ship.health))
      |> Map.update(player2, player1.ship.health, &(&1 + player1.ship.health))
    end)

    # Apply the calculated damage and filter out destroyed ships, award points to the destroyer
    Enum.map(players, fn player ->
      damage = Map.get(damage_map, player, 0)
      if damage > 0 do
        updated_player = Player.take_damage(player, damage)
        if Ship.alive?(updated_player.ship) do
          updated_player
        else
          # Find the collision that resulted in this player's destruction and award points to the other player
          Enum.each(unique_collisions, fn {destroyer, destroyed} ->
            if destroyed == player do
              ProjectQuazar.HighScores.insert_entry(destroyer.name, 250)  # award points to the destroyer
            end
          end)
          nil  # Remove destroyed player
        end
      else
        player  # No damage, return the player as is
      end
    end)
    |> Enum.reject(&is_nil/1)  # Filter out nil entries which represent destroyed ships
  end
end