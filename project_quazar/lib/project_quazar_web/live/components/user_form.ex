# user_form.ex
defmodule ProjectQuazarWeb.UserForm do
  use ProjectQuazarWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="outer-user-form-container">
    <h1 class="title"> Join Game </h1>
      <div class="inner--user-form-container ">

        <form  action="#" method="post" phx-submit="join">
          <label class="username_form_label heading" for="username">Enter your username:</label>
          <input class="username_form_inputbox" type="text" id="username" name="username">
          <p class="error_message"><%= @error_message %></p>

          <h2 class= "heading"> Choose your Ship:</h2>
          <div class="radio-btn-options-container-row">
            <div class='radio-button-option-col'>
              <label class='option_label sub_heading'>Tank</label>
              <img src={~p"/images/ship_asset/red_ship_trimmed.png"} alt="Example Image" style="width: 40px; height: 40px;">
              <h1 class="health_text">Health: 200</h1>
              <h1 class="speed_text">Speed: Slow</h1>
              <div>
                <input type='radio' name='ship' value='tank'>
              </div>
            </div>

            <div class='radio-button-option-col'>
              <label class='option_label sub_heading'>Destroyer</label>
              <img src={~p"/images/ship_asset/purple_ship_trimmed.png"} alt="Example Image" style="width: 40px; height: 40px;">
              <h1 class="health_text">Health: 150</h1>
              <h1 class="speed_text">Speed: normal</h1>
              <div>
                <input type='radio' name='ship' value='destroyer' checked>
              </div>
            </div>

            <div class='radio-button-option-col'>
              <label class='sub_heading'>Scout</label>
              <img src={~p"/images/ship_asset/blue_ship_trimmed.png"} alt="Example Image" style="width: 40px; height: 40px;">
              <h1 class="health_text">Health: 100</h1>
              <h1 class="speed_text">Speed: fast</h1>
              <div>
                <input type='radio' name='ship' value='scout'>
              </div>
            </div>
          </div>

          <h2 class="bullet_selection_heading heading"> Choose your Bullet:</h2>
          <div class="radio-btn-options-container-row">

            <div class='radio-button-option-col '>
              <label class='option_label sub_heading'>Heavy</label>

              <img src={~p"/images/red_bullet_asset/Red_Bullet.png"} alt="Example Image" style="width: 30px; height:  30px;">
              <h1 class="damage_text" >Damage: 40</h1>
              <h1 class="speed_text" >Speed: Slow</h1>
              <div>
                <input type='radio' name='bullet' value='heavy'>
              </div>
            </div>

            <div class='radio-button-option-col'>
              <label class='option_label sub_heading'>Medium</label>
              <img src={~p"/images/green_bullet_asset/Green_Bullet.png"} alt="Example Image" style="width: 30px; height:  30px;">
              <h1 class="damage_text">Damage: 25</h1>
              <h1 class="speed_text">Speed: normal</h1>
              <div>
                <input type='radio' name='bullet' value='medium' checked>
              </div>
            </div>

            <div class='radio-button-option-col'>
              <label class="sub_heading">Light</label>
              <img src={~p"/images/purple_bullet_asset/Purple_Bullet.png"} alt="Example Image" style="width: 30px; height: 30px;">
              <h1 class="damage_text">Damage: 10</h1>
              <h1 class="speed_text">Speed: fast</h1>
              <div>
                <input type='radio' name='bullet' value='light'>
              </div>
            </div>

          </div>

          <input class= "submit_btn" type="submit" value="Submit">

        </form>


      </div>
    </div>
    """
  end
end
