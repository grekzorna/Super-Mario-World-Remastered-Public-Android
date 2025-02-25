extends PlayerState

var can_fly := true

var flight_force := 200

const max_fly_speed := 100
const max_fall_speed := 100
const gravity := 5

func enter(_msg := {}) -> void:
	can_fly = false
	player.velocity.y = -100
	await get_tree().create_timer(0.5, false).timeout
	can_fly = true

func physics_update(delta: float) -> void:
	if can_fly and player.bee_flight >= 1:
		if Input.is_action_pressed("jump"):
			player.velocity.y -= flight_force * delta
			player.bee_flight -= 25 * delta
		else:
			player.velocity.y += gravity
	else:
		player.velocity.y += gravity
	player.velocity.y = clamp(player.velocity.y, -max_fly_speed, max_fall_speed if player.bee_flight >= 0 else 200)
	
	player.velocity.x = clamp(player.velocity.x, -player.walk_speed, player.walk_speed)
	player.velocity.x += (player.walk_speed * (player.run_accel * 3.5) * delta) * player.input_direction
	if player.input_direction != 0:
		player.direction = player.input_direction
	if player.is_on_floor():
		state_machine.transition_to("Normal")
