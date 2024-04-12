# user_form.ex
defmodule ProjectQuazarWeb.UserForm do
  use ProjectQuazarWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="outer-container flex justify-center items-center">
      <div class="inner-container">
        <form action="#" method="post" phx-submit="join">
          <label for="username">Enter your username:</label><br>
          <input type="text" id="username" name="username"><br><br>

          <input type="radio" name="ship" value="ship1">
          <label>Ship 1</label> <br>

          <input type="radio" name="bullet" value="bullet1">
          <label>Bullet 1</label> <br>

          <input class= " mt-4 bg-green-600 p-2 rounded cursor-pointer hover:text-white" type="submit" value="Submit">
        </form>
        <p class="text-red-500"><%= @error_message %></p>
      </div>
    </div>
    """
  end
end
