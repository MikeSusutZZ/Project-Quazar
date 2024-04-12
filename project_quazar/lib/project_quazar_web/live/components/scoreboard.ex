# scoreboard.ex
defmodule ProjectQuazarWeb.Scoreboard do
  use ProjectQuazarWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="bg-gray-900 p-6 rounded-lg shadow-lg max-w-md mx-auto">
      <h2 class="text-white text-3xl font-bold text-center mb-6">Live Scoreboard</h2>
      <div class="flex flex-col space-y-4">
        <%= for {user_id, metadata} <- @users do %>
          <%= if user_id == @current_user do %>
            <div class="flex justify-between items-center p-4 bg-green-600 rounded-lg text-white font-semibold transition duration-300 ease-in-out transform hover:scale-105">
              <span class="text-lg"><%= user_id %></span>
              <span class="text-xl text-yellow-400"><%= metadata[:points] %></span>
            </div>
          <% else %>
            <div class="flex justify-between items-center p-4 bg-gray-800 rounded-lg text-white font-semibold transition duration-300 ease-in-out transform hover:scale-105">
              <span class="text-lg"><%= user_id %></span>
              <span class="text-xl text-yellow-400"><%= metadata[:points] %></span>
            </div>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end
end
