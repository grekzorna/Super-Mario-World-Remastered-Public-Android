extends PlayerState

var travel_index := 0.0

var travel_speed := 200
var travel_direction := 1

func enter(_msg := {}) -> void:
	travel_index = player.pipe_travel_path.get_closest_offset(player.global_position)
	if player.pipe_travel_reverse:
		travel_direction = -1
	else:
		travel_direction = 1

func physics_update(delta: float) -> void:
	player.hide()
	travel_index += (player.pipe_travel_speed * travel_direction) * delta
	player.global_position = player.pipe_travel_path.sample_baked(travel_index) + Vector2(0, 16)
	if travel_direction == 1:
		if travel_index >= player.pipe_travel_path.get_baked_length() - 15:
			player.exit_pipe(player.pipe_travel_destination, player.pipe_travel_destination.entering_direction)
	elif travel_direction == -1:
		if travel_index <= 15:
			player.exit_pipe(player.pipe_travel_destination, player.pipe_travel_destination.entering_direction)
