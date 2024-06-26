defmodule GameServer do
  use GenServer

  @moduledoc """
  Manages the core game server logic.

  Features:
  - Real-time game state management and synchronization across players.
  - Handling of player inputs for actions such as moving, turning, accelerating, braking, and firing.
  - Collision detection and management, including player and projectile interactions.
  - Dynamic updating of game entities such as players and projectiles based on game logic.
  - Comprehensive use of game mechanics like health management, drag effects, and periodic updates through game ticks.
  """

  @derive Jason.Encoder
  defstruct [:players, :projectiles]

  @table GameState
  # Ticks/second
  @tick_rate 20
  # Time in seconds before a dead player is removed from the game state (2 seconds)
  @dead_removal_interval_sec 2000
  @drag_rate 0.1
  @turn_rate :math.pi() / 3 * 0.1
  @health_increment 0.3
  @damage_zone_damage_per_tick @health_increment + 1

  # bounds for the screen (assumption at present, can be done programmatically later)
  @bounds %{
    x: 800,
    y: 800,
    # Creates a damage zone around the map. E.g. A 100px border.
    damage_zone: 100
  }

  @doc "Spawns a new player within the screen boundaries of a specific type and bullet style."
  def spawn_player(name, ship_type, bullet_type),
    do: GenServer.cast({:global, __MODULE__}, {:spawn_player, name, ship_type, bullet_type})

  @doc "Adds a bullet that was fired from the player."
  def add_projectile(bullet), do: GenServer.cast({:global, __MODULE__}, {:add_projectile, bullet})

  @doc "Pings server for debugging."
  def ping(socket) do
    GenServer.cast({:global, __MODULE__}, {:ping, socket})
  end

  @doc "Removes a player from the player list"
  def remove_player(name) do
    GenServer.cast({:global, __MODULE__}, {:remove_player, name})
  end

  @doc """
  Removes players that are not in the presence list. This is to ensure
  that leftover players are removed from the game state.
  """
  def remove_leftover_players(presence_list) do
    GenServer.cast({:global, __MODULE__}, {:remove_leftover_players, presence_list})
  end

  @doc "Accelerates the Player with the given name."
  def accelerate_pressed(name) do
    GenServer.cast({:global, __MODULE__}, {:input, :accelerate, true, name})
  end

  @doc "Stops accelerating the specified player."
  def accelerate_released(name) do
    GenServer.cast({:global, __MODULE__}, {:input, :accelerate, false, name})
  end

  @doc "Starts braking the specified Player."
  def brake_pressed(name) do
    GenServer.cast({:global, __MODULE__}, {:input, :brake, true, name})
  end

  @doc "Stops accelerating the specfied player."
  def brake_released(name) do
    GenServer.cast({:global, __MODULE__}, {:input, :brake, false, name})
  end

  @doc "Turns a specfied player right (clockwise)."
  def turn_right_pressed(name) do
    GenServer.cast({:global, __MODULE__}, {:input, :turn_right, true, name})
  end

  @doc "Stops a specfied player from turning right."
  def turn_right_released(name) do
    GenServer.cast({:global, __MODULE__}, {:input, :turn_right, false, name})
  end

  @doc "Turns a specfied player left (counter-clockwise)."
  def turn_left_pressed(name) do
    GenServer.cast({:global, __MODULE__}, {:input, :turn_left, true, name})
  end

  @doc "Stops a specfied player from turning left."
  def turn_left_released(name) do
    GenServer.cast({:global, __MODULE__}, {:input, :turn_left, false, name})
  end

  @doc "Fires bullets from a specfied player."
  def fire_pressed(name) do
    GenServer.cast({:global, __MODULE__}, {:input, :fire, true, name})
  end

  @doc "Stops firing bullets from a specified player."
  def fire_released(name) do
    GenServer.cast({:global, __MODULE__}, {:input, :fire, false, name})
  end

  @doc "Handles any and all idle movement/velocity. Should be called every tick for any movable entity."
  def move_all(movables) do
    # Filter movables based on in_bounds
    in_bounds_movables =
      Enum.filter(movables, fn movable ->
        %{px: px, py: py} = movable.kinematics
        Boundary.outside?(%{x: px, y: py}, %{x: @bounds.x, y: @bounds.y}) == false
      end)

    # Move the filtered movables
    new_moved_movables =
      Enum.map(in_bounds_movables, fn movable ->
        Movable.Motion.move(movable)
      end)

    # Return the new list of movables after filtering and moving
    new_moved_movables
  end

  @doc "Given a player and player list, replaces players with the same name in the list and returns the new list."
  def update_players(players, updated_player) do
    Enum.map(players, fn p -> if p.name == updated_player.name, do: updated_player, else: p end)
  end

  @doc "Used to update the players inputs, movement, and other features every tick."
  def modify_players(players) do
    if length(players) == 0 do
      # Return the empty list if no players.
      []
    else
      # Modify players as necessary by piping through state modification functions
      Enum.map(players, fn player ->
        # IO.inspect(player)
        if Player.alive?(player) do
          player
          # This handles all player-based inputs
          |> Player.handle_inputs(@turn_rate)
          # This applies current velocity to players
          |> Movable.Motion.move()
          # This causes the ship to slow down over time
          |> Movable.Drag.apply_drag(@drag_rate)
          # This increments the health of the player over time
          |> Player.inc_health(@health_increment)

        else
          # Send the player's score to the all time high score board
          ProjectQuazar.HighScores.add_entry(player.name, player.score)
          # Check player health after a certain time, to decide if they should be removed
          Process.send_after(
            self(),
            {:check_player_health, player.name},
            @dead_removal_interval_sec
          )

          # Apply regular motion to dead/wrecked ships until removed.
          player
          # This applies current velocity to players
          |> Movable.Motion.move()
          # This causes the ship to slow down over time
          |> Movable.Drag.apply_drag(@drag_rate)
        end
      end)
    end
  end

  def start_link(_arg) do
    GenServer.start_link(__MODULE__, nil, name: {:global, __MODULE__})
  end

  @impl true
  def init(_arg) do
    IO.puts("Starting game server with #{inspect(self())}.")

    gamestate =
      case :ets.lookup(@table, __MODULE__) do
        [{_, savedstate}] ->
          savedstate

        [] ->
          %__MODULE__{
            players: [],
            projectiles: []
          }
      end

    :timer.send_interval(round(1000 / @tick_rate), :tick)
    {:ok, gamestate}
  end

  # Main gameplay loop.
  @impl true
  def handle_info(:tick, %__MODULE__{players: players, projectiles: projectiles} = gamestate) do
    new_gamestate = %{
      gamestate
      | players: modify_players(players),
        projectiles: move_all(projectiles)
    }

    {collision_updated_projectiles, collision_updated_players} =
      CollisionHandler.handle_collisions(new_gamestate.projectiles, new_gamestate.players)

    # Check each player for boundary conditions
    live_players =
      Enum.map(collision_updated_players, fn player ->
        cond do
          Boundary.outside?(player, @bounds) ->
            # Kill the player's ship if outside the boundary
            Player.kill_ship(player)

          Boundary.inside_damage_zone?(player, @bounds) ->
            # Damage the player if inside the damage zone
            Player.take_damage(player, @damage_zone_damage_per_tick)

          true ->
            player
        end
      end)

    # Update the game state with the new lists of players and projectiles
    updated_gamestate = %{
      new_gamestate
      | players: live_players,
        projectiles: collision_updated_projectiles
    }

    # Remove dead ships
    # Enum.each(updated_projectiles, fn updated_projectile ->
    #   IO.inspect(updated_projectile)
    # end)
    # Enum.each(updated_players, fn updated_player ->
    #   nil
    #   # IO.inspect(updated_player)
    #   # Game can call boundary checks like so and damage players accordingly
    #   # IO.inspect(Boundary.outside?(player, @bounds))
    #   # IO.inspect(Boundary.inside_damage_zone?(player, @bounds))
    # end)

    # TODO: Game can call boundary checks like so and damage players accordingly
    # IO.inspect(Boundary.outside?(player, @bounds))
    # IO.inspect(Boundary.inside_damage_zone?(player, @bounds))

    # IO.puts("tick")

    # Broadcast gamestate to each client
    Phoenix.PubSub.broadcast(
      ProjectQuazar.PubSub,
      "game_state:updates",
      {:state_updated, new_gamestate}
    )

    :ets.insert(@table, {__MODULE__, updated_gamestate})
    {:noreply, updated_gamestate}
  end

  @impl true
  def handle_call(:update, _from, gamestate) do
    {:reply, gamestate}
  end

  @doc """
  Checks the health of the player with the given name. If the player's health is below 0, the player is removed from the game state.
  """
  def handle_info({:check_player_health, player_name}, %__MODULE__{players: players} = gamestate) do
    case Enum.find(players, fn player -> player.name == player_name end) do
      nil ->
        # Player might have been removed already
        {:noreply, gamestate}

      player ->
        if Player.alive?(player) do
          # Player recovered
          {:noreply, gamestate}
        else
          # Player still has health below 0, remove them
          new_players = Enum.reject(players, fn p -> p.name == player_name end)
          new_gamestate = %{gamestate | players: new_players}
          {:noreply, new_gamestate}
        end
    end
  end

  # Spawns a new player within the screen boundaries of a specific type and bullet style.
  @impl true
  def handle_cast(
        {:spawn_player, name, type, bullet_type},
        %__MODULE__{players: players} = gamestate
      ) do
    player_ship = Ship.random_ship(type, bullet_type, @bounds)
    new_players = [Player.new_player(name, player_ship, @bounds) | players]
    {:noreply, %{gamestate | players: new_players}}
  end

  # Debugging ping function.
  @impl true
  def handle_cast({:ping, pid}, state) do
    IO.inspect(pid)
    {:noreply, state}
  end

  # Adds a bullet that was fired from the player.
  @impl true
  def handle_cast({:add_projectile, bullet}, %{projectiles: projectiles} = state) do
    # Add the new bullet to the projectile list
    new_projectiles = [bullet | projectiles]
    {:noreply, %{state | projectiles: new_projectiles}}
  end

  # Removes a player from the game state.
  @impl true
  def handle_cast({:remove_player, name}, %{players: players} = state) do
    new_players = Enum.reject(players, fn player -> player.name == name end)
    new_state = %{state | players: new_players}
    {:noreply, new_state}
  end

  # Removes players that are not in the presence list. This is to ensure
  # that leftover players are removed from the game state.
  @impl true
  def handle_cast({:remove_leftover_players, presence_list}, %{players: players} = state) do
    players
    |> Enum.map(& &1.name)
    |> Enum.each(fn player ->
      if !Map.has_key?(presence_list, player) do
        GameServer.remove_player(player)
      end
    end)

    {:noreply, state}
  end

  # This handles any user input events and updates the associated player with the inputs.
  @impl true
  def handle_cast(
        {:input, input_type, pressed_or_released, username},
        %{players: players} = state
      ) do
    # Update the passed players input mappings
    new_players =
      Enum.map(players, fn player ->
        if player.name == username do
          Player.update_inputs(player, input_type, pressed_or_released)
        else
          player
        end
      end)

    # Return updated input state
    new_state = %{state | players: new_players}
    {:noreply, new_state}
  end
end
