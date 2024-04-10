defmodule ProjectQuazarWeb.AllTimeHighScores do
  use ProjectQuazarWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="high-scores-container">
      <h1>All-Time High Scores</h1>
      <div id="scores">
        <ul>
          <%= for score <- @top_scores do %>
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
end
