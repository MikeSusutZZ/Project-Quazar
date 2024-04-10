# game.ex
defmodule ProjectQuazarWeb.Game do
  use ProjectQuazarWeb, :live_view
  alias ProjectQuazarWeb.Presence
  alias ProjectQuazar.PubSub
  alias ProjectQuazar.HighScores

  @presence "project_quazar:presence"

  @impl true
  def mount(_params, _session, socket) do

    # For the `all-time high scores` component; subscribes to high_scores
    # PubSub seen in lib > project_quazar_web >channels > `high_scores_channel.ex`
    Phoenix.PubSub.subscribe(ProjectQuazar.PubSub, "high_scores:updates")
    top_scores = fetch_top_scores()

    {:ok, socket
      |> assign(:joined, false)
      |> assign(:users, %{})
      |> assign(:error_message, "")
      |> assign(:top_scores, top_scores)
    }
  end

  @impl true
  def handle_event("join", %{"username" => username}, socket) do
    case Map.has_key?(Presence.list(@presence), username) do
      true ->
        {:reply, %{error: "Username already taken"}, assign(socket, :error_message, "Username already taken")}
      false ->
        Presence.track(self(), @presence, username, %{
          points: 0,
        })
        Phoenix.PubSub.subscribe(PubSub, @presence)
        {:noreply, socket
          |> assign(:joined, true)
          |> assign(:current_user, username)
          |> handle_joins(Presence.list(@presence))}
    end
  end

  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff", payload: diff}, socket) do
    {:noreply, socket
      |> handle_leaves(diff.leaves)
      |> handle_joins(diff.joins)}
  end

  # Fetches top scores for all-time high scores component (see below)
  @impl true
  def handle_info(:scores_updated, socket) do
    top_scores = fetch_top_scores()
    {:noreply, assign(socket, :top_scores, top_scores)}
  end

  defp handle_joins(socket, joins) do
    users = joins
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
    sorted_users = socket.assigns.users
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
end
