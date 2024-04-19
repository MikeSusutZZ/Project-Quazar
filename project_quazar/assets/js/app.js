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

//Render game board hook
Hooks.GameBoardHook = {
  mounted() {
    let pressedKeys = new Set();
    //assets
    const canvas = document.getElementById("main");
    gameBoard = new Image();
    gameBoard.src = "/images/game_board_asset/Game_Background.png";
    gameBoard.onload = function () {
      drawGameBoard(canvas, gameBoard, myShip, enemyShip);
    };
    myShip = new Image();
    myShip.src = "/images/ship_asset/blue_ship_trimmed.png";
    enemyShip = new Image();
    enemyShip.src = "/images/ship_asset/red_ship_trimmed.png";
    let tankShip = new Image();
    let destroyerShip = new Image();
    let scoutShip = new Image();
    tankShip.src = "/images/ship_asset/red_ship_trimmed.png";
    destroyerShip.src = "/images/ship_asset/purple_ship_trimmed.png";
    scoutShip.src = "/images/ship_asset/blue_ship_trimmed.png";
    let shipTypes = {
      tank: tankShip,
      destroyer: destroyerShip,
      scout: scoutShip,
    };

    //bullet types
    let lightBullet = new Image();
    let mediumBullet = new Image();
    let heavyBullet = new Image();
    lightBullet.src = "/images/purple_bullet_asset/Purple_Bullet.png";
    mediumBullet.src = "/images/green_bullet_asset/Green_Bullet.png";
    heavyBullet.src = "/images/red_bullet_asset/Red_Bullet.png";

    let bulletTypes = {
      light: lightBullet,
      medium: mediumBullet,
      heavy: heavyBullet,
    };

    // event handlers
    this.handleEvent("update", (_) => {
      drawGameBoard(
        canvas,
        gameBoard,
        myShip,
        enemyShip,
        bulletTypes,
        shipTypes
      );
    });

    // push events
    // Keydown event listener
    canvas.addEventListener("mousedown", (e) => {
      console.log(e);
      this.pushEvent("key_down", { key: " " });
    });

    canvas.addEventListener("mouseup", (e) => {
      console.log(e);
      this.pushEvent("key_up", { key: " " });
    });

    window.addEventListener("keydown", (e) => {
      if (!pressedKeys.has(e.key)) {
        console.log(e.key);
        pressedKeys.add(e.key); // Add pressed key to the set
        this.pushEvent("key_down", { key: e.key });
      }
    });

    // Key Up event listener
    window.addEventListener("keyup", (e) => {
      if (pressedKeys.has(e.key)) {
        pressedKeys.delete(e.key); // Remove released key from the set
        this.pushEvent("key_up", { key: e.key });
      }
    });
  },
};

function drawGameBoard(
  canvas,
  gameBoard,
  myShip,
  enemyShip,
  bulletTypes,
  shipTypes
) {
  // drawing the background
  canvas.width = 800;
  canvas.height = 800;
  ctx = canvas.getContext("2d");
  ctx.drawImage(gameBoard, 0, 0, 800, 800);

  // getting the data
  const data = JSON.parse(canvas.getAttribute("data-game-state"));

  // Get the player name from the route parameters
  const playerName = canvas.getAttribute("data-name");

  //console.log("Data", data);

  //console.log("Player", playerName);

  // Find the player with the matching name and remove from the list
  let me = null;
  for (let i = 0; i < data.players.length; i++) {
    const player = data.players[i];
    if (player.name === playerName) {
      me = player;
      // Remove the player from the players list
      data.players.splice(i, 1);
      break; // Stop searching once we find a match
    }
  }
  try {
    drawShip(
      ctx,
      shipTypes[me.ship.type],
      me.ship.kinematics.px,
      me.ship.kinematics.py,
      me.ship.kinematics.angle,
      me.name,
      me.ship.health,
      me.ship.max_health,
      me.ship.radius,
      playerName,
      me.ship.type
    );
  } catch {
    //console.log("frame skip");
  }

  const enemies = data.players;
  enemies.forEach((enemy) => {
    try {
      drawShip(
        ctx,
        shipTypes[enemy.ship.type],
        enemy.ship.kinematics.px,
        enemy.ship.kinematics.py,
        enemy.ship.kinematics.angle,
        enemy.name,
        enemy.ship.health,
        enemy.ship.max_health,
        enemy.ship.radius,
        playerName,
        enemy.ship.type
      );
    } catch {
      //console.log("frame skip");
    }
  });

  const bullets = data.projectiles;

  //console.log(bullets);

  bullets.forEach((bullet) => {
    drawBullet(
      ctx,
      bulletTypes[bullet.type],
      bullet.kinematics.px,
      bullet.kinematics.py,
      bullet.radius
    );
  });
}

function drawShip(
  ctx,
  ship,
  px,
  py,
  angle,
  name,
  health,
  maxHealth,
  radius,
  playerName,
  srcType
) {
  const spriteSize = radius * 2;
  const xOffset = 10;
  const yOffset = 60;
  const textSize = 10;

  let shipSrc = {
    tank: "/images/ship_asset/red_ship_trimmed.png",
    destroyer: "/images/ship_asset/purple_ship_trimmed.png",
    scout: "/images/ship_asset/blue_ship_trimmed.png",
  };

  //console.log("ship", ship);

  if (health <= 0) {
    ship.src = "/images/ship_asset/boom1.png";
  } else {
    ship.src = shipSrc[srcType];
  }

  ctx.save();
  ctx.translate(px + spriteSize / 2 - xOffset, py + spriteSize / 2 - xOffset); // Adjust these values according to the sprite size
  ctx.rotate((angle - Math.PI / 2) * -1);
  ctx.drawImage(ship, -spriteSize, -spriteSize, spriteSize * 2, spriteSize * 2); // Adjust the sprite size here
  ctx.restore();

  ctx.font = "20px";
  ctx.textAlign = "center";

  //console.log("rounded", Math.round(health));

  ctx.fillStyle = "white";
  if (name == playerName.replace(/^"|"$/g, '')) {
    ctx.font = "20px Arial";
    ctx.fillText(
      name,
      px + spriteSize - xOffset * 2,
      py + spriteSize - yOffset * 1.1
    );
  } else {
    ctx.font = "10px Arial";
    ctx.fillText(
      name,
      px + spriteSize - xOffset * 2,
      py + spriteSize - yOffset
    );
  }
  ctx.font = "10px Arial";

  healthRatio = parseFloat(health) / maxHealth;
  ctx.fillStyle =
    healthRatio > 0.8 ? "green" : healthRatio > 0.4 ? "yellow" : "red";
  ctx.fillText(
    Math.round(health),
    px + spriteSize - xOffset * 2,
    py + spriteSize - yOffset + textSize
  );
}

function drawBullet(ctx, bulletimg, px, py, radius) {
  const spriteSize = radius * 2;
  //console.log("bullet", bulletimg);
  ctx.save();
  ctx.translate(px + spriteSize / 2, py + spriteSize / 2);
  ctx.drawImage(
    bulletimg,
    -(radius * 2),
    -(radius * 2),
    spriteSize,
    spriteSize
  );
  ctx.restore();
}

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
});

//Styling Hooks for gameover screen
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
liveSocket.disableDebug();
