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
    <div id="help" class="bg-gray-900 p-6 rounded-lg shadow-lg max-w-lg mx-auto mt-8">
      <div class="flex justify-end">
        <button phx-click="hide_help" class="bg-red-500 hover:bg-red-700 text-white font-bold py-2 px-4 rounded">X</button>
      </div>
      <h2 class="text-white text-4xl font-bold text-center mb-8">How To Play</h2>
      <p class="text-white text-center text-lg">Page: <%= current_page %></p>
      <%= raw(page_content) %>
      <div class="flex justify-between w-full mt-8">
        <%= if current_page > 1 do %>
          <button phx-click="previous_page" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-3 px-6 rounded-lg text-lg">Previous</button>
        <% end %>
        <%= if current_page < 3 do %>
          <button phx-click="next_page" class="bg-green-500 hover:bg-green-700 text-white font-bold py-3 px-6 rounded-lg text-lg">Next</button>
        <% end %>
      </div>
    </div>
    """
  end
end
