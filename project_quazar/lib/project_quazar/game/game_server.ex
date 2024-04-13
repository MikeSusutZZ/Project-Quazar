defmodule GameServer do
  use GenServer

  defstruct [:players, :projectiles]

  @table GameState
  @tick_rate 1 # Ticks/second

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

    # Collision detection and handling
    CollisionHandler.handle_collisions(projectiles, players)

    # Remove dead ships
    Enum.each(projectiles, fn projectile -> IO.inspect(projectile) end)
    Enum.each(players, fn player -> IO.inspect(player) end)
    IO.puts("bonk")
    :ets.insert(@table, {__MODULE__, new_gamestate})
    {:noreply, new_gamestate}
  end

  @impl true
  def handle_call(:update, _from, gamestate) do
    {:reply, gamestate}
  end

  def spawn_player(name), do: GenServer.cast({:global, __MODULE__}, {:spawn_player, name})

  @impl true
  def handle_cast({:spawn_player, name}, %__MODULE__{players: players} = gamestate) do
    player_ship = Ship.new_ship(0, 0, 0, 100, :destroyer)
    new_players = [Player.new_player(name, player_ship) | players]
    {:noreply, %{gamestate | players: new_players}}
  end

  def move_all(movables), do: Enum.map(movables, fn movable -> Movable.Motion.move(movable) end)

  @doc "Used for testing how players can interact/move."
  def modify_players(players) do
    if length(players) == 0 do
      spawn_player("Bill") # Spawns a player
      [] # Return empty list, cast will update players
    else
      # Modify players as necessary by piping through state modification functions
      Enum.map(players, fn player ->
        if Player.alive?(player) do
          Player.take_damage(player, 10)
          |> Player.inc_score(100)
          |> Movable.Motion.accelerate(1) # To call protocol impl use Movable.Motion functions
          |> Movable.Motion.move()
        else
          Player.respawn(player, 0, 0, 0)
        end
      end)
    end
  end

end
