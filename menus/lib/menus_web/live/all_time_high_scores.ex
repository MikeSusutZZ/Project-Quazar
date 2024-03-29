defmodule MenusWeb.AllTimeHighScoresLive do
  use Phoenix.LiveView

  # `mount/3` prepares the socket for the live session.
  # It's called when the live view is mounted.
  @impl true
  def mount(_session, _params, socket) do
    {:ok, assign(socket, :sample_assign, "Hello, World!")}
  end

  # `render/1` is called to render the template.
  # It should return valid HEEx or LEEx markup.
  @impl true
  def render(assigns) do
    ~L"""
    <div>
      <%= @sample_assign %>
    </div>
    """
  end
end
