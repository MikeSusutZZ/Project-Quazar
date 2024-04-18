defmodule ProjectQuazarWeb.Scoreboard do
  use ProjectQuazarWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="scoreboard-position">
      <div class="base-container">

        <h2 class="title">Live Scoreboard</h2>

        <div class="user-list-container">
          <%= for player <- @players do %>

            <%= if player.name == @current_user do %>
              <div class="user-item-base">
                <span class="user-id"><%= player.name %></span>
                <span class="user-points"><%= player.score %></span>
              </div>

            <% else %>
              <div class="user-item-base">
                <span class="user-id"><%= player.name %></span>
                <span class="user-points"><%= player.score %></span>
              </div>
            <% end %>

          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
