defmodule ProjectQuazarWeb.GameOver do
  use ProjectQuazarWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div id="gameOverContainer" class="fixed inset-0 bg-black flex flex-col items-center justify-center">
      <!-- Text elements with fade-in effect, each with a unique id -->
      <div id="destroyedMessage" class="fade-in-text text-red-500 text-center text-6xl transition-opacity duration-2000 delay-2000 ease-in-out" phx-hook="FadeIn">
        Your ship has been destroyed
      </div>
      <div id="gameOverMessage" class="fade-in-text text-red-500 text-center text-5xl mt-4 transition-opacity duration-2000 delay-3000 ease-in-out" phx-hook="FadeIn">
        Your score:
        <%= for player <- @players do %>
          <%= if player.name == @current_user do %>
            <% player.score %>
          <% end %>
        <% end %>
      </div>
      <!-- Button without fade-in effect -->
      <button class="mt-5 bg-gray-700 text-white py-2 px-4 rounded" phx-click="show_start_game">
        Return to Main Menu
      </button>
    </div>
    """
  end
end
