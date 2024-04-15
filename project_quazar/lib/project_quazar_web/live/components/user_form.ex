# user_form.ex
defmodule ProjectQuazarWeb.UserForm do
  use ProjectQuazarWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="outer-container">
      <div class="inner-container">
        <form action="#" method="post" phx-submit="join">
          <label for="username">Enter your username:</label><br>
          <input type="text" id="username" name="username"><br><br>
          <input type="submit" value="Submit">
        </form>
        <p class="text-red-500"><%= @error_message %></p>
        <span phx-window-keydown="ping_server"></span>
        <span phx-window-keydown="control"></span>
      </div>
    </div>
    """
  end
end
