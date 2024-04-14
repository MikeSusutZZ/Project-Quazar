defmodule ProjectQuazarWeb.GameOver do
  use ProjectQuazarWeb, :live_view

  def mount(%{"score" => score} = params, _session, socket) do
    {:ok, assign(socket, score: score)} #this is being hard coded for now, will be dynamic
  end


  def handle_event("return_to_main_menu", _params, socket) do
    {:noreply, push_redirect(socket, to: "/start")}
  end

end
