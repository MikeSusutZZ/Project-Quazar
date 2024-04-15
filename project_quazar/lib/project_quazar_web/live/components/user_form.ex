# user_form.ex
defmodule ProjectQuazarWeb.UserForm do
  use ProjectQuazarWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="outer-user-form-container">
      <div class="inner--user-form-container ">

        <form  action="#" method="post" phx-submit="join">
          <label class="username_form_label" for="username">Enter your username:</label>
          <input class="username_form_inputbox" type="text" id="username" name="username">
          <p class="error_message"><%= @error_message %></p>

          <h2> Choose your Ship:</h2>
          <div class="radio-btn-options-container-row">
            <div class='radio-button-option-col'>
              <label class='option_label'>Tank</label>
              <h1 class="health_text">Health: 250</h1>
              <div>
                <input type='radio' name='ship' value='tank' checked>
              </div>
            </div>

            <div class='radio-button-option-col'>
              <label class='option_label'>Destroyer</label>
              <h1 class="health_text">Health: 150</h1>
              <div>
                <input type='radio' name='ship' value='destroyer' checked>
              </div>
            </div>

            <div class='radio-button-option-col'>
              <label class=''>Scout</label>
              <h1 class="health_text">Health: 100</h1>
              <div>
                <input type='radio' name='ship' value='scout' checked>
              </div>
            </div>
          </div>

          <h2 class="bullet_selection_heading"> Choose your Bullet:</h2>
          <div class="radio-btn-options-container-row">

            <div class='radio-button-option-col '>
              <label class='option_label'>Heavy</label>

              <img src={~p"/images/red_bullet_asset/Red_Bullet.png"} alt="Example Image">
              <h1 class="damage_text" >Damage: 35</h1>
              <h1 class="speed_text" >Speed: Slow</h1>
              <div>
                <input type='radio' name='bullet' value='heavy' checked>
              </div>
            </div>

            <div class='radio-button-option-col'>
              <label class='option_label'>Medium</label>
              <img src={~p"/images/green_bullet_asset/Green_Bullet.png"} alt="Example Image">
              <h1 class="damage_text">Damage: 20</h1>
              <h1 class="speed_text">Speed: normal</h1>
              <div>
                <input type='radio' name='bullet' value='medium' checked>
              </div>
            </div>

            <div class='radio-button-option-col'>
              <label>Light</label>
              <img src={~p"/images/purple_bullet_asset/Purple_Bullet.png"} alt="Example Image">
              <h1 class="damage_text">Damage: 10</h1>
              <h1 class="speed_text">Speed: fast</h1>
              <div>
                <input type='radio' name='bullet' value='light' checked>
              </div>
            </div>

          </div>

          <input class= "submit_btn" type="submit" value="Submit">

        </form>

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
