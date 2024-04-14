defmodule ProjectQuazarWeb.AllTimeHighScores do
  use ProjectQuazarWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="base-container">
      <h1 class="title">Score Leaderboard</h1>

      <div id="user-list-container">
        <%= if Enum.empty?(@top_scores) do %>
          <p class="no-scores">No scores yet!</p>

        <%= else %>
          <ul>
            <%= for score <- @top_scores do %>
              <li>
                <span class="text-lg"><%= score.player %></span>
                <span class="text-xl text-green-600"><%= score.score %></span>
              </li>
            <% end %>
          </ul>
        <% end %>
      </div>

    </div>
    """
  end
end
