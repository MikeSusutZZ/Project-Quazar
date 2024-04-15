defmodule ProjectQuazarWeb.Start do
  use ProjectQuazarWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="container">
      <h2 class="startup-title">Project Quazar</h2>
      <div class="flex flex-col space-y-6 items-center">
        <button phx-click="show_start_game" class="button-primary">Start Game</button>
        <button phx-click="show_help" class="button-secondary">How To Play</button>
      </div>
    </div>
    """
  end
end
