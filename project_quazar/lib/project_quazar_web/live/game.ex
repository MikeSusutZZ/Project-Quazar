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
     |> assign(:circle_pos, json_pos)
     # assigns for start and how to play components
     |> assign(:start, true)
     |> assign(:show_help, false)
     # handles pagination for how to play
     |> assign(:current_page, 1)
     |> assign(:game_over, false)
     |> assign(:dead_player_score, 0)
     |> assign(:game_state, "")}
  end

  # Join event called by submit button. Check if username already exists or blank, if not, start tracking them
  # with Presence and subscribe their socket to the Presence PubSub topic.
  @impl true
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
      {:reply, %{error: "Username can't be blank"},
       assign(socket, :error_message, "Username can't be blank")}
    else
      case Map.has_key?(Presence.list(@presence), username) do
        true ->
          {:reply, %{error: "Username already taken"},
           assign(socket, :error_message, "Username already taken")}

        false ->
          GameServer.remove_leftover_players(Presence.list(@presence))
          # where ship/bullet are atoms
          GameServer.spawn_player(username, ship_type, bullet_type)
          Presence.track(self(), @presence, username, %{})
          Phoenix.PubSub.subscribe(PubSub, @presence)
          Phoenix.PubSub.subscribe(PubSub, "game_state:updates")
          # default ship destroyer, change when implemented ship choice
          # GameServer.spawn_player(username, :destroyer)
          {:noreply,
           socket
           |> assign(:joined, true)
           |> assign(:current_user, username)
           |> assign(:error_message, "")}
      end
    end
  end

  # "Handle the event for next page in how to play component"
  def handle_event("next_page", _value, socket) do
    current_page = Map.get(socket.assigns, :current_page, 1)
    next_page = current_page + 1

    {:noreply, assign(socket, current_page: next_page)}
  end

  # "Handle the event for previous page in how to play component"
  def handle_event("previous_page", _value, socket) do
    current_page = Map.get(socket.assigns, :current_page, 1)
    previous_page = max(current_page - 1, 1)

    {:noreply, assign(socket, current_page: previous_page)}
  end

  # "Handle the state for start component"
  def handle_event("show_start_game", _value, socket) do
    {:noreply, assign(socket, :start, false)}
  end

  # "Handle the state for displaying help component"
  def handle_event("show_help", _value, socket) do
    {:noreply, assign(socket, :show_help, true)}
  end

  # "Handle the state for hiding help component"
  def handle_event("hide_help", _value, socket) do
    {:noreply, assign(socket, :show_help, false)}
  end

  # "Handle Presence event whenever there is change to Presence."
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

  # Handle the state_updated sent by GameServer in each tick.
  @impl true
  def handle_info({:state_updated, new_state}, socket) do
    send(self(), :update_client)

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
         |> assign(:game_state, new_state)}

      dead_player ->
        # :timer.sleep(2000)
        Process.send_after(self(), {:death, dead_player}, 1000)

        {:noreply,
         socket
         |> assign(:players, new_state.players)
         |> sort_players_by_score()
         |> assign(:projectiles, new_state.projectiles)
         |> assign(:dead_player_score, dead_player.score)}
    end
  end

  def handle_info({:death, dead_player}, socket) do
    IO.puts("Handle death")
    Presence.untrack(self(), @presence, dead_player.name)
    GameServer.remove_leftover_players(Presence.list(@presence))

    {:noreply, socket |> assign(:game_over, true)}
  end

  # Handle the 'leaves' object retrieved from the 'presence_diff' event.
  # Update the socket's players map using the 'leaves' object.
  defp handle_leaves(socket, leaves) do
    Enum.reduce(leaves, socket, fn {player, _}, socket ->
      GameServer.remove_player(player)
      assign(socket, :players, List.delete(socket.assigns.players, player))
    end)
  end

  defp sort_players_by_score(socket) do
    sorted_players =
      socket.assigns.players
      |> Enum.sort_by(& &1.score, &>=/2)

    assign(socket, :players, sorted_players)
  end

  # Fetches top scores for all-time high scores component
  defp fetch_top_scores do
    case HighScores.fetch_top_scores() do
      {:ok, top_scores} -> top_scores
      {:error, _reason} -> []
    end
  end

  # Catches all other keyboard events
  def handle_event("control", _, socket), do: {:noreply, socket}

  ## Frontend Events
  @doc "Handles key press events from browser and triggers appropriate game server functions based on the key pressed."
  @impl true
  def handle_event("key_down", %{"key" => key}, socket) do
    IO.puts("Key Down: #{key}")
    player_name = socket.assigns.current_user

    case String.downcase(key) do
      "w" -> GameServer.accelerate_pressed(player_name)
      "s" -> GameServer.brake_pressed(player_name)
      "d" -> GameServer.turn_right_pressed(player_name)
      "a" -> GameServer.turn_left_pressed(player_name)
      " " -> GameServer.fire_pressed(player_name)
      _ -> :ok
    end

    {:noreply, socket}
  end

  @doc "Handles key release events and triggers game server functions based on the key released."
  @impl true
  def handle_event("key_up", %{"key" => key}, socket) do
    player_name = socket.assigns.current_user
    key = String.downcase(key)
    IO.puts("Key Up: #{key}")
    IO.inspect(key)

    case key do
      "w" ->
        GameServer.accelerate_released(player_name)

      "s" ->
        GameServer.brake_released(player_name)

      "d" ->
        GameServer.turn_right_released(player_name)

      "a" ->
        GameServer.turn_left_released(player_name)

      " " ->
        GameServer.fire_released(player_name)

      _ ->
        :ok
    end

    {:noreply, socket}
  end

  @doc "Handles custom messages intended for client-side updates."
  def handle_info(:update_client, socket) do
    {:noreply, push_event(socket, "update", %{updated: "true"})}
  end

  # Frontend Events End

  def handle_event("game_over_to_lobby", _value, socket) do
    new_socket =
      assign(socket, :start, false)
      |> assign(:joined, false)
      |> assign(:game_over, false)

    {:noreply, new_socket}
  end
end
