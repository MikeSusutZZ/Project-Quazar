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
        # Assuming bullet radius as 1
        collides?({bullet_x, bullet_y}, bullet.radius, {ship_x, ship_y}, player.ship.radius) && (bullet.sender !== player.name)
    end)
      |> Enum.map(fn player ->
        # Log the collision
        IO.puts(
          "Collision detected between bullet from #{bullet.sender} and ship: #{player.name}"
        )

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
    for player1 <- players, player2 <- players, player1 != player2, player1.name < player2.name do
      %{x: ship1_x, y: ship1_y} = Movable.Motion.get_pos(player1.ship.kinematics)
      %{x: ship2_x, y: ship2_y} = Movable.Motion.get_pos(player2.ship.kinematics)

      if collides?(
           {ship1_x, ship1_y},
           player1.ship.radius,
           {ship2_x, ship2_y},
           player2.ship.radius
         ) do
        IO.puts("Collision detected between two ships: #{player1.name} and #{player2.name}")
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
    #IO.puts("Checking for collisions...")
    # Early exit if there are no entities to check for collisions
    case {bullets, players} do
      {[], []} ->
        #IO.puts("No bullets or ships to check for collisions.")
        {[], []}

      {_, []} ->
        #IO.puts("No ships available to collide with bullets.")
        {bullets, []}

      {[], _} when length(players) == 1 ->
        #IO.puts("Only one ship and no bullets; no ship-ship collisions possible.")
        {[], players}

      {[], _} ->
        #IO.puts("Multiple ships but no bullets; checking for ship-ship collisions only.")
        new_players = handle_ship_ship_collisions(check_ship_ship_collisions(players), players)
        {[], new_players}

      {_, _} ->
        #IO.puts("Checking for bullet-ship and ship-ship collisions...")
        # Normal case: Handle both bullet-ship and ship-ship collisions
        bullet_ship_collisions = check_bullet_ship_collisions(bullets, players)

        {updated_bullets, intermediate_updated_players} =
          handle_bullet_ship_collisions(bullet_ship_collisions, bullets, players)

        # Now handle ship-ship collisions using the updated players list
        ship_ship_collisions = check_ship_ship_collisions(intermediate_updated_players)

        final_updated_players =
          handle_ship_ship_collisions(ship_ship_collisions, intermediate_updated_players)

        # Return the final updated lists of bullets and players
        {updated_bullets, final_updated_players}
    end
  end

  # Checks for collision between two circles given their positions and radius
  # Accepts positions in the format `{x, y}` and radius
  # Returns true if there is a collision
  defp collides?({px1, py1}, radius1, {px2, py2}, radius2) do
    distance({px1, py1}, {px2, py2}) < radius1 + radius2
  end

  # Calculates the distance between two points
  defp distance({px1, py1}, {px2, py2}) do
    :math.sqrt(:math.pow(px2 - px1, 2) + :math.pow(py2 - py1, 2))
  end

  # Handles bullet-ship collisions.
  # Accepts a list of collision tuples, identifies bullets that have hit ships, and applies the corresponding damage.
  # Returns the updated lists of bullets and players after removing those that have collided with ships.
  defp handle_bullet_ship_collisions(collisions, bullets, players) do
    # Identify collided bullets and remove them from the active list
    collided_bullets = MapSet.new(Enum.map(collisions, fn {_, bullet, _} -> bullet end))
    updated_bullets = Enum.reject(bullets, &MapSet.member?(collided_bullets, &1))

    # Process collisions to apply damage and update scores
    {final_players, score_updates} = Enum.reduce(collisions, {players, %{}}, &process_collision/2)

    # Update players with new scores
    updated_players = apply_score_updates(final_players, score_updates)

    {updated_bullets, updated_players}
  end

  # Processes individual collisions and updates player health and score records.
  # Accepts a tuple containing the collision details and a tuple of the current player list and score updates.
  # Returns updated players list and score updates after processing the collision.
  defp process_collision({_, bullet, collided_player}, {players, score_updates}) do
    # Apply damage to the collided player
    damaged_player = Player.take_damage(collided_player, bullet.damage)

    # IO.puts("Damaged #{collided_player.name}: New health = #{damaged_player.ship.health}")

    # Update the player list
    updated_players = update_player_in_list(players, damaged_player)

    new_score_updates =
      Map.update(score_updates, bullet.sender, bullet.damage, &(&1 + bullet.damage))

    {updated_players, new_score_updates}
  end

  # Applies accumulated score updates to players.
  # Accepts a current list of players and a map containing score updates for each player.
  # Returns the list of players with updated scores.
  defp apply_score_updates(players, score_updates) do
    Enum.map(players, fn player ->
      if Map.has_key?(score_updates, player.name) do
        Player.inc_score(player, Map.fetch!(score_updates, player.name))
      else
        player
      end
    end)
  end

  # Updates a player in the list with a new version of that player.
  # Takes a list of players and the player who has been updated.
  # Returns a new list of players with the updated player replaced.
  defp update_player_in_list(players, updated_player) do
    Enum.map(players, fn player ->
      if player.name == updated_player.name, do: updated_player, else: player
    end)
  end

  # Processes collisions between ships, each ship's health is reduced by the amount of health the opposing ship has.
  # Accepts a list of collisions and the current list of players, updates the health of each ship involved in collision.
  # Returns an updated list of `Player` structs after applying the collision effects.
  defp handle_ship_ship_collisions(collisions, players) do
    # Filter only valid collisions and ensure both players in the collision are not nil
    valid_collisions =
      Enum.filter(collisions, fn
        {:ship_ship_collision, %Player{} = player1, %Player{} = player2} ->
          player1 != nil and player2 != nil

        _ ->
          false
      end)

    # Create a damage map for each player
    damage_map =
      Enum.reduce(valid_collisions, %{}, fn {:ship_ship_collision, player1, player2}, acc ->
        acc
        |> Map.update(player1, player2.ship.health, &(&1 + player2.ship.health))
        |> Map.update(player2, player1.ship.health, &(&1 + player1.ship.health))
      end)

    # Apply calculated damage and update players
    Enum.map(players, fn player ->
      damage = Map.get(damage_map, player, 0)

      if damage > 0 do
        updated_player = Player.take_damage(player, damage)

        if Ship.alive?(updated_player.ship) do
          # If the ship is still alive, increment the score
          Player.inc_score(updated_player, 250)
        else
          # If the ship is not alive, just update without changing the score
          updated_player
        end
      else
        player
      end
    end)
  end
end
