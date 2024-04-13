defmodule ProjectQuazar.HighScores.ETSWrapper do
  @moduledoc """
  A GenServer module that uses ETS (Erlang Term Storage) operations for high scores.
  """

  use GenServer

  @table_name :high_scores

  @doc """
  Starts the GenServer with the given arguments.
  """
  def start_link(_args \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Inserts a new entry into the ETS table.
  """
  def insert_entry(username, score) do
    GenServer.call(__MODULE__, {:insert_entry, username, score})
  end

  @doc """
  Fetches the top scores from the ETS table.
  """
  def fetch_top_scores() do
    GenServer.call(__MODULE__, :fetch_top_scores)
  end

  @doc """
  Initializes the GenServer and creates a new ETS table if it doesn't already exist.
  """
  def init(:ok) do
    unless :ets.info(@table_name) do
      :ets.new(@table_name, [:ordered_set, :public, :named_table, {:keypos, 2}])
    end

    {:ok, %{}}
  end

  @doc """
  Handles the `insert_entry` call. Inserts a new entry or updates an existing one if the new score is higher.
  """
  def handle_call({:insert_entry, username, score}, _from, state) do
    current_datetime = DateTime.utc_now()
    entry = {score, username, current_datetime}

    case :ets.lookup(@table_name, username) do
      [] ->
        broadcast_and_insert_entry(entry)
        {:reply, {:ok, entry}, state}

      [{existing_score, _, _} = _existing_entry] when score > existing_score ->
        :ets.delete(@table_name, username)
        broadcast_and_insert_entry(entry)
        {:reply, {:ok, entry}, state}

      _ ->
        {:reply, {:ok, :no_update}, state}
    end
  end

  @doc """
  Handles the `fetch_top_scores` call. Returns the top scores from the ETS table.
  """
  def handle_call(:fetch_top_scores, _from, state) do
    {:reply, {:ok, top_scores()}, state}
  end

  @doc """
  Inserts an entry into the ETS table and broadcasts a `scores_updated` message.
  """
  defp broadcast_and_insert_entry(entry) do
    :ets.insert(@table_name, entry)

    Phoenix.PubSub.broadcast(
      ProjectQuazar.PubSub,
      "high_scores:updates",
      {:scores_updated, top_scores()}
    )

    IO.puts("Broadcasted scores_updated message")
  end

  @doc """
  Fetches and formats the top scores from the ETS table.
  """
  defp top_scores do
    :ets.tab2list(@table_name)
    |> Enum.sort_by(&elem(&1, 0), :desc)
    |> Enum.map(fn {score, username, _datetime} ->
      %{player: username, score: score}
    end)
  end
end
