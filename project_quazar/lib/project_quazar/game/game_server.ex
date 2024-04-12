defmodule GameServer do
  use GenServer

  defstruct [:players, :projectiles]

  @table GameState
  @tick_rate 1 # Ticks/second
  @accel_rate 1
  @turn_rate :math.pi() / 3

  def start_link(_arg) do
    GenServer.start_link(__MODULE__, nil, name: {:global, __MODULE__})
  end

  @impl true
  def init(_arg) do
    IO.puts("Starting game server with #{inspect(self())}.")

    gamestate = case :ets.lookup(@table, __MODULE__) do
      [{_, savedstate}] -> savedstate
      [] -> %__MODULE__{
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
    new_gamestate = %{gamestate | players: modify_players(players), projectiles: move_all(projectiles)}
    Enum.each(players, fn player -> IO.inspect(player) end)
    IO.puts("bonk")
    :ets.insert(@table, {__MODULE__, new_gamestate})
    Phoenix.PubSub.broadcast(ProjectQuazar.PubSub, "gamestate", {:new_gamestate, new_gamestate})
    {:noreply, new_gamestate}
  end

  @impl true
  def handle_call(:update, _from, gamestate) do
    {:reply, gamestate}
  end

  def spawn_player(name), do: GenServer.cast({:global, __MODULE__}, {:spawn_player, name})

  @impl true
  def handle_cast({:spawn_player, name}, %__MODULE__{players: players} = gamestate) do
    player_ship = Ship.new_ship(0, 0, 0, 100, 10)
    new_players = [Player.new_player(name, player_ship) | players]
    {:noreply, %{gamestate | players: new_players}}
  end

  def move_all(movables), do: Enum.map(movables, fn movable -> Movable.Motion.move(movable) end)

  @doc "Used for testing how players can interact/move."
  def modify_players(players) do
    if length(players) == 0 do
      # spawn_player("Bill") # Spawns a player
      [] # Return empty list, cast will update players
    else
      # Modify players as necessary by piping through state modification functions
      Enum.map(players, fn player ->
        if Player.alive?(player) do
          # Player.take_damage(player, 10) |>
          Player.inc_score(player, 100)
          # |> Movable.Motion.accelerate(1) # To call protocol impl use Movable.Motion functions
          |> Movable.Motion.move()
        else
          Player.respawn(player, 0, 0, 0)
        end
      end)
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
    if player == :default
    do
      {:noreply, state}
    else
      updated_players = update_players(players, Movable.Motion.accelerate(player, @accel_rate))
      {:noreply, %{state | :players => updated_players}}
    end
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
    if player == :default
    do
      {:noreply, state}
    else
      if dir == :cw || dir == :ccw
      do
        updated_players = update_players(players, Movable.Motion.rotate(player, @turn_rate, dir))
        {:noreply, %{state | :players => updated_players}}
      else
        {:noreply, state}
      end
    end
  end


end
