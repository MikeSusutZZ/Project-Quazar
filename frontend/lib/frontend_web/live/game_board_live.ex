# lib/my_app_web/live/game_board_live.ex
defmodule FrontendWeb.GameBoardLive do
  use FrontendWeb, :live_view

  def render(assigns) do
    game_board = assigns.game_board

    ~H"""
    <canvas id="gameCanvas" width="400" height="400"></canvas>
    <script defer type="text/javascript">
      document.addEventListener("DOMContentLoaded", function() {
        let canvas = document.getElementById('gameCanvas');
        if (canvas.getContext) {
          let ctx = canvas.getContext('2d');

          // Use Phoenix.HTML.raw to safely inject the game_board into JavaScript
          let game_board = JSON.parse(`<%= Phoenix.HTML.raw(Jason.encode!(game_board)) %>`);

          let cellSize = 50; // Adjust this value as needed
          let rows = game_board.length;
          let cols = game_board[0].length;

          // Draw the game board
          for (let row = 0; row < rows; row++) {
            for (let col = 0; col < cols; col++) {
              let x = col * cellSize;
              let y = row * cellSize;

              ctx.fillStyle = '#FFFFFF'; // Set the background color
              ctx.fillRect(x, y, cellSize, cellSize); // Draw the cell background

              ctx.strokeStyle = '#000000'; // Set the border color
              ctx.strokeRect(x, y, cellSize, cellSize); // Draw the cell border

              let cellValue = " ";
              ctx.fillStyle = '#000000'; // Set the text color
              // Adjust text alignment and baseline for better centering
              ctx.textAlign = 'center';
              ctx.textBaseline = 'middle';
              ctx.fillText(cellValue, x + cellSize / 2, y + cellSize / 2); // Draw the cell value
            }
          }

          // Draw the grid lines
          ctx.strokeStyle = '#000000'; // Set the color of the grid lines
          for (let row = 0; row <= rows; row++) {
            ctx.beginPath();
            ctx.moveTo(0, row * cellSize);
            ctx.lineTo(cols * cellSize, row * cellSize);
            ctx.stroke();
          }
          for (let col = 0; col <= cols; col++) {
            ctx.beginPath();
            ctx.moveTo(col * cellSize, 0);
            ctx.lineTo(col * cellSize, rows * cellSize);
            ctx.stroke();
          }
        }
      });
    </script>
    """
  end

  def mount(_params, _session, socket) do
    # Fetch game board data (e.g., from a JSON file or a database query)
    game_board_data = fetch_game_board_data()

    # Pass the game board data to the LiveView template
    IO.inspect(game_board_data)
    {:ok, assign(socket, :game_board, game_board_data)}
  end

  # Helper function to fetch game board data (replace with your implementation)
  defp fetch_game_board_data() do
    # Fetch game board data from JSON or a struct
    # Example: game_board_data = MyApp.GameBoard.fetch_data()
    # For demo purposes, return a static example
    [
      ["X", "O", "X", "O", "X", "O", "X", "O", "X", "O"],
      ["O", "X", "O", "X", "O", "X", "O", "X", "O", "X"],
      ["X", "O", "X", "O", "X", "O", "X", "O", "X", "O"],
      ["O", "X", "O", "X", "O", "X", "O", "X", "O", "X"],
      ["X", "O", "X", "O", "X", "O", "X", "O", "X", "O"],
      ["O", "X", "O", "X", "O", "X", "O", "X", "O", "X"],
      ["X", "O", "X", "O", "X", "O", "X", "O", "X", "O"],
      ["O", "X", "O", "X", "O", "X", "O", "X", "O", "X"],
      ["X", "O", "X", "O", "X", "O", "X", "O", "X", "O"],
      ["O", "X", "O", "X", "O", "X", "O", "X", "O", "X"]
    ]
  end
end
