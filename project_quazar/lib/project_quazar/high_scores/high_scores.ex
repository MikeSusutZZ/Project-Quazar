defmodule ProjectQuazar.HighScores do
  @moduledoc """
  Module for managing high scores
  """
  alias ProjectQuazar.HighScores.ETSWrapper

  @doc """
  Calls the ETSWrapper to add an entry to the high scores table
  """
  def add_entry(username, score) do
    ETSWrapper.insert_entry(username, score)
  end

  @doc """
  Calls the ETSWrapper to fetch the top scores from the high scores table
  """
  def fetch_top_scores() do
    ETSWrapper.fetch_top_scores()
  end
end
