defmodule ProjectQuazarWeb.GameOver do
  use ProjectQuazarWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, score: 100)} #this is being hard coded for now, will be dynamic
  end


  def handle_event("return_to_main_menu", _params, socket) do
    # Logic to handle the event, possibly navigating to another page
    {:noreply, socket}
  end
end
