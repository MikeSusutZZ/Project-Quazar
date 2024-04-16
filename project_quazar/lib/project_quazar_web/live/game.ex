# game.ex
defmodule ProjectQuazarWeb.Game do
  use ProjectQuazarWeb, :live_view
  alias ProjectQuazarWeb.Presence
  alias ProjectQuazar.PubSub
  alias ProjectQuazar.HighScores

  @presence "project_quazar:presence"

  @impl true
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(ProjectQuazar.PubSub, "high_scores:updates")
    top_scores = fetch_top_scores()

    {:ok,
     socket
     |> assign(:joined, false)
     |> assign(:users, %{})
     |> assign(:error_message, "")
     |> assign(:top_scores, top_scores)}
  end

  @impl true
  def handle_event("join", %{"username" => username}, socket) do
    case Map.has_key?(Presence.list(@presence), username) do
      true ->
        {:reply, %{error: "Username already taken"},
         assign(socket, :error_message, "Username already taken")}

      false ->
        Presence.track(self(), @presence, username, %{
          points: 0
        })

        Phoenix.PubSub.subscribe(PubSub, @presence)

        {:noreply,
         socket
         |> assign(:joined, true)
         |> assign(:current_user, username)
         |> handle_joins(Presence.list(@presence))}
    end
  end

  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff", payload: diff}, socket) do
    {:noreply,
     socket
     |> handle_leaves(diff.leaves)
     |> handle_joins(diff.joins)}
  end

  # accepts the new scores from the broadcast
  @impl true
  def handle_info({:scores_updated, top_scores}, socket) do
    {:noreply, assign(socket, :top_scores, top_scores)}
  end

  defp handle_joins(socket, joins) do
    users =
      joins
      |> Enum.map(fn {user, %{metas: [meta | _]}} -> {user, meta} end)
      |> Enum.into(%{})

    assign(socket, :users, Map.merge(socket.assigns.users, users))
    |> sort_users_by_points()
  end

  defp handle_leaves(socket, leaves) do
    Enum.reduce(leaves, socket, fn {user, _}, socket ->
      assign(socket, :users, Map.delete(socket.assigns.users, user))
    end)
  end

  defp sort_users_by_points(socket) do
    sorted_users =
      socket.assigns.users
      |> Enum.sort_by(fn {_, %{points: points}} -> -points end)
      |> Enum.into(%{})

    assign(socket, :users, sorted_users)
  end

  # Fetches top scores for all-time high scores component
  defp fetch_top_scores do
    case HighScores.fetch_top_scores() do
      {:ok, top_scores} -> top_scores
      {:error, _reason} -> []
    end
  end

  # Pings the game server
  def handle_event("ping_server", %{"key" => "p"}, socket) do
    GameServer.ping(socket)
    {:noreply, socket}
  end

  def handle_event("ping_server", _, socket), do: {:noreply, socket}

  # Spawn a test ship
  def handle_event("control", %{"key" => "r"}, socket) do
    IO.puts("Spawning test ship")
    GameServer.spawn_player("default", :destroyer, :light)
    {:noreply, socket}
  end

  # Accelerate the test ship
  def handle_event("control", %{"key" => "w"}, socket) do
    GameServer.accelerate_player("default")
    {:noreply, socket}
  end

  # Rotate the test ship clockwise
  def handle_event("control", %{"key" => "d"}, socket) do
    GameServer.rotate_player("default", :cw)
    {:noreply, socket}
  end

  # Rotate the test ship counter-clockwise
  def handle_event("control", %{"key" => "a"}, socket) do
    GameServer.rotate_player("default", :ccw)
    {:noreply, socket}
  end

  # Fire the bullet
  def handle_event("control", %{"key" => " "}, socket) do
    current_user = Map.get(socket.assigns, :current_user)

    # Check if `current_user` is present
    if current_user do
      GameServer.fire(current_user)
    else
      IO.puts("No current user set. Cannot fire.")
      # GameServer.fire("default")  # test test ship firing
    end

    {:noreply, socket}
  end

  # Catches all other keyboard events
  def handle_event("control", _, socket), do: {:noreply, socket}
end
