defmodule ProjectQuazar.HighScores.ETSWrapper do
  # alias ElixirSense.Plugins.Phoenix
  use GenServer

  @table_name :high_scores

  # client

  # called by the application supervisor
  def start_link(_args \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  # call this to insert a new entry into the high scores table
  def insert_entry(username, score) do
    GenServer.call(__MODULE__, {:insert_entry, username, score})
  end

  # call this to fetch the top scores
  def fetch_top_scores() do
    GenServer.call(__MODULE__, :fetch_top_scores)
  end

  # server

  # called by the GenServer, ets table created upon initialization
  def init(:ok) do
    :ets.new(@table_name, [:ordered_set, :public, :named_table, { :keypos, 2 }])
    {:ok, %{}}
  end

  # handle the insert_entry call
  # returns {:ok, entry} if the entry was inserted successfully
  # returns {:error, :username_exists} if the username already exists
  def handle_call({:insert_entry, username, score}, _from, state) do
    current_datetime = DateTime.utc_now()
    entry = {score, username, current_datetime}

    case :ets.lookup(@table_name, username) do
      [] ->
        :ets.insert(@table_name, entry)
        Phoenix.PubSub.broadcast(ProjectQuazar.PubSub, "high_scores:updates", :scores_updated)
        IO.puts("Broadcasted scores_updated message")
        {:reply, {:ok, entry}, state}
      _ ->
        {:reply, {:error, :username_exists}, state}
    end
  end

  # handle the fetch_top_scores call
  # returns {:ok, top_scores} where top_scores is a list of the top scores
  # sorted in descending order
  def handle_call(:fetch_top_scores, _from, state) do
    top_scores = :ets.tab2list(@table_name)
                |> Enum.sort_by(&elem(&1, 0), :desc)
                |> Enum.map(fn {score, username, _datetime} ->
                     %{player: username, score: score}
                   end)

    {:reply, {:ok, top_scores}, state}
  end
end
