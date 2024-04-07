defmodule ProjectQuazar.HighScores do
  alias ProjectQuazar.HighScores.ETSWrapper

  # calls the ETSWrapper to insert a new entry into the high scores table
  def add_entry(username, score) do
    ETSWrapper.insert_entry(username, score)
  end

  # calls the ETSWrapper to fetch the top scores
  def fetch_top_scores() do
    ETSWrapper.fetch_top_scores()
  end
end
