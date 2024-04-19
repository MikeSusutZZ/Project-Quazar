defmodule ProjectQuazarWeb.Help do
  use ProjectQuazarWeb, :live_component

  def mount(_params, _session, socket) do
    {:ok, assign(socket, current_page: socket.assigns.current_page || 1)}
  end

  def render(assigns) do
    current_page = Map.get(assigns, :current_page, 1)

    page_content =
      case current_page do
        1 -> ~S"""
              <div class="mt-8">
                <h3 class="text-white text-lg font-bold text-center mb-4">Introduction</h3>
                <p class="text-white text-lg">
                  Welcome to Project Quazar! Control your ship and navigate through space, shooting other player's ships to survive and to rack up the highest score!
                </p>
              </div>
              """
        2 -> ~S"""
              <div class="mt-8">
                <h3 class="text-white text-lg font-bold text-center mb-4">Ship Information / Controls</h3>
                <p class="text-white text-lg">
                  Before you begin, you'll need to name your ship and choose a ship and weapon type!
                </p>
                <h3 class="text-white text-lg font-bold mt-4">Ship Types:</h3>
                <ul class="text-white text-lg">
                  <li>Scout: A fast but weak ship [100 hp]</li>
                  <li>Destroyer: An all-around ship with decent speed and health [150 hp]</li>
                  <li>Tank: A slow and sturdy ship [250 hp]</li>
                </ul>
                <h3 class="text-white text-lg font-bold mt-4">Weapon Types:</h3>
                <ul class="text-white text-lg">
                  <li>Light: 10 Damage, 0.75s Reload, High Velocity</li>
                  <li>Medium: 20 Damage, 1.1s Reload, Medium Velocity</li>
                  <li>Heavy: 35 Damage, 1.5s Reload, Slow Velocity</li>
                </ul>
                <h3 class="text-white text-lg font-bold mt-4">Controls:</h3>
                <p class="text-white text-lg">W - Accelerate</p>
                <p class="text-white text-lg">A/D - Turn Left/Right</p>
                <p class="text-white text-lg">S - Decelerate</p>
                <p class="text-white text-lg">Space - Shoot</p>
              </div>
              """
        3 -> ~S"""
              <div class="mt-8">
                <h3 class="text-white text-lg font-bold text-center mb-4">Game Mechanics</h3>
                <p class="text-white text-lg mb-4">
                  Shoot other players to survive the longest! You'll gain more points depending on how long you survive.
                </p>
                <p class="text-white text-lg mb-4">
                  Your ship will be destroyed if it reaches 0 health, and you'll be brought back to start. Ships regenerate health over time.
                </p>
                <p class="text-white text-lg mb-4">
                  Stay out of the danger zone; you'll take damage while inside! And if you venture too far into space, bad things will happen...
                </p>
              </div>
              """
        _ -> "Invalid page number"
      end

    ~H"""
    <div id="help" class="container mt-8">
      <div class="flex justify-end">
        <button phx-click="hide_help" class="button-tertiary">X</button>
      </div>
      <h2 class="startup-title">How To Play</h2>
      <p class="text-white text-center text-lg">Page: <%= current_page %></p>
      <%= raw(page_content) %>
      <div class="flex justify-between w-full mt-8">
        <%= if current_page > 1 do %>
          <button phx-click="previous_page" class="button-secondary">Previous</button>
        <% end %>
        <%= if current_page < 3 do %>
          <button phx-click="next_page" class="button-primary">Next</button>
        <% end %>
      </div>
    </div>
    """
  end
end
