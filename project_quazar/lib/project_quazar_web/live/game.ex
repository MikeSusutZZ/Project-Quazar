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
      |> assign(:players, [])
     |> assign(:projectiles, [])
      |> assign(:error_message, "")
      |> assign(:top_scores, top_scores)
      |> assign(:circle_pos, json_pos)
      # assigns for start and how to play components
      |> assign(:start, true)
      |> assign(:show_help, false)
      |> assign(:current_page, 1) # handles pagination for how to play
      |> assign(:game_over, false)
      |> assign(:dead_player_score, 0)
    }
  end

  @doc """
  Join event called by submit button. Check if username already exists or blank, if not, start tracking them
  with Presence and subscribe their socket to the Presence PubSub topic.
  """
  def handle_event("join", %{"username" => username, "ship" => ship, "bullet" => bullet}, socket) do
    IO.puts("------------------")
    IO.inspect(username)
    IO.inspect(ship)
    IO.inspect(bullet)
    # Turn string value gotten from radio button into atom to pass into spawn player
    ship_type = String.to_atom(ship)
    bullet_type = String.to_atom(bullet)
    IO.inspect(ship_type)
    IO.inspect(bullet_type)
    # Check if username blank
    if username == "" do
      {:reply, %{error: "Username can't be blank"}, assign(socket, :error_message, "Username can't be blank")}
    else
      case Map.has_key?(socket, username) do
        true ->
          {:reply, %{error: "Username already taken"}, assign(socket, :error_message, "Username already taken")}
        false ->
          GameServer.remove_leftover_players(Presence.list(@presence))
          GameServer.spawn_player(username, ship_type, bullet_type) #where ship/bullet are atoms
          Presence.track(self(), @presence, username, %{})
          Phoenix.PubSub.subscribe(PubSub, @presence)
          Phoenix.PubSub.subscribe(PubSub, "game_state:updates")
          # default ship destroyer, change when implemented ship choice
          # GameServer.spawn_player(username, :destroyer)
          {:noreply, socket
            |> assign(:joined, true)
            |> assign(:current_user, username)
            |> assign(:error_message, "")}
      end
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

    # game_over =
      Enum.find(socket.assigns.players, fn player ->
        socket.assigns.current_user == player.name && player.ship.health <= 0
      end)
      |> case do
        nil ->
          {:noreply,
          socket
          |> assign(:players, new_state.players)
          |> sort_players_by_score()
          |> assign(:projectiles, new_state.projectiles)
          }
        dead_player ->
          Presence.untrack(self(), @presence, dead_player.name)
          GameServer.remove_leftover_players(Presence.list(@presence))
          {:noreply,
          socket
          |> assign(:players, new_state.players)
          |> sort_players_by_score()
          |> assign(:projectiles, new_state.projectiles)
          |> assign(:dead_player_score, dead_player.score)
          |> assign(:game_over, true)}
      end

    # {:noreply,
    # socket
    # |> assign(:players, new_state.players)
    # |> sort_players_by_score()
    # |> assign(:projectiles, new_state.projectiles)
    # |> assign(:game_over, game_over)}

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

  def handle_event("game_over_to_lobby", _value, socket) do
    new_socket = assign(socket, :start, false)
    |> assign(:joined, false)
    |> assign(:game_over, false)
    {:noreply, new_socket}
  end

end
