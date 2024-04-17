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

    {:ok, socket
      |> assign(:joined, false)
      |> assign(:users, %{})
      |> assign(:error_message, "")
      |> assign(:top_scores, top_scores)
      |> assign(:circle_pos, json_pos)
      # assigns for start and how to play components
      |> assign(:start, true)
      |> assign(:show_help, false)
      |> assign(:current_page, 1) # handles pagination for how to play
    }
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
        GameServer.spawn_player(username, "default")
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

  @doc "Handle the event for next page in how to play component"
  def handle_event("next_page", _value, socket) do
    current_page = Map.get(socket.assigns, :current_page, 1)
    next_page = current_page + 1

    {:noreply, assign(socket, current_page: next_page)}
  end

  @doc "Handle the event for previous page in how to play component"
  def handle_event("previous_page", _value, socket) do
    current_page = Map.get(socket.assigns, :current_page, 1)
    previous_page = max(current_page - 1, 1)

    {:noreply, assign(socket, current_page: previous_page)}
  end

  @doc "Handle the state for start component"
  def handle_event("show_start_game", _value, socket) do
    {:noreply, assign(socket, :start, false)}
  end

  @doc "Handle the state for displaying help component"
  def handle_event("show_help", _value, socket) do
    {:noreply, assign(socket, :show_help, true)}
  end

  @doc "Handle the state for hiding help component"
  def handle_event("hide_help", _value, socket) do
    {:noreply, assign(socket, :show_help, false)}
  end


  @doc "Handle the event for next page in how to play component"
  def handle_event("next_page", _value, socket) do
    current_page = Map.get(socket.assigns, :current_page, 1)
    next_page = current_page + 1

    {:noreply, assign(socket, current_page: next_page)}
  end

  @doc "Handle the event for previous page in how to play component"
  def handle_event("previous_page", _value, socket) do
    current_page = Map.get(socket.assigns, :current_page, 1)
    previous_page = max(current_page - 1, 1)

    {:noreply, assign(socket, current_page: previous_page)}
  end

  @doc "Handle Presence event whenever there is change to Presence (leaving/joining)."
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

  @doc """
  Handle the 'joins' object retrieved from the 'presence_diff' event.
  Update the socket's users map using the 'joins' object.
  """
  defp handle_joins(socket, joins) do
    users =
      joins
      |> Enum.map(fn {user, %{metas: [meta | _]}} -> {user, meta} end)
      |> Enum.into(%{})

    assign(socket, :users, Map.merge(socket.assigns.users, users))
    |> sort_users_by_points()
  end

  @doc """
  Handle the 'leaves' object retrieved from the 'presence_diff' event.
  Update the socket's users map using the 'leaves' object.
  """
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
