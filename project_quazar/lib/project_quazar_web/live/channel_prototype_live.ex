defmodule ProjectQuazarWeb.ChannelPrototypeLive do
  use ProjectQuazarWeb, :live_view

  def render(assigns) do
    ~H"""
    <div phx-hook="ChannelHook" id="messages"></div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
