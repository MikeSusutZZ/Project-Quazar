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
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";

// Hooks initializer
let Hooks = {};

// Frontend Prototype 1
Hooks.MoveCircle = {
  mounted() {
    console.log("circle mounted");
    window.addEventListener("keydown", (e) => {
      console.log(e);
      if (e.key === "w") {
        console.log("up");
        this.pushEvent("move_up", {});
      } else if (e.key === "a") {
        console.log("left");
        this.pushEvent("move_left", {});
      } else if (e.key === "s") {
        console.log("down");
        this.pushEvent("move_down", {});
      } else if (e.key === "d") {
        console.log("right");
        this.pushEvent("move_right", {});
      }
    });
  },
};

// Frontend Prototype 2
const drawGame = () => {
  let canvas = document.getElementById("circleCanvas");
  let myData = JSON.parse(canvas.getAttribute("data-pos"));
  console.log("My data", myData);
  // Start
  let ctx = canvas.getContext("2d");

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

      let cellValue = game_board[row][col];
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

  // Create a new image object
  let image = new Image();
  image.src = "/images/side-eye.jpg"; // Adjust the path to your image

  // Draw the image onto the canvas when it's loaded
  image.onload = function () {
    ctx.drawImage(image, myData.x, myData.y, 130, 100);
  };
};

Hooks.MoveHook = {
  mounted() {
    console.log("Movement mounted");
    let pressedKeys = new Set(); // Set to track pressed keys

    // Initial Render
    drawGame();

    window.addEventListener("keydown", (e) => {
      if (!pressedKeys.has(e.key)) {
        pressedKeys.add(e.key); // Add pressed key to the set
        this.pushEvent("start_move", { key: e.key }, (reply) => {
          console.log("reply", reply);
          // Render on key-event, will be changed to on broadcast received
          drawGame();
        });
      }
    });

    window.addEventListener("keyup", (e) => {
      if (pressedKeys.has(e.key)) {
        pressedKeys.delete(e.key); // Remove released key from the set
        this.pushEvent("stop_move", { key: e.key });
      }
    });

    // Add event listener for the "click" event
    window.addEventListener("click", () => {
      this.pushEvent("shoot", {});
    });
  },
};

let bullet1_xy = [0, 400];
let bullet2_xy = [0, 500];
let bullet3_xy = [0, 600];

// Frontend Prototype 3
const drawGame3 = () => {
  let canvas = document.getElementById("circleCanvas");
  let myData = JSON.parse(canvas.getAttribute("data-pos"));
  console.log("My data", myData);
  // Start
  let ctx = canvas.getContext("2d");

  // Initialize canvas images
  let gameBoard = new Image();
  let player = new Image();
  let bullet1 = new Image();
  let bullet2 = new Image();
  let bullet3 = new Image();

  // Link images to assets
  gameBoard.src = "/images/game_board_asset/Game_Background.png";
  player.src = "/images/side-eye.jpg";
  bullet1.src = "/images/red_bullet_asset/Red_Bullet.png";
  bullet2.src = "/images/green_bullet_asset/Green_Bullet.png";
  bullet3.src = "/images/purple_bullet_asset/Purple_Bullet.png";

  // Render images when loaded
  gameBoard.onload = function () {
    ctx.drawImage(gameBoard, 0, 0, 800, 800);
  };

  bullet1.onload = function () {
    ctx.drawImage(bullet1, bullet1_xy[0], bullet1_xy[1], 40, 40);
    bullet1_xy[0] += 20;
  };

  bullet2.onload = function () {
    ctx.drawImage(bullet2, bullet2_xy[0], bullet2_xy[1], 40, 40);
    bullet2_xy[0] += 20;
  };

  bullet3.onload = function () {
    ctx.drawImage(bullet3, bullet3_xy[0], bullet3_xy[1], 40, 40);
    bullet3_xy[0] += 20;
  };

  player.onload = function () {
    ctx.drawImage(player, myData.x, myData.y, 130, 100);
  };
};

Hooks.Game3 = {
  mounted() {
    console.log("Game mounted");
    let pressedKeys = new Set(); // Set to track pressed keys

    // Initial Render
    drawGame3();

    window.addEventListener("keydown", (e) => {
      if (!pressedKeys.has(e.key)) {
        pressedKeys.add(e.key); // Add pressed key to the set
        this.pushEvent("start_move", { key: e.key }, (reply) => {
          console.log("reply", reply);
          // Render on key-event, will be changed to on broadcast received
          drawGame3();
        });
      }
    });

    window.addEventListener("keyup", (e) => {
      if (pressedKeys.has(e.key)) {
        pressedKeys.delete(e.key); // Remove released key from the set
        this.pushEvent("stop_move", { key: e.key });
      }
    });

    // Add event listener for the "click" event
    window.addEventListener("click", () => {
      this.pushEvent("shoot", {});
    });
  },
};

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
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
