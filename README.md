# Project-Quazar

## Menus Team

The Menus team is responsible for creating the following:

- **Start Screen**: includes the Play and High Scores buttons
- **Create Ship** screen: where players name their ship, select a ship type, and select a weapon type
- **In-Game High Scores** screen: displays the scores of all players in the current game, from highest to lowest
- **All-Time High Scores** screen: displays the scores of all players who have ever played the game, from highest to lowest

<br>

![Menus Team Screenshot](image.png "Menus Team Screenshot")

## Team Members

- Amarjot Sangha
- Carson Olafson
- Ediljohn Joson
- Rhys Mahannah

## Backend Team

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

<br>

![Backend Team Screenshot](backend.png "Backend Team Diagram")

## Team Members

- Olga Zimina
- Dakaro Mueller
- Abhishek Chouhan
- Alex Sichitiu
- Shawn Birring
- Mikko Sio
- Michelle Kwok

## Front Team

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

- **Multiplayer**
  - Implement rendering processes for multiplayer interactions.

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

### Setting Up Your Environment

#### (1) Clone the Repository

- Open **VS Code**
- Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on macOS) to open the Command Palette.
- Type `Git: Clone` and select the option.
- Paste the project URL: `https://github.com/MikeSusutZZ/Project-Quazar.git` and hit `Enter`.
- When prompted, select `Open` to open the cloned repository.

#### (2) Install Dependencies

- Right-click on `project_quazar` in the Explorer sidebar and select `Open in Integrated Terminal`
- Run the following command in the terminal: `mix deps.get`

#### (3) Start the Phoenix Server

- In the integrated terminal, start your server with: `mix phx.server`
- Visit `localhost:4000` in your browser to see the application.

### Making Changes

#### (1) Create a New Branch

- In VS Code, open the Source Control sidebar by clicking the branch icon on the left or pressing `Ctrl+Shift+G`.
- Click on the branch name in the bottom left corner to bring up the branch menu.
- Select `Create new branch...` and enter the name for your branch, such as `feature/add-scoreboard`, then hit `Enter`.
- Click `Publish Branch` in the left sidebar, to push your branch to GitHub.
- Check the bottom-left corner to ensure you're on your new branch.

#### (2) Writing Code

- Write code associated with the feature.
- Save files and regularly commit changes to your branch.

### Submitting for Review

#### (1) Commit Latest Changes

- Ensure your latest changes are committed to your branch.
- Resolve any errors or conflicts before proceeding.

#### (2) Create a Pull Request

- Open GitHub in your browser and navigate to the repository.
- You should see, in a yellow banner, the prompt `Compare & pull request`. Click this.
- Add a title and brief description.
- On the right-hand side, click the gear icon to assign reviewers. Assign `rhysmah`.
- Click the green `Create pull request` button.
- Wait for feedback. Make any necessary changes and push them to your branch.
- Click the green `Merge pull request` button to merge your changes into the main branch.
- Click the `Delete branch` button to remove your feature branch.
