# user_form.ex
defmodule ProjectQuazarWeb.UserForm do
  use ProjectQuazarWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="outer-container rounded bg-gray-50 border-4 border-gray-200 p-3">
      <div class="inner-container w-full flex justify-center items-center">

        <form  action="#" method="post" phx-submit="join">
          <label for="username">Enter your username:</label><br>
          <input type="text" id="username" name="username"><br><br>

          <h2> Choose your Ship:</h2>
          <div class="flex flex-row w-full justify-between  mt-3 mr-3">
            <div class='flex flex-col items-center transition duration-0 ease-in-out transform hover:scale-105 '>
              <label class='mr-2'>Tank</label>
              <h1 class="text-green-600">Health: 250</h1>
              <div>
                <input type='radio' name='ship' value='tank' checked>
              </div>
            </div>

            <div class='flex flex-col items-center mr-3 ml-3 transition duration-0 ease-in-out transform hover:scale-105'>
              <label class='mr-2'>Destroyer</label>
              <h1 class="text-green-600">Health: 150</h1>
              <div>
                <input type='radio' name='ship' value='destroyer' checked>
              </div>
            </div>

            <div class='flex flex-col items-center transition duration-0 ease-in-out transform hover:scale-105'>
              <label class='mr-2'>Scout</label>
              <h1 class="text-green-600">Health: 100</h1>
              <div>
                <input type='radio' name='ship' value='scout' checked>
              </div>
            </div>
          </div>

          <h2 class="mt-2"> Choose your Bullet:</h2>
          <div class="flex flex-row w-full justify-between mt-3 mr-3">

            <div class='flex flex-col  items-center transition duration-0 ease-in-out transform hover:scale-105 '>
              <label class='mr-2'>Heavy</label>

              <img src={~p"/images/red_bullet_asset/Red_Bullet.png"} alt="Example Image">
              <h1 class="text-red-600" >Damage: 35</h1>
              <h1 class="text-yellow-600" >Speed: Slow</h1>
              <div>
                <input type='radio' name='bullet' value='heavy' checked>
              </div>
            </div>

            <div class='flex flex-col items-center mr-3 ml-3 transition duration-0 ease-in-out transform hover:scale-105'>
              <label class='mr-2'>Medium</label>
              <img src={~p"/images/green_bullet_asset/Green_Bullet.png"} alt="Example Image">
              <h1 class="text-red-600">Damage: 20</h1>
              <h1 class="text-yellow-600">Speed: fast</h1>
              <div>
                <input type='radio' name='bullet' value='medium' checked>
              </div>
            </div>

            <div class='flex flex-col items-center transition duration-0 ease-in-out transform hover:scale-105'>
              <label class='mr-2'>Light</label>
              <img src={~p"/images/purple_bullet_asset/Purple_Bullet.png"} alt="Example Image">
              <h1 class="text-red-600">Damage: 10</h1>
              <h1 class="text-yellow-600">Speed: very fast</h1>
              <div>
                <input type='radio' name='bullet' value='light' checked>
              </div>
            </div>

          </div>

          <input class= " mt-4 bg-green-600 p-2 rounded cursor-pointer hover:text-white" type="submit" value="Submit">
        </form>
        <p class="text-red-500"><%= @error_message %></p>
        <span phx-window-keydown="ping_server"></span>
        <span phx-window-keydown="control"></span>
      </div>
    </div>
    """
  end

  def radio_input(label) do
    ~S"""
    <div class='flex flex-col items-center'>
            <label class='mr-2'>#{label}</label>
            <div>
            <input type='radio' name='ship' value='#{String.upcase(label)}' checked>
            </div>
      </div>
    """
  end

end
