# game.ex
defmodule ProjectQuazarWeb.Game do
  use ProjectQuazarWeb, :live_view
  alias ProjectQuazarWeb.Presence
  alias ProjectQuazar.PubSub

  @presence "project_quazar:presence"

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket
      |> assign(:joined, false)
      |> assign(:users, %{})
      |> assign(:error_message, "")}
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
end
