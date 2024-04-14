defmodule ProjectQuazarWeb.AllTimeHighScores do
  use ProjectQuazarWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="base-container">

      <h1 class="title">All-Time Score Leaderboard</h1>

      <div id="user-list-container">
        <%= if Enum.empty?(@top_scores) do %>
          <p class="no-scores">No scores yet!</p>

        <% else %>

            <%= for score <- @top_scores do %>
              <div class="user-item-base mt-4">
                <span class="user-id"><%= score.player %></span>
                <span class="user-points"><%= score.score %></span>
              </div>
            <% end %>

        <% end %>
      </div>
    </div>
    """
  end
end
