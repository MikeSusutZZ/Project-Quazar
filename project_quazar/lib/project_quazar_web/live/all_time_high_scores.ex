defmodule ProjectQuazarWeb.AllTimeHighScoresLive do
  use Phoenix.LiveView
  alias Phoenix.PubSub
  alias ProjectQuazar.HighScores

  @impl true
  def mount(_session, _params, socket) do
    PubSub.subscribe(ProjectQuazar.PubSub, "high_scores:updates")
    IO.puts("Subscribed to high_scores:updates")

    case HighScores.fetch_top_scores() do
      {:ok, top_scores} -> {:ok, assign(socket, :top_scores, top_scores)}
      {:error, _reason} -> {:ok, assign(socket, :top_scores, [])}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="high-scores-container">
      <h1>All-Time High Scores</h1>
      <div id="scores">
        <ul>
          <%= for score <- @top_scores do %>
            <li>
              <span class="player"><%= score.player %></span>
              <span class="score"><%= score.score %></span>
            </li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  @impl true
  def handle_info(:scores_updated, socket) do
    IO.puts("Received scores_updated in LiveView")

    case HighScores.fetch_top_scores() do
      {:ok, top_scores} ->
        updated_socket = assign(socket, :top_scores, top_scores)
        IO.inspect(updated_socket, label: "Updated top_scores")
        {:noreply, updated_socket}

      {:error, _reason} -> {:noreply, assign(socket, :top_scores, [])}
    end
  end
end
