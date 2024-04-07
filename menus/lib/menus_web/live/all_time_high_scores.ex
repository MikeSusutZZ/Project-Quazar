defmodule MenusWeb.AllTimeHighScoresLive do
  use Phoenix.LiveView

  @impl true
  def mount(_session, _params, socket) do
    high_scores = fetch_high_scores()
    {:ok, assign(socket, :high_scores, high_scores)}
  end

  @impl true
  def render(assigns) do
    ~L"""

    <div class="high-scores-container">

      <h1>All-Time High Scores</h1>

      <div id="scores">
        <ul>
          <%= for score <- @high_scores do %>
            <li>
              <span class="player"><%= score.player %></span>
              <span class="score"><%= score.score %></span>
            </li>
          <% end %>
        </ul>
      </div>

    </div>
    """
  end

  # Simulates a call to the backend for high scores
  defp fetch_high_scores do
    [
      %{player: "Alice", score: 12345},
      %{player: "Bob", score: 11300},
      %{player: "Charlie", score: 11000}
    ]
  end
end
