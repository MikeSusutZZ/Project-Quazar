defmodule ProjectQuazarWeb.Start do
  use ProjectQuazarWeb, :live_component

  def mount(_params, _session, socket) do
    {:ok, assign(socket, show_high_scores: false)}
  end

  def render(assigns) do
    ~H"""
    <div class="bg-gray-900 p-6 rounded-lg shadow-lg max-w-md mx-auto">
      <h2 class="text-white text-3xl font-bold text-center mb-6">Project Quazar</h2>
      <div class="flex flex-col space-y-4 items-center">
        <button phx-click="show_start_game" class="bg-green-500 hover:bg-green-700 text-white font-bold py-2 px-4 rounded">Start Game</button>
        <button phx-click="show_high_scores" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">All Time High Scores</button>
      </div>
    </div>
    """
  end

  def handle_event("show_high_scores", _value, socket) do
    {:noreply, assign(socket, show_high_scores: true)}
  end
end
