defmodule GamePrototype do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def add(user) do
    GenServer.cast(__MODULE__, {:add, user})
  end

  def update_user(user, value) do
    GenServer.cast(__MODULE__, {:update_user, user, value})
  end

  def get_users() do
    GenServer.call(__MODULE__, :get_users)
  end

  def remove_user(name) do
    GenServer.cast(__MODULE__, {:remove_user, name})
  end

  @impl true
  def init(_) do
    {:ok, {[], 0}}
  end

  @impl true
  def handle_cast({:add, user}, {users, count}) do
    {:noreply, {[user | users], count}}
  end

  @impl true
  def handle_call(:get_users, _from, {users, count}) do
    updated_count = count + 1
    {:reply, {users, updated_count}, {users, updated_count}}
  end

  @impl true
  def handle_cast({:update_user, user, value}, {users, count}) do
    updated_users =
      Enum.map(users, fn %{name: name} = u ->
        if name == user do
          %{u | key: value}
        else
          u
        end
      end)

    {:noreply, {updated_users, count}}
  end

  @impl true
  def handle_cast({:remove_user, name}, {users, count}) do
    updated_users = Enum.reject(users, &(&1.name == name))
    {:noreply, {updated_users, count}}
  end
end

# GamePrototype.start()
# GamePrototype.add(%{name: "Alice", value: "some_value"})
# GamePrototype.get_users()
# GamePrototype.update_user("Alice", "Potato")
