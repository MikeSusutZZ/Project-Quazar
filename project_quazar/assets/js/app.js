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

// Game Channel imports
import "./game_socket.js";
import socket from "./game_socket.js";

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

Hooks.FadeIn = {
  mounted() {
    console.log("FadeIn mounted, applying styles...");
    this.el.style.opacity = 0;
    setTimeout(() => {
      this.el.style.transition = "opacity 5s ease-in-out";
      this.el.style.opacity = 1;
      console.log("Styles applied, opacity should be 1 now.");
    }, 100);
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
  let player1 = new Image();
  let player2 = new Image();
  let player3 = new Image();
  let bullet1 = new Image();
  let bullet2 = new Image();
  let bullet3 = new Image();

  // Link images to assets
  gameBoard.src = "/images/game_board_asset/Game_Background.png";

  // Render images when loaded
  gameBoard.onload = function () {
    console.log("Board rendered");
    ctx.drawImage(gameBoard, 0, 0, 800, 800);

    // Once board is loaded, link to rest of assets to trigger onload
    player1.src = "/images/ship_asset/blue_ship.png";
    player2.src = "/images/ship_asset/purple_ship.png";
    player3.src = "/images/ship_asset/red_ship.png";
    bullet1.src = "/images/red_bullet_asset/Red_Bullet.png";
    bullet2.src = "/images/green_bullet_asset/Green_Bullet.png";
    bullet3.src = "/images/purple_bullet_asset/Purple_Bullet.png";
  };

  bullet1.onload = function () {
    console.log("Bullet1 rendered");
    ctx.drawImage(bullet1, bullet1_xy[0], bullet1_xy[1], 40, 40);
    bullet1_xy[0] += 20;
  };

  bullet2.onload = function () {
    console.log("Bullet2 rendered");
    ctx.drawImage(bullet2, bullet2_xy[0], bullet2_xy[1], 40, 40);
    bullet2_xy[0] += 20;
  };

  bullet3.onload = function () {
    console.log("Bullet3 rendered");
    ctx.drawImage(bullet3, bullet3_xy[0], bullet3_xy[1], 40, 40);
    bullet3_xy[0] += 20;
  };

  player1.onload = function () {
    console.log("Player rendered");
    ctx.drawImage(player1, myData.x, myData.y, 300, 300);
  };

  player2.onload = function () {
    console.log("Player rendered");
    ctx.drawImage(player2, myData.x + 100, myData.y, 300, 300);
  };

  player3.onload = function () {
    console.log("Player rendered");
    ctx.drawImage(player3, myData.x + 200, myData.y, 300, 300);
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

// Frontend Prototype 4
const DummyPlayerList = {
  players: [
    {
      name: "Player1",
      score: 1200,
      ship: {
        kinematics: { px: 100, py: 150 },
        max_health: 100,
        current_health: 80,
        bullet_type: "laser",
      },
    },
  ],
};

const drawGame4 = () => {
  let canvas = document.getElementById("circleCanvas");
  let ctx = canvas.getContext("2d");

  // Dummy data for player positions and attributes
  const playerData = DummyPlayerList.players[0]; // Assuming single player for simplicity

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
    bullet1_xy[0] += 20; // Example movement
  };

  bullet2.onload = function () {
    ctx.drawImage(bullet2, bullet2_xy[0], bullet2_xy[1], 40, 40);
    bullet2_xy[0] += 20; // Example movement
  };

  bullet3.onload = function () {
    ctx.drawImage(bullet3, bullet3_xy[0], bullet3_xy[1], 40, 40);
    bullet3_xy[0] += 20; // Example movement
  };

  player.onload = function () {
    // Using the kinematics property from JSON to set player position
    ctx.drawImage(
      player,
      playerData.ship.kinematics.px,
      playerData.ship.kinematics.py,
      130,
      100
    );
  };
};

Hooks.Game4 = {
  mounted() {
    console.log("Game mounted");
    let pressedKeys = new Set();

    // Initial Render
    drawGame4();

    window.addEventListener("keydown", (e) => {
      if (!pressedKeys.has(e.key)) {
        pressedKeys.add(e.key);
        this.pushEvent("start_move", { key: e.key }, (reply) => {
          console.log("reply", reply);
          drawGame4();
        });
      }
    });

    window.addEventListener("keyup", (e) => {
      if (pressedKeys.has(e.key)) {
        pressedKeys.delete(e.key);
        this.pushEvent("stop_move", { key: e.key });
      }
    });

    window.addEventListener("click", () => {
      this.pushEvent("shoot", {});
    });
  },
};

Hooks.ChannelHook = {
  mounted() {
    console.log("Channel mounted");
    const currentUrl = window.location.href;
    const url = new URL(currentUrl);
    const pathname = url.pathname;
    const parts = pathname.split("/");
    const name = parts[parts.length - 1];
    let pressedKeys = new Set(); // Set to track pressed keys

    this.pushEvent("greet", { channelSocket: socket });
    let channel = socket.channel("room:lobby", { name: name });

    // Join the channel (Like + Subscribe + Notifications)
    channel
      .join()
      .receive("ok", (resp) => {
        console.log("Joined successfully", resp);
      })
      .receive("error", (resp) => {
        console.log("Unable to join", resp);
      });

    // On mount message
    channel.push("mounted", {}).receive("ok", (resp) => {
      console.log("Reply from server:", resp);
    });

    // Display "Game State"
    let messagesContainer = document.querySelector("#messages");

    // Keydown event listener
    window.addEventListener("keydown", (e) => {
      if (!pressedKeys.has(e.key)) {
        pressedKeys.add(e.key); // Add pressed key to the set
        channel.push("keydown", { key: e.key });
      }
    });

    // Attempts to promote this client to be the broadcast owner
    function sendPromoteMessage() {
      console.log("Promoting...");
      channel.push("promote", {}).receive("ok", (resp) => {
        console.log("Reply from server:", resp);
      });
    }

    // Attempt to promote every second
    setInterval(sendPromoteMessage, 1000);

    // Key Up event listener
    window.addEventListener("keyup", (e) => {
      if (pressedKeys.has(e.key)) {
        pressedKeys.delete(e.key); // Remove released key from the set
        // channel.push("keyup", { key: e.key });
      }
    });

    // Listens to channel for user state
    channel.on("user_state", (payload) => {
      messagesContainer.innerHTML = "";
      let messageItem = document.createElement("p");
      console.log(payload);
      messageItem.innerText = `Frame: ${payload.count}, Data: ${JSON.stringify(
        payload.users
      )}`;
      messagesContainer.appendChild(messageItem);
    });

    // Listens to channel for broadcast logging
    channel.on("broadcast", () => {
      console.log("Interval broadcast detected");
    });
  },
};

const updateElements = () => {
  let dataElement = document.getElementById("main");
  console.log(dataElement);
  let gameState = JSON.parse(dataElement.getAttribute("data-game-state"));
  let frames = JSON.parse(dataElement.getAttribute("data-frames"));
  console.log("My data", gameState);
  console.log("My data", frames);

  dataElement.innerHTML = `Frame: ${frames}, Data: ${JSON.stringify(
    gameState
  )}`;
};

Hooks.PubsubPrototype = {
  mounted() {
    console.log("Mounted");

    this.handleEvent("update", (data) => {
      console.log(data);
      updateElements();
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
