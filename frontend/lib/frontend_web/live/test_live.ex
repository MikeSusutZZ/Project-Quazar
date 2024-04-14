# Frontend Prototype 1
defmodule FrontendWeb.TestLive do
  use FrontendWeb, :live_view

  def mount(_params, _session, socket) do
    initial_x = 100
    initial_y = 100
    json_coords = %{x: initial_x, y: initial_y}
    {:ok, assign(socket, circle_coords: json_coords, rotation_angle: 0)}
  end

  def handle_event("move_up", _value, socket) do
    {:noreply,
     update(socket, :circle_coords, fn %{x: current_x, y: current_y} ->
       %{x: current_x, y: current_y - 10}
     end)}

    dec_y(socket, 0, 10)
  end

  def handle_event("move_down", _value, socket) do
    {:noreply,
     update(socket, :circle_coords, fn %{x: current_x, y: current_y} ->
       %{x: current_x, y: current_y + 10}
     end)}

    inc_y(socket, 180, 10)
  end

  def handle_event("move_left", _value, socket) do
    {:noreply,
     update(socket, :circle_coords, fn %{x: current_x, y: current_y} ->
       %{x: current_x - 10, y: current_y}
     end)}

    dec_x(socket, 270, 10)
  end

  def handle_event("move_right", _value, socket) do
    {:noreply,
     update(socket, :circle_coords, fn %{x: current_x, y: current_y} ->
       %{x: current_x + 10, y: current_y}
     end)}

    inc_x(socket, 90, 10)
  end

  # movement
  defp inc_x(socket, rotation, inc) do
    updated_socket =
      socket
      |> update(:rotation_angle, fn _current_angle -> rotation end)
      |> update(:circle_coords, fn %{x: current_x, y: current_y} ->
        %{x: current_x + inc, y: current_y}
      end)

    {:noreply, updated_socket}
  end

  defp dec_x(socket, rotation, dec) do
    updated_socket =
      socket
      |> update(:rotation_angle, fn _current_angle -> rotation end)
      |> update(:circle_coords, fn %{x: current_x, y: current_y} ->
        %{x: current_x - dec, y: current_y}
      end)

    {:noreply, updated_socket}
  end

  defp inc_y(socket, rotation, inc) do
    updated_socket =
      socket
      |> update(:rotation_angle, fn _current_angle -> rotation end)
      |> update(:circle_coords, fn %{x: current_x, y: current_y} ->
        %{x: current_x, y: current_y + inc}
      end)

    {:noreply, updated_socket}
  end

  defp dec_y(socket, rotation, dec) do
    updated_socket =
      socket
      |> update(:rotation_angle, fn _current_angle -> rotation end)
      |> update(:circle_coords, fn %{x: current_x, y: current_y} ->
        %{x: current_x, y: current_y - dec}
      end)

    {:noreply, updated_socket}
  end
end
