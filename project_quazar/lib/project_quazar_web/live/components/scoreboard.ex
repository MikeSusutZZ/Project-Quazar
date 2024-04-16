defmodule ProjectQuazarWeb.Scoreboard do
  use ProjectQuazarWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="scoreboard-position">
      <div class="base-container">

        <h2 class="title">Live Scoreboard</h2>

        <div class="user-list-container">
          <%= for {user_id, metadata} <- @users do %>

            <%= if user_id == @current_user do %>
              <div class="user-item-base">
                <span class="user-id"><%= user_id %></span>
                <span class="user-points"><%= metadata[:points] %></span>
              </div>

            <% else %>
              <div class="user-item-base">
                <span class="user-id"><%= user_id %></span>
                <span class="user-points"><%= metadata[:points] %></span>
              </div>
            <% end %>

          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
