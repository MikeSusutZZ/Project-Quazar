defmodule GameServer do
  use GenServer

  @derive Jason.Encoder
  defstruct [:players, :projectiles]

  @table GameState
  # Ticks/second
  @tick_rate 1
  # Ticks/second
  # @tick_rate 20
  @accel_rate 0.25
  @drag_rate 0.2
  @turn_rate :math.pi() / 3 * 0.1
  @health_increment 1
  @score_increment 100
  @dead_time 2000

  # bounds for the screen (assumption at present, can be done programmatically later)
  @bounds %{
    x: 800,
    y: 800,
    # Creates a damage zone around the map. E.g. A 100px border.
    damage_zone: 100
  }

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

    # Collision detection and handling to be used by Michelle
    CollisionHandler.handle_collisions(projectiles, players)

    # Remove dead ships
    # Enum.each(projectiles, fn projectile -> IO.inspect(projectile) end)

    Enum.each(players, fn player ->
      nil
      # IO.inspect(player)
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

    :ets.insert(@table, {__MODULE__, new_gamestate})
    {:noreply, new_gamestate}
  end

  @impl true
  def handle_call(:update, _from, gamestate) do
    {:reply, gamestate}
  end

  def spawn_player(name, ship_type, bullet_type),
    do: GenServer.cast({:global, __MODULE__}, {:spawn_player, name, ship_type, bullet_type})

  @impl true
  def handle_cast(
        {:spawn_player, name, type, bullet_type},
        %__MODULE__{players: players} = gamestate
      ) do
    player_ship = Ship.random_ship(type, bullet_type, @bounds)
    new_players = [Player.new_player(name, player_ship, @bounds) | players]
    {:noreply, %{gamestate | players: new_players}}
  end

  def move_all(movables), do: Enum.map(movables, fn movable -> Movable.Motion.move(movable) end)

  @doc "Used for testing how players can interact/move."
  def modify_players(players) do
    if length(players) == 0 do
      # spawn_player("Bill", :destroyer, :light) # Spawns a player
      # Return empty list, cast will update players
      []
    else
      # Modify players as necessary by piping through state modification functions
      Enum.map(players, fn player ->
        IO.inspect(player)

        if Player.alive?(player) do
          player
          # Player.take_damage(player, 10) |>
          # IO.inspect(player)
          |> Player.inc_score(@score_increment)
          # |> Movable.Motion.accelerate(1) # To call protocol impl use Movable.Motion functions
          |> Movable.Motion.move()
          # causes the ship to slow down over time
          |> Movable.Drag.apply_drag(@drag_rate)
          # increments the health of the player
          |> Player.inc_health(@health_increment)
        else
          Process.send_after(self(), {:check_player_health, player.name}, @dead_time)
          player
        end
      end)
    end
  end

  @doc """
  Checks the health of the player with the given name. If the player's health is below 0, the player is removed from the game state.
  """
  def handle_info({:check_player_health, player_name}, %__MODULE__{players: players} = gamestate) do
    case Enum.find(players, fn player -> player.name == player_name end) do
      nil ->
        {:noreply, gamestate}  # Player might have been removed already

      player ->
        if Player.alive?(player) do
          {:noreply, gamestate}  # Player recovered
        else
          # Player still has health below 0, remove them
          new_players = Enum.reject(players, fn p -> p.name == player_name end)
          new_gamestate = %{gamestate | players: new_players}
          {:noreply, new_gamestate}
        end
    end
  end



  # Debugging ping function.
  @impl true
  def handle_cast({:ping, pid}, state) do
    IO.inspect(pid)
    {:noreply, state}
  end

  # Pings server for debugging.
  def ping(socket) do
    GenServer.cast({:global, __MODULE__}, {:ping, socket})
  end

  # Accelerate the Player with the given name.
  @impl true
  def handle_cast({:accel, name}, %{players: players} = state) do
    player = Enum.find(players, fn player -> player.name == name end)

    if player == :default do
      {:noreply, state}
    else
      updated_players = update_players(players, Movable.Motion.accelerate(player, @accel_rate))
      {:noreply, %{state | :players => updated_players}}
    end
  end

  @doc """
  Fires a bullet from the player with the given name.
  """
  @impl true
  def handle_cast({:fire, name}, %{players: players, projectiles: projectiles} = state) do
    # Find the player who is firing
    player = Enum.find(players, fn player -> player.name == name end)

    case Ship.fire(player.ship, player.name) do
      {:ok, bullet} ->
        # Add the new bullet to the projectile list
        new_projectiles = [bullet | projectiles]
        {:noreply, %{state | projectiles: new_projectiles}}

      :error ->
        {:noreply, state}
    end
  end

  @doc "Fire a bullet from the player with the given name."
  def fire(name) do
    GenServer.cast({:global, __MODULE__}, {:fire, name})
  end

  # Accelerate the Player with the given name.
  def accelerate_player(name) do
    GenServer.cast({:global, __MODULE__}, {:accel, name})
  end

  # Given a player and player list, replaces players with the same name in the list and returns the new list.
  def update_players(players, updated_player) do
    Enum.map(players, fn p -> if p.name == updated_player.name, do: updated_player, else: p end)
  end

  # Rotates the ship with the given name in the given direction.
  def rotate_player(name, dir) do
    GenServer.cast({:global, __MODULE__}, {:rotate, name, dir})
  end

  # Rotates the ship with the given name in the given direction
  @impl true
  def handle_cast({:rotate, name, dir}, %{players: players} = state) do
    player = Enum.find(players, fn player -> player.name == name end)

    if player == :default do
      {:noreply, state}
    else
      if dir == :cw || dir == :ccw do
        updated_players =
          update_players(players, Movable.Rotation.rotate(player, @turn_rate, dir))

        {:noreply, %{state | :players => updated_players}}
      else
        {:noreply, state}
      end
    end
  end

  @doc "Removes a player from the game state."
  @impl true
  def handle_cast({:remove_player, name}, %{players: players} = state) do
    new_players = Enum.reject(players, fn player -> player.name == name end)
    new_state = %{state | players: new_players}
    {:noreply, new_state}
  end

  def remove_player(name) do
    GenServer.cast({:global, __MODULE__}, {:remove_player, name})
  end

  @doc """
  Removes players that are not in the presence list. This is to ensure
  that leftover players are removed from the game state.
  """
  @impl true
  def handle_cast({:remove_leftover_players, presence_list}, %{players: players} = state) do
    state.players
    |> Enum.map(& &1.name)
    |> Enum.each(fn player ->
      if !Map.has_key?(presence_list, player) do
        GameServer.remove_player(player)
      end
    end)

    {:noreply, state}
  end

  def remove_leftover_players(presence_list) do
    GenServer.cast({:global, __MODULE__}, {:remove_leftover_players, presence_list})
  end
end
