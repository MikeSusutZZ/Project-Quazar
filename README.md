<h1 align="center"> :rocket: Project-Quazar :rocket: </h1>

Dive into the galactic world of **Project Quazar**! In this action-packed multiplayer space shooter, players face off in intense skirmishes, aiming to obliterate enemy ships and rack up points. Choose your arsenal from a variety of unique space ships and devastating bullet types that fit your combat style. Thrive in the chaos of current games and etch your name onto the leaderboards. Are you ready to claim your place among the stars in Project Quazar? Join the fray and dominate the galaxy!

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

**Project Quazar** is a multiplayer space shooter game designed by students in BCIT's CST Programming Paradigms Option. Built on the innovative Phoenix Framework and powered by Elixir and JavaScript, this game lets you pilot a variety of unique ships, unleash powerful bullets, and battle it out for the top spot on the leaderboard. Dive into the action and connect with other players around the globe in this galactic showdown!

![-----------------------------------------------------](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png)

<h2 id="instructions"> :video_game: User Instructions</h2>

First time piloting a space ship in **Project Quazar**? We're here to help:

### Starting the Game

1. Click **Start Game** on the main menu to begin your space adventure.

<p align="center"> 
  <img src="main_menu.png" alt="" height="200px" width="350">
</p>

2. You'll be taken to a setup screen where you can personalize your gameplay:
   - **Enter your username**: Choose a unique identifier for your space hero.
   - **Choose your Ship**: Select a ship type. Each has different health and speed stats:
     - _Tank_ - High health, slow speed.
     - _Destroyer_ - Balanced health and speed.
     - _Scout_ - Low health, high speed.
   - **Choose your Bullet**: Decide on your ammunition:
     - _Heavy_ - High damage, slow speed.
     - _Medium_ - Moderate damage and speed.
     - _Light_ - Low damage, high speed.
3. Hit **Submit** to lock in your choices.

### In-Game Controls

- Use **WASD** keys to rotate and move your ship across the galaxy.
- Press the **Spacebar** to fire your selected ammunition at enemy ships.
- Your ship will regenerate 1 HP (health point) every second—use this to your advantage!

### Game Board

- Engage in stellar dogfights on the game board.
- Your ship's health is precious! Avoid lingering in the red border, which depletes your HP by 1 every second.
- Remember, if you fly off the screen, it's game over.

<p align="center"> 
  <img src="game_board.png" alt="" height="200px" width="200">
</p>

### Scoreboard and Points

- Keep an eye on the scoreboard to the right to track your score and see how you stack up against the competition.

<p align="center"> 
  <img src="score_board.png" alt="" height="50px" width="100">
</p>

- Show off your sharpshooting skills! Each successful hit on an enemy ship boosts your score by 25 points.
- Aim true, and you may find your name etched into the high scores for all of Project Quazar to see!

Ready your thrusters and prepare for your first match in **Project Quazar**!

![-----------------------------------------------------](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png)

<h2 id="overview"> :cloud: Overview</h2>

For the development of Project Quazar, we organized our efforts into three specialized teams, each focusing on a distinct aspect of the game to ensure an engaging player experience.

Menus Team: Tasked with crafting the first impressions, this team designed the intuitive start screen and user interfaces that players interact with throughout the game. Their work is crucial in making navigation and settings both easy and enjoyable.

Backend Team: The backbone of our game operations, this team handled all the game logic. From scoring systems to multiplayer interactions, they ensured that the game runs smoothly, with every action and reaction precisely programmed for fairness and fun.

Frontend Team: Bringing the visual magic, this team was responsible for rendering all the game elements on the screen. Their expertise in graphics and animation brought the space battles to life!

Each team's dedicated efforts were seamlessly integrated into the final product, creating a cohesive and captivating gaming experience that we are proud to present to the world.

![-----------------------------------------------------](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png)

<h2 id="menu"> :page_with_curl: Menus Team</h2>

The Menus team was responsible for creating the following:

- **Start Screen**: Includes the Play and High Scores buttons
- **Create Ship Screen**: Where players name their ship, select a ship type, and select a weapon type
- **In-Game High Scores Screen** : Displays the scores of all players in the current game, from highest to lowest
- **All-Time High Scores Screen** : Displays the scores of all players who have ever played the game, from highest to lowest

![Menus Team Screenshot](image.png "Menus Team Screenshot")

## Team Members

- Amarjot Sangha
- Carson Olafson
- Ediljohn Joson
- Rhys Mahannah

![-----------------------------------------------------](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png)

<h2 id="backend"> :fax: Backend Team</h2>

The Backend team was responsible for creating the following:

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

The Frontend team was responsible for creating the following:

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
