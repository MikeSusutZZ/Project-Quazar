defmodule ProjectQuazarWeb.UserSocket do
  use Phoenix.Socket

  # Channels
  channel "high_scores:updates", ProjectQuazarWeb.HighScoresChannel

  # Socket connect
  def connect(_params, socket), do: {:ok, socket}

  # Socket id
  def id(_socket), do: nil
end
