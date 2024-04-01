defmodule GameServer do
  use GenServer

  defstruct [:ships, :projectiles]

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
        ships: [],
        projectiles: []
      }
    end

    :timer.send_interval(round(1000 / @tick_rate), :tick)
    {:ok, gamestate}
  end

  # Main gameplay loop.
  @impl true
  def handle_info(:tick, %__MODULE__{ships: ships, projectiles: projectiles} = gamestate) do
    new_gamestate = %{gamestate | ships: move_all(ships), projectiles: move_all(projectiles)}
    Enum.each(ships, fn ship -> IO.inspect(ship) end)
    :ets.insert(@table, {__MODULE__, new_gamestate})
    {:noreply, new_gamestate}
  end

  @impl true
  def handle_call(:update, _from, gamestate) do
    {:reply, gamestate}
  end

  def spawn_ship(), do: GenServer.cast({:global, __MODULE__}, :spawn_ship)

  @impl true
  def handle_cast(:spawn_ship, %__MODULE__{ships: ships} = gamestate) do
    new_ships = [Movable.new_movable(0, 0, 1, 1, 0) | ships]
    {:noreply, %{gamestate | ships: new_ships}}
  end

  def move_all(movables), do: Enum.map(movables, fn movable -> Movable.move(movable) end)

end
