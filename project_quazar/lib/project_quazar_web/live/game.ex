# game.ex
defmodule ProjectQuazarWeb.Game do
  use ProjectQuazarWeb, :live_view
  alias ProjectQuazarWeb.Presence
  alias ProjectQuazar.PubSub
  alias ProjectQuazar.HighScores

  @doc "PubSub topic for presence"
  @presence "project_quazar:presence"

  @impl true
  def mount(_params, _session, socket) do
    # For the `all-time high scores` component; subscribes to high_scores
    # PubSub seen in lib > project_quazar_web >channels > `high_scores_channel.ex`
    Phoenix.PubSub.subscribe(ProjectQuazar.PubSub, "high_scores:updates")
    top_scores = fetch_top_scores()

    # Frontend Prototype Data Start
    initial_x = 100
    initial_y = 100
    json_pos = %{x: initial_x, y: initial_y}
    player_status = %{health: 100, isAlive: true}
    json_pos = Map.merge(json_pos, player_status)
    # End

    {:ok,
     socket
     |> assign(:joined, false)
     |> assign(:players, [])
     |> assign(:projectiles, [])
     |> assign(:error_message, "")
     |> assign(:top_scores, top_scores)
     # Frontend Test Data
     |> assign(:circle_pos, json_pos)}
  end

  @doc """
  Join event called by submit button. Check if username already exists, if not, start tracking them
  with Presence and subscribe their socket to the Presence PubSub topic.
  """
  @impl true
  def handle_event("join", %{"username" => username}, socket) do
    case Map.has_key?(Presence.list(@presence), username) do
      true ->
        {:reply, %{error: "Username already taken"},
         assign(socket, :error_message, "Username already taken")}

      false ->
        GameServer.remove_leftover_players(Presence.list(@presence))
        Presence.track(self(), @presence, username, %{})

        Phoenix.PubSub.subscribe(PubSub, @presence)
        Phoenix.PubSub.subscribe(PubSub, "game_state:updates")
        # default ship destroyer, change when implemented ship choice
        GameServer.spawn_player(username, :destroyer)

        {:noreply,
         socket
         |> assign(:joined, true)
         |> assign(:current_user, username)}
    end
  end

  @doc "Handle Presence event whenever there is change to Presence."
  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff", payload: diff}, socket) do
    {:noreply,
     socket
     |> handle_leaves(diff.leaves)}
  end

  # accepts the new scores from the broadcast
  @impl true
  def handle_info({:scores_updated, top_scores}, socket) do
    {:noreply, assign(socket, :top_scores, top_scores)}
  end

  @doc """
  Handle the state_updated sent by GameServer in each tick.
  """
  @impl true
  def handle_info({:state_updated, new_state}, socket) do
    {:noreply,
    socket
    |> assign(:players, new_state.players)
    |> sort_players_by_score()
    |> assign(:projectiles, new_state.projectiles)}
  end

  @doc """
  Handle the 'leaves' object retrieved from the 'presence_diff' event.
  Update the socket's players map using the 'leaves' object.
  """
  defp handle_leaves(socket, leaves) do
    Enum.reduce(leaves, socket, fn {player, _}, socket ->
      GameServer.remove_player(player)
      assign(socket, :players, List.delete(socket.assigns.players, player))
    end)
  end

  defp sort_players_by_score(socket) do
    sorted_players =
      socket.assigns.players
      |> Enum.sort_by(&(&1.score), &>=/2)

    assign(socket, :players, sorted_players)
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
    GameServer.spawn_player("default")
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

  # Catches all other keyboard events
  def handle_event("control", _, socket), do: {:noreply, socket}

  ## Frontend Events
  def handle_event("start_move", %{"key" => key}, socket) do
    IO.inspect("#{key} pressed")
    IO.inspect(socket.assigns.circle_pos)

    new_pos =
      case key do
        # Move up
        "w" -> %{x: socket.assigns.circle_pos.x, y: socket.assigns.circle_pos.y - 10}
        # Move left
        "a" -> %{x: socket.assigns.circle_pos.x - 10, y: socket.assigns.circle_pos.y}
        # Move down
        "s" -> %{x: socket.assigns.circle_pos.x, y: socket.assigns.circle_pos.y + 10}
        # Move right
        "d" -> %{x: socket.assigns.circle_pos.x + 10, y: socket.assigns.circle_pos.y}
        _ -> socket.assigns.circle_pos
      end

    # Merge the extra values back into the new position map
    new_pos = Map.merge(new_pos, Map.drop(socket.assigns.circle_pos, [:x, :y]))

    {:noreply, assign(socket, :circle_pos, new_pos)}
  end

  def handle_event("stop_move", %{"key" => key}, socket) do
    IO.inspect("#{key} released")
    {:noreply, socket}
  end

  def handle_event("shoot", _value, socket) do
    IO.inspect("Pew")
    {:noreply, socket}
  end

  def handle_event("game_over", %{"score" => score}, socket) do
    {:noreply, push_redirect(socket, to: "/game-over?score=#{score}")}
  end

end
