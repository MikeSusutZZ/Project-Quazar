defmodule ProjectQuazarWeb.GameBoard do
  use ProjectQuazarWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="fixed top-11 left-4">
    <canvas id="main" data-game-state={"#{Jason.encode!(@game_state)}"} data-name={"#{Jason.encode!(@current_user)}"} phx-hook="GameBoardHook">Pubsub Prototype</canvas>
    </div>
    """
  end
end
