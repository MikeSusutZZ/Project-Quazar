<h1 align="center"> :rocket: Project-Quazar :rocket: </h1>

Project Quazar is a multiplayer space shooter game developed by students at BCIT in the Programming Paradigms Option. The game is built using the Phoenix Framework, Elixir, and JavaScript. The game features a variety of ships and bullets, as well as high scores and multiplayer capabilities.

![-----------------------------------------------------](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png)

## :book: Table of Contents

<details open="open">
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#about-the-project"> ➤ About The Project</a></li>
    <li><a href="#instructions"> ➤ Instructions</a></li>
    <li><a href="#overview"> ➤ Overview</a></li>
    <li><a href="#menu"> ➤ Menus Team</a></li>
    <li><a href="#backend"> ➤ Backend Team</a></li>
    <li><a href="#frontend"> ➤ Frontend Team</a></li>
    <li><a href="#setting-up-your-environments"> ➤ Setting Up Your Environment</a></li>
    <li><a href="#making-changes"> ➤ Making Changes</a></li>
    <li><a href="#submitting-for-review"> ➤ Submitting for Review</a></li>
    <li><a href="#credits"> ➤ Credits</a></li>
  </ol>
</details>

![-----------------------------------------------------](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png)

<h2 id="about-the-project"> :pencil: About The Project</h2>

Project Quazar's goal of the game is to engage in multiplayer battles, where players try to destroy enemy ships in and earn points. Players can choose from a variety of ships and bullet types. The game features a high score system that displays the top scores of all players in the current game, as well as the all-time top scores.

![-----------------------------------------------------](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png)

<h2 id="instructions"> :notebook: Instructions</h2>

## :video_game: User Instructions

Welcome to the interstellar arena of **Project Quazar**! Here's how to get started:

### Starting the Game

1. Click **Start Game** on the main menu to begin your space adventure.
2. You'll be taken to a setup screen where you can personalize your gameplay:
    - **Enter your username**: Choose a unique identifier for your space hero.
    - **Choose your Ship**: Select a ship type. Each has different health and speed stats:
        - *Tank* - High health, slow speed.
        - *Destroyer* - Balanced health and speed.
        - *Scout* - Low health, high speed.
    - **Choose your Bullet**: Decide on your ammunition:
        - *Heavy* - High damage, slow speed.
        - *Medium* - Moderate damage and speed.
        - *Light* - Low damage, high speed.
3. Hit **Submit** to lock in your choices.

### In-Game Controls

- Use **WASD** keys to rotate and move your ship across the cosmos.
- Press the **Spacebar** to fire your selected ammunition at enemy ships.
- Your ship will regenerate 1 HP (health point) every second—use this to your advantage!

### Game Board and Scoreboard

- Engage in stellar dogfights on the game board. Keep an eye on the scoreboard to the right to track your score and see how you stack up against the competition.
- Your ship's health is precious! Avoid lingering in the red border, which depletes your HP by 1 every second.
- Remember, if you fly off the screen, it's game over.

### Scoring Points

- Show off your sharpshooting skills! Each successful hit on an enemy ship boosts your score by 25 points.
- Aim true, and you may find your name etched into the high scores for all of Project Quazar to see!

Ready your thrusters and prepare for an epic space showdown in **Project Quazar**!


![-----------------------------------------------------](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png)

<h2 id="overview"> :cloud: Overview</h2>

The game is divided into three main teams: Menus, Backend, and Frontend. Each team is responsible for different aspects of the game, such as creating the start screen, handling game logic, and rendering game elements on the screen.

![-----------------------------------------------------](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png)

<h2 id="menu"> :page_with_curl: Menus Team</h2>

The Menus team is responsible for creating the following:

- **Start Screen**: includes the Play and High Scores buttons
- **Create Ship Screen**: where players name their ship, select a ship type, and select a weapon type
- **In-Game High Scores Screen** : displays the scores of all players in the current game, from highest to lowest
- **All-Time High Scores Screen** : displays the scores of all players who have ever played the game, from highest to lowest

![Menus Team Screenshot](image.png "Menus Team Screenshot")

## Team Members

- Amarjot Sangha
- Carson Olafson
- Ediljohn Joson
- Rhys Mahannah

![-----------------------------------------------------](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png)

<h2 id="backend"> :fax: Backend Team</h2>

The Backend team is responsible for creating the following:

- **Bullet**: Handles all bullet-related operations
- **CollisionHandler**: Handles collision detection between game entities (bullet/player/ship)
- **GameBoundary**: Handles boundary collision logic
- **GameServer**: Contains the main game logic
- **Movable**: Handles an object's position/velocity/direction
- **Player**: Stores all player-related functionality
- **Ship**: Contains all ship-related functionality
- **ETSWrapper**: Uses ETS operations for high scores
- **HighScores**: Manages high scores
- **Application**: the entry point, sets up supervision trees
- **Mailer**: Handles email-sending capabilities within the application

![Backend Team Screenshot](backend.png "Backend Team Diagram")

## Team Members

- Olga Zimina
- Dakaro Mueller
- Abhishek Chouhan
- Alex Sichitiu
- Shawn Birring
- Mikko Sio
- Michelle Kwok

![-----------------------------------------------------](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png)

<h2 id="frontend"> :tv: Frontend Team</h2>

The Frontend team is responsible for creating the following:

### Design Elements

- **Design Bullets**

  - Create bullet assets.
  - Render bullets on screen.
  - Handle bullet movement dynamics.

- **Design Player**

  - Create player ship asset.
  - Render player ship and health bar on screen.
  - Display player's name.
  - Manage player ship movement.

- **Design Game Board**
  - Create assets for the game board.
  - Set up boundaries for the game board.
  - Render the game board.

### Multiplayer Features

- **Multiplayer**: Implement rendering processes for multiplayer interactions.

### Core Components

- **Components**: Define and manage interactive components essential for gameplay.

- **Render Canvas**: Set up and manage the canvas where the game elements are rendered.

- **PubSub System**: Implement a Publish-Subscribe system to handle event-driven interactions within the game.

<br>

![Frontend Team Screenshot](frontend_and_menu.png "Frontend Team Diagram")

## Team Members

- Sean Sollestre
- Aditya Agrawai
- Josh Chuah
- Jason Shi
- Shuyi Liu
- Emily Tran
- Daniel Okonov

![-----------------------------------------------------](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png)

<h2 id="setting-up-your-environments"> :wrench: Setting Up Your Environment</h2>

### (1) Clone the Repository

- Open **VS Code**
- Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on macOS) to open the Command Palette.
- Type `Git: Clone` and select the option.
- Paste the project URL: `https://github.com/MikeSusutZZ/Project-Quazar.git` and hit `Enter`.
- When prompted, select `Open` to open the cloned repository.

### (2) Install Dependencies

- Right-click on `project_quazar` in the Explorer sidebar and select `Open in Integrated Terminal`
- Run the following command in the terminal: `mix deps.get`

### (3) Start the Phoenix Server

- In the integrated terminal, start your server with: `mix phx.server`
- Visit `localhost:4000` in your browser to see the application.

![-----------------------------------------------------](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png)

<h2 id="making-changes"> :clipboard: Making Changes</h2>

### (1) Create a New Branch

- In VS Code, open the Source Control sidebar by clicking the branch icon on the left or pressing `Ctrl+Shift+G`.
- Click on the branch name in the bottom left corner to bring up the branch menu.
- Select `Create new branch...` and enter the name for your branch, such as `feature/add-scoreboard`, then hit `Enter`.
- Click `Publish Branch` in the left sidebar, to push your branch to GitHub.
- Check the bottom-left corner to ensure you're on your new branch.

### (2) Writing Code

- Write code associated with the feature.
- Save files and regularly commit changes to your branch.

![-----------------------------------------------------](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png)

<h2 id="submitting-for-review"> :mailbox: Submitting for Review</h2>

### (1) Commit Latest Changes

- Ensure your latest changes are committed to your branch.
- Resolve any errors or conflicts before proceeding.

### (2) Create a Pull Request

- Open GitHub in your browser and navigate to the repository.
- You should see, in a yellow banner, the prompt `Compare & pull request`. Click this.
- Add a title and brief description.
- On the right-hand side, click the gear icon to assign reviewers. Assign `rhysmah`.
- Click the green `Create pull request` button.
- Wait for feedback. Make any necessary changes and push them to your branch.
- Click the green `Merge pull request` button to merge your changes into the main branch.
- Click the `Delete branch` button to remove your feature branch.

![-----------------------------------------------------](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png)

<h2 id="credits"> :pray: Credits</h2>

We would like to thank everyone in our class for contributing to this awesome project. It was a blast working with all of you. All the all-nighters, the debugging, the laughter, and the frustration were worth it in the end. We hope you enjoy playing Project Quazar as much as we enjoyed making it! :rocket:

To Albert, our instructor, thank you for making us work on a 19-person project. It was a challenge with all the merge conflicts, but we learned a lot and had fun along the way.
