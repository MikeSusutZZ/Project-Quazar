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
    new_gamestate = %{gamestate | players: move_all(players), projectiles: move_all(projectiles)}
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
    player_ship = Ship.new_ship(0, 0, 0, 100, 10)
    new_players = [Player.new_player(name, player_ship) | players]
    {:noreply, %{gamestate | players: new_players}}
  end

  def move_all(movables), do: Enum.map(movables, fn movable -> Movable.Motion.move(movable) end)

end
