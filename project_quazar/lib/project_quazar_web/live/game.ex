defmodule ProjectQuazarWeb.Game do
  use ProjectQuazarWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event("join", %{"username" => username}, socket) do
    IO.inspect(username)
    {:noreply, socket}
  end
end
