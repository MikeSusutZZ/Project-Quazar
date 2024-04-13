// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//spac

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

const DummyPlayerList = {
  "players": [
    { "name": "Player1", "score": 1200, "ship": { "kinematics": { "px": 100, "py": 150 }, "max_health": 100, "current_health": 80, "bullet_type": "laser" } }
  ]
};

// Define the LogKey hook
let Hooks = {};

Hooks.LogKey = {
  mounted() {
    console.log("Log has been mounted!");
    this.handleEvent("log-to-console", ({ key }) => {
      console.log("Key pressed:", key);
    });
  },
};

Hooks.MoveHook = {
  mounted() {
    console.log("Movement mounted");
    let pressedKeys = new Set(); // Set to track pressed keys

    let canvas = document.getElementById("circleCanvas");
    // let myData = JSON.parse(canvas.getAttribute("data-pos"));
    // console.log("My data", myData);
    // Start
    let ctx = canvas.getContext("2d");

    // Parse player data directly from DummyPlayerList
    let shipImage = new Image();
    shipImage.src = "/images/test_space_ship.jpg"; // Path to your spaceship image
    shipImage.onload = () => {
      // Draw each ship when the image is loaded
      DummyPlayerList.players.forEach(player => {
        let ship = player.ship;
        ctx.drawImage(shipImage, ship.kinematics.px, ship.kinematics.py, 130, 100);
      });
    };

    // Use Phoenix.HTML.raw to safely inject the game_board into JavaScript
    let game_board = JSON.parse(canvas.getAttribute("data-board"));

    let cellSize = 50; // Adjust this value as needed
    let rows = game_board.length;
    let cols = game_board[0].length;

    // Draw the game board
    for (let row = 0; row < rows; row++) {
      for (let col = 0; col < cols; col++) {
        let x = col * cellSize;
        let y = row * cellSize;

        ctx.fillStyle = "#FFFFFF"; // Set the background color
        ctx.fillRect(x, y, cellSize, cellSize); // Draw the cell background

        ctx.strokeStyle = "#000000"; // Set the border color
        ctx.strokeRect(x, y, cellSize, cellSize); // Draw the cell border

        let cellValue = " ";
        ctx.fillStyle = "#000000"; // Set the text color
        // Adjust text alignment and baseline for better centering
        ctx.textAlign = "center";
        ctx.textBaseline = "middle";
        ctx.fillText(cellValue, x + cellSize / 2, y + cellSize / 2); // Draw the cell value
      }
    }

    // Draw the grid lines
    ctx.strokeStyle = "#000000"; // Set the color of the grid lines
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

    // End
    // Get the 2D rendering context

    // Function to create JSON payload
    const createKeyPayload = (key, action) => {
      return JSON.stringify({ key: key, action: action });
    };

    window.addEventListener("keydown", (e) => {
      if (!pressedKeys.has(e.key)) {
        pressedKeys.add(e.key); // Add pressed key to the set
        let keyPayload = createKeyPayload(e.key, 'start'); // Create JSON payload
        this.pushEvent("start_move", { key_payload: keyPayload }, (reply) => {
          console.log("Server reply", reply);
        });
      }
    });

    window.addEventListener("keyup", (e) => {
      if (pressedKeys.has(e.key)) {
        pressedKeys.delete(e.key); // Remove released key from the set
        let keyPayload = createKeyPayload(e.key, 'stop'); // Create JSON payload
        this.pushEvent("stop_move", { key_payload: keyPayload });
      }
    });

    // Add event listener for the "click" event
    window.addEventListener("click", () => {
      this.pushEvent("shoot", {});
    });
  },
};

window.addEventListener("phx:remove-el", (e) =>
  console.log("Remove", e.detail.id)
);

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks, // Add the LogKey hook here
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

// document.addEventListener("keydown", function (event) {
//   console.log("Key pressed:", event.key);
// });