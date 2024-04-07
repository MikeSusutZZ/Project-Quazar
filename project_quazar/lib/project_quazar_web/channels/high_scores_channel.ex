defmodule ProjectQuazarWeb.HighScoresChannel do
  use Phoenix.Channel
  alias ProjectQuazar.HighScores

  # called when the client joins the channel
  def join("high_scores:updates", _payload, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  # call this after the client joins the channel
  def handle_info(:after_join, socket) do
    top_scores = fetch_top_scores()
    push(socket, "initial_high_scores", %{scores: top_scores})
    {:noreply, socket}
  end

  # call this when the client sends a message to add a score
  # also broadcasts the updated high scores to all clients
  def handle_in("add_score", %{"username" => username, "score" => score}, socket) do
    case HighScores.add_entry(username, score) do
      {:ok, _entry} ->
        top_scores = fetch_top_scores()
        broadcast!(socket, "updated_high_scores", %{scores: top_scores})
        {:reply, {:ok, %{scores: top_scores}}, socket}
      {:error, _} = error ->
        {:reply, error, socket}
    end
  end

  # private method that fetches the top scores and formats them for transmission
  defp fetch_top_scores() do
    {:ok, top_scores} = HighScores.fetch_top_scores()
    Enum.map(top_scores, fn {score, username, timestamp} ->
      %{score: score, username: username, timestamp: timestamp}
    end)
  end

end
