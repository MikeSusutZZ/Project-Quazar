# "w" -> GameServer.accelerate_pressed(player_name)
#       "s" -> GameServer.brake_pressed(player_name)
#       "d" -> GameServer.turn_right_pressed(player_name)
#       "a" -> GameServer.turn_left_pressed(player_name)
#       " " -> GameServer.fire_pressed(player_name)

# "w" ->
#   GameServer.accelerate_released(player_name)

# "s" ->
#   GameServer.brake_released(player_name)

# "d" ->
#   GameServer.turn_right_released(player_name)

# "a" ->
#   GameServer.turn_left_released(player_name)

# " " ->
#   GameServer.fire_released(player_name)


defmodule Bot do
  def decide player, player_list do
    target =
      Enum.filter(player_list, fn p ->
        p.name != player.name
      end) |>
      List.last()
    if target do
      turn_direction(player, target)
      GameServer.fire_pressed(player.name)
    else
      GameServer.fire_released(player.name)
    end

    player
  end

  def turn_direction(player, target) do
    dx = target.ship.kinematics.px - player.ship.kinematics.px
    dy = target.ship.kinematics.py - player.ship.kinematics.py
    target_angle = :math.atan2(dy, dx)
    opp_dir = player.ship.kinematics.angle - target_angle  # Inverted calculation here

    opp_dir =
      case opp_dir do
        dir when dir < -6.28 -> dir + 6.28318
        dir when dir > 6.28 -> dir - 6.28318
        dir -> dir
      end

    player_name = player.name
    if player_name == "bot" do
      IO.inspect(opp_dir)
    end

    case opp_dir do
      _ when opp_dir < -0.1 ->
        GameServer.turn_right_pressed(player_name)  # Adjusted the turn directions
        GameServer.turn_left_released(player_name)
        GameServer.fire_released(player_name)
      _ when opp_dir > 0.1 ->
        GameServer.turn_left_pressed(player_name)  # Adjusted the turn directions
        GameServer.turn_right_released(player_name)
        GameServer.fire_released(player_name)
      _ ->
        GameServer.fire_pressed(player_name)
        GameServer.turn_left_released(player_name)
        GameServer.turn_right_released(player_name)
    end
  end


end
