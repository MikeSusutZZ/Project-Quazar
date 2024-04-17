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
                <p class="text-white text-lg">This is page 1 content.</p>
              </div>
              """
        2 -> ~S"""
              <div class="mt-8">
                <p class="text-white text-lg">This is page 2 content.</p>
              </div>
              """
        3 -> ~S"""
              <div class="mt-8">
                <p class="text-white text-lg">This is page 3 content.</p>
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
