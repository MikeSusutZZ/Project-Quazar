defmodule GameServer do
  use GenServer

  @derive Jason.Encoder
  defstruct [:players, :projectiles]

  @table GameState
  # Ticks/second
  @tick_rate 20
  @drag_rate 0.2
  @turn_rate :math.pi() / 3 * 0.1
  @health_increment 1

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
  def move_all(movables), do: Enum.map(movables, fn movable -> Movable.Motion.move(movable) end)

  @doc "Given a player and player list, replaces players with the same name in the list and returns the new list."
  def update_players(players, updated_player) do
    Enum.map(players, fn p -> if p.name == updated_player.name, do: updated_player, else: p end)
  end

  @doc "Used to update the players inputs, movement, and other features every tick."
  def modify_players(players) do
    if length(players) == 0 do
      [] # Return the empty list if no players.
    else
      # Modify players as necessary by piping through state modification functions
      Enum.map(players, fn player ->
        IO.inspect(player)
        if Player.alive?(player) do
          player
          |> Player.handle_inputs(@turn_rate)       # This handles all player-based inputs
          |> Movable.Motion.move()                  # This applies current velocity to players
          |> Movable.Drag.apply_drag(@drag_rate)    # This causes the ship to slow down over time
          |> Player.inc_health(@health_increment)   # This increments the health of the player over time
        else
          player # Apply regular motion to dead/wrecked ships until removed.
          |> Movable.Motion.move()                  # This applies current velocity to players
          |> Movable.Drag.apply_drag(@drag_rate)    # This causes the ship to slow down over time
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

    {updated_projectiles, updated_players} = CollisionHandler.handle_collisions(new_gamestate.projectiles, new_gamestate.players)

    # Update the game state with the new lists of players and projectiles
    updated_gamestate = %{new_gamestate | players: updated_players, projectiles: updated_projectiles}

    # Remove dead ships
    Enum.each(updated_projectiles, fn updated_projectile ->
      IO.inspect(updated_projectile)
    end)
    Enum.each(updated_players, fn updated_player ->
      nil
      # IO.inspect(updated_player)
      # Game can call boundary checks like so and damage players accordingly
      # IO.inspect(Boundary.outside?(player, @bounds))
      # IO.inspect(Boundary.inside_damage_zone?(player, @bounds))
    end)


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
  def handle_cast({:input, input_type, pressed_or_released, username}, %{players: players} = state) do
    # Update the passed players input mappings
    new_players = Enum.map(players, fn player ->
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
