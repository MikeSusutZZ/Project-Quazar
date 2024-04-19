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
                <div class="mt-4">
                  <h4 class="text-white text-lg font-bold mb-2 text-center">Ship Types:</h4>
                  <div class="flex justify-between">
                    <div>
                      <h5 class="type-heading">Scout</h5>
                      <p class="text-white italic text-center">100 HP</p>
                      <p class="text-white text-lg">A fast but weak ship</p>
                    </div>
                    <div>
                      <h5 class="type-heading">Destroyer</h5>
                      <p class="text-white italic text-center">150 HP</p>
                      <p class="text-white text-lg">An all around ship</p>
                    </div>
                    <div>
                      <h5 class="type-heading">Destroyer</h5>
                      <p class="text-white italic text-center">250 HP</p>
                      <p class="text-white text-lg">A slow and sturdy ship</p>
                    </div>
                  </div>
                </div>
                <div class="mt-4">
                  <h4 class="text-white text-lg font-bold mb-2 text-center">Weapon Types:</h4>
                  <div class="flex justify-between">
                    <div>
                      <h5 class="type-heading">Light</h5>
                      <ul>
                        <li class="text-white text-md">Damage: 10</li>
                        <li class="text-white text-md">Reload: 0.75s</li>
                        <li class="text-white text-md">Velocity: High</li>
                      </ul>
                    </div>
                    <div>
                      <h5 class="type-heading">Medium</h5>
                      <ul>
                        <li class="text-white text-md">Damage: 20</li>
                        <li class="text-white text-md">Reload: 1.1s</li>
                        <li class="text-white text-md">Velocity: Medium</li>
                      </ul>
                    </div>
                    <div>
                      <h5 class="type-heading">Heavy</h5>
                      <ul>
                        <li class="text-white text-md">Damage: 35</li>
                        <li class="text-white text-md">Reload: 1.5s</li>
                        <li class="text-white text-md">Velocity: Slow</li>
                      </ul>
                    </div>
                  </div>
                </div>
                <div class="mt-4">
                  <h4 class="text-white text-lg font-bold text-center">Controls:</h4>
                  <p class="control-item">W - Accelerate</p>
                  <p class="control-item">A/D - Turn Left/Right</p>
                  <p class="control-item">S - Decelerate</p>
                  <p class="control-item">Space - Shoot</p>
                </div>
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
    <div id="help" class="help-container mt-8">
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
