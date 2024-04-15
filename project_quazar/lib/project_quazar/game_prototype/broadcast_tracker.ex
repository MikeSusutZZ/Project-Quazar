defmodule BroadcastTracker do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def toggle() do
    GenServer.cast(__MODULE__, :toggle)
  end

  def set_owner(new_owner) do
    GenServer.cast(__MODULE__, {:set_owner, new_owner})
  end

  def is_broadcasting() do
    GenServer.call(__MODULE__, :is_broadcasting)
  end

  def owner() do
    GenServer.call(__MODULE__, :owner)
  end

  @impl true
  def init(_) do
    {:ok, {"", false}}
  end

  @impl true
  def handle_cast(:toggle, {owner, is_broadcasting}) do
    {:noreply, {owner, !is_broadcasting}}
  end

  @impl true
  def handle_cast({:set_owner, new_owner}, {_owner, is_broadcasting}) do
    {:noreply, {new_owner, is_broadcasting}}
  end

  @impl true
  def handle_call(:is_broadcasting, _from, {owner, is_broadcasting}) do
    {:reply, is_broadcasting, {owner, is_broadcasting}}
  end

  @impl true
  def handle_call(:owner, _from, {owner, is_broadcasting}) do
    {:reply, owner, {owner, is_broadcasting}}
  end
end
