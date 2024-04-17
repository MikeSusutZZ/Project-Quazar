# Frontend Prototype 1
defmodule ProjectQuazarWeb.TestLive do
  use ProjectQuazarWeb, :live_view

  def mount(_params, _session, socket) do
    initial_x = 100
    initial_y = 100
    rotation_angle = 0
    initial_bullet = []
    json_coords = %{x: initial_x, y: initial_y, bullet: initial_bullet}
    {:ok, assign(socket, circle_coords: json_coords, rotation_angle: rotation_angle)}
  end

  def handle_event("move_up", _value, socket) do
    {:noreply,
     update(socket, :circle_coords, fn %{x: current_x, y: current_y, bullet: initial_bullet} ->
       %{x: current_x, y: current_y - 10, bullet: initial_bullet}
     end)}

    dec_y(socket, 0, 10)
  end

  def handle_event("move_down", _value, socket) do
    {:noreply,
     update(socket, :circle_coords, fn %{x: current_x, y: current_y, bullet: initial_bullet} ->
       %{x: current_x, y: current_y + 10, bullet: initial_bullet}
     end)}

    inc_y(socket, 180, 10)
  end

  def handle_event("move_left", _value, socket) do
    {:noreply,
     update(socket, :circle_coords, fn %{x: current_x, y: current_y, bullet: initial_bullet} ->
       %{x: current_x - 10, y: current_y, bullet: initial_bullet}
     end)}

    dec_x(socket, 270, 10)
  end

  def handle_event("move_right", _value, socket) do
    {:noreply,
     update(socket, :circle_coords, fn %{x: current_x, y: current_y, bullet: initial_bullet} ->
       %{x: current_x + 10, y: current_y, bullet: initial_bullet}
     end)}

    inc_x(socket, 90, 10)
  end

  def handle_event("shoot", _value, socket) do
    new_bullet = %{x: socket.assigns.circle_coords.x, y: socket.assigns.circle_coords.y}
    updated_bullets = [new_bullet | socket.assigns.circle_coords.bullet]

    {:noreply,
     assign(socket, :circle_coords, %{socket.assigns.circle_coords | bullet: updated_bullets})}
  end

  # movement
  defp inc_x(socket, rotation, inc) do
    updated_socket =
      socket
      |> update(:rotation_angle, fn _current_angle -> rotation end)
      |> update(:circle_coords, fn %{x: current_x, y: current_y, bullet: initial_bullet} ->
        %{x: current_x + inc, y: current_y, bullet: initial_bullet}
      end)

    {:noreply, updated_socket}
  end

  defp dec_x(socket, rotation, dec) do
    updated_socket =
      socket
      |> update(:rotation_angle, fn _current_angle -> rotation end)
      |> update(:circle_coords, fn %{x: current_x, y: current_y, bullet: initial_bullet} ->
        %{x: current_x - dec, y: current_y, bullet: initial_bullet}
      end)

    {:noreply, updated_socket}
  end

  defp inc_y(socket, rotation, inc) do
    updated_socket =
      socket
      |> update(:rotation_angle, fn _current_angle -> rotation end)
      |> update(:circle_coords, fn %{x: current_x, y: current_y, bullet: initial_bullet} ->
        %{x: current_x, y: current_y + inc, bullet: initial_bullet}
      end)

    {:noreply, updated_socket}
  end

  defp dec_y(socket, rotation, dec) do
    updated_socket =
      socket
      |> update(:rotation_angle, fn _current_angle -> rotation end)
      |> update(:circle_coords, fn %{x: current_x, y: current_y, bullet: initial_bullet} ->
        %{x: current_x, y: current_y - dec, bullet: initial_bullet}
      end)

    {:noreply, updated_socket}
  end
end
