defmodule ProjectQuazarWeb.Start do
  use ProjectQuazarWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="bg-gray-900 p-6 rounded-lg shadow-lg max-w-lg mx-auto">
      <h2 class="text-white text-4xl font-bold text-center mb-8">Project Quazar</h2>
      <div class="flex flex-col space-y-6 items-center">
        <button phx-click="show_start_game" class="bg-green-500 hover:bg-green-700 text-white font-bold py-3 px-6 rounded-lg text-lg">Start Game</button>
        <button phx-click="show_help" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-3 px-6 rounded-lg text-lg">How To Play</button>
      </div>
    </div>
    """
  end
end
