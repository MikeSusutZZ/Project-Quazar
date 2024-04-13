defmodule FrontendWeb.TestLive do
  use FrontendWeb, :live_view

  def render(assigns) do
    ~L"""
    <div>
      Press a key to see the last key pressed in the console.
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, last_key: nil)}
  end

  def handle_event("key_pressed", %{"key" => key}, socket) do
    {:noreply, assign(socket, last_key: key)}
  end
end
