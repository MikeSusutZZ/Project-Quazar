defmodule ProjectQuazarWeb.GameBoard do
  use ProjectQuazarWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="fixed left-4">
    <%= Phoenix.HTML.raw(Jason.encode!(@circle_pos)) %>
    <canvas id="circleCanvas" phx-hook="Game3" width="800" height="800" data-pos={"#{Jason.encode!(@circle_pos)}"}} ></canvas>
    </div>
    """
  end
end
