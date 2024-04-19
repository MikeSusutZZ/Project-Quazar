defmodule ProjectQuazarWeb.GameOver do
  use ProjectQuazarWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div id="gameOverContainer" class="fixed inset-0 bg-black flex flex-col items-center justify-center">
      <!-- Text elements with fade-in effect, each with a unique id -->
      <div id="destroyedMessage" class="fade-in-text text-red-500 text-center text-6xl transition-opacity duration-2000 delay-5000 ease-in-out" phx-hook="FadeIn">
        Your ship has been destroyed
      </div>
      <div id="gameOverMessage" class="fade-in-text text-red-500 text-center text-5xl mt-4 transition-opacity duration-2000 delay-5000 ease-in-out" phx-hook="FadeIn">
        Your score:
        <%= @player_score %>
      </div>
      <!-- Button without fade-in effect -->
      <button class="mt-5 bg-gray-700 text-white py-2 px-4 rounded" phx-click="game_over_to_lobby">
        Return to Main Menu
      </button>
    </div>
    """
  end
end
