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
                <h3 class="help-heading">Introduction</h3>
                <p class="help-text">
                  Welcome to Project Quazar! Control your ship and navigate through space, shooting other player's ships to survive and to rack up the highest score!
                </p>
              </div>
              """
              2 -> ~S"""
              <div class="mt-8">
                <h3 class="help-heading">Ship Information / Controls</h3>
                <p class="help-text">
                  Before you begin, you'll need to name your ship and choose a ship and weapon type!
                </p>
                <div class="mt-4">
                  <h4 class="info-heading">Ship Types:</h4>
                  <div class="flex justify-between">
                    <div>
                      <h5 class="type-heading">Scout</h5>
                      <p class="help-health-text">100 HP</p>
                      <p class="help-text">A fast but weak ship</p>
                    </div>
                    <div>
                      <h5 class="type-heading">Destroyer</h5>
                      <p class="help-health-text">150 HP</p>
                      <p class="help-text">An all around ship</p>
                    </div>
                    <div>
                      <h5 class="type-heading">Destroyer</h5>
                      <p class="help-health-text">250 HP</p>
                      <p class="help-text">A slow and sturdy ship</p>
                    </div>
                  </div>
                </div>
                <div class="mt-4">
                  <h4 class="info-heading">Weapon Types:</h4>
                  <div class="flex justify-between">
                    <div>
                      <h5 class="type-heading">Light</h5>
                      <ul>
                        <li class="text-white">Damage: 10</li>
                        <li class="text-white">Reload: 0.75s</li>
                        <li class="text-white">Velocity: High</li>
                      </ul>
                    </div>
                    <div>
                      <h5 class="type-heading">Medium</h5>
                      <ul>
                        <li class="text-white">Damage: 20</li>
                        <li class="text-white">Reload: 1.1s</li>
                        <li class="text-white">Velocity: Medium</li>
                      </ul>
                    </div>
                    <div>
                      <h5 class="type-heading">Heavy</h5>
                      <ul>
                        <li class="text-white">Damage: 35</li>
                        <li class="text-white">Reload: 1.5s</li>
                        <li class="text-white">Velocity: Slow</li>
                      </ul>
                    </div>
                  </div>
                </div>
                <div class="mt-4">
                  <h4 class="info-heading">Controls:</h4>
                  <p class="control-item"><span class="font-bold">W</span> - Accelerate</p>
                  <p class="control-item"><span class="font-bold">A/D</span> - Turn Left/Right</p>
                  <p class="control-item"><span class="font-bold">S</span> - Decelerate</p>
                  <p class="control-item"><span class="font-bold">Space</span> - Shoot</p>
                </div>
              </div>
              """
        3 -> ~S"""
              <div class="mt-8">
                <h3 class="help-heading">Game Mechanics</h3>
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
    <div id="help" class="help-container">
      <div class="flex justify-end">
        <button phx-click="hide_help" class="button-tertiary">X</button>
      </div>
      <h2 class="startup-title">How To Play</h2>
      <%= raw(page_content) %>
      <div class="flex justify-between w-full mt-8">
        <%= if current_page > 1 do %>
          <button phx-click="previous_page" class="button-secondary">Previous</button>
        <% end %>
        <%= if current_page < 3 do %>
          <button phx-click="next_page" class="button-primary">Next</button>
        <% end %>
      </div>
      <p class="text-white text-center text-lg">Page: <%= current_page %></p>
    </div>
    """
  end
end
