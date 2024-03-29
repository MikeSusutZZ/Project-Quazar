# Project-Quazar

## Menus Team
This guide is specifically for the Menus Team. If you are **NOT** on the Menus Team, please do not alter the `menus` folder without permission.

The Menus team is responsible for creating the following:

- **Start Screen**: includes the Play and High Scores buttons

- **Create Ship** screen: where player names their ship, selects a ship type, and selects a weapon type

- **In-Game High Scores** screen: displays the scores of all players in the current game, from highest to lowest

- **All-Time High Scores** screen: displays the scores of all players who have ever played the game, from highest to lowest

## Team Members
- Amarjot Sangha
- Carson Olafson
- Ediljohn Joson
- Rhys Mahannah

## Instructions

    Ensure you're working in the "menus" subfolder for all menu-related development.

### Setting Up Environment
---

#### (1) Clone the Repository

- Open VS Code

- Press Ctrl+Shift+P (or Cmd+Shift+P on macOS) to open the Command Palette.

- Type `Git: Clone` and select the option.

- Paste the project URL -- `https://github.com/MikeSusutZZ/Project-Quazar.git` -- and hit `Enter`.

- When prompted, select `Open` to open the cloned repository.

#### (2) Install Dependencies

- Right-click on `menus` in the Explorer sidebar and select `Open in Integrated Terminal`

- Run the following command in the terminal: `mix deps.get`

#### (3) Start the Phoenix Server

- In the integrated terminal, start your server with: `mix phx.server`

- Visit `localhost:4000` in your browser to see the application.

### Making Changes
---

#### (1) Create a New Branch

- In VS Code, open the Source Control sidebar by clicking the branch icon on the left or pressing Ctrl+Shift+G.

- Click on the branch name in the bottom left corner to bring up the branch menu.

- Select `Create new branch...` and enter the name for your branch, such as `feature/add-scoreboard`.

#### (2) Writing Code

- Write code associated with the feature.

- Save files and regularly commit changes to your branch.

### Submitting for Review
---

#### (1) Commit Latest Changes

- Ensure your latest changes are committed to your branch.

- Resolve any errors or conflicts before proceeding.

#### (2) Create a Pull Request

- Open GitHub in your browser and navigate to the repository.

- Click on the `Pull requests` tab at the top of the page.

- Click the green `New pull request` button.

- Select your branch from the `compare` dropdown and select `main` as the base branch.

- Click the green `Create pull request` button.

- Add a title and description for your pull request.

- Click the green `Create pull request` button again to submit.

### Best Practices
---

- Always pull the latest changes from main before starting a new feature branch.

- Commit small chunks of work with descriptive messages.

- Regularly push your feature branch to GitHub to back up your work.
