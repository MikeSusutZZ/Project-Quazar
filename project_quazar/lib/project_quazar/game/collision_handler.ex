defmodule CollisionHandler do
  @moduledoc """
  Handles collision detection between game entities.
  """

  @doc """
  Checks for collisions between a list of bullets and ships.
  Returns tuples of collided bullets and ships.
  """
  def check_collisions(bullets, players) do
    Enum.flat_map(bullets, fn bullet ->
      Enum.filter(players, fn player -> collide?(bullet, player.ship) end)
      |> Enum.map(&{bullet, &1})
    end)
  end

  defp collide?(%Bullet{kinematics: %{px: bullet_px, py: bullet_py}},
              %Ship{kinematics: %{px: ship_px, py: ship_py}, size: ship_size}) do
    distance({bullet_px, bullet_py}, {ship_px, ship_py}) < ship_size
  end

  defp distance({x1, y1}, {x2, y2}) do
    :math.sqrt(:math.pow(x2 - x1, 2) + :math.pow(y2 - y1, 2))
  end
end
