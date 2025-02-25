extends PlayerState


var sliding_direction := 1

func enter(_msg := {}) -> void:
	sliding_direction = player.direction
	player.big_hitbox.set_deferred("disabled", true)
	player.big_collision.set_deferred("disabled", true)

func physics_update(delta: float) -> void:
	if player.velocity_direction != sliding_direction:
		player.current_animation = "SlideTurn"
	else: player.current_animation = "PenguinSlide"
	player.velocity.x = lerpf(player.velocity.x, player.run_speed * sliding_direction, delta * 2.5)
	if player.input_direction != 0:
		sliding_direction = player.input_direction
	player.sprite.scale.x = sliding_direction
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		player.crouching = false
		state_machine.transition_to("Normal", {"Jump" = true})
	if Input.is_action_just_pressed("move_up"):
		player.crouching = false
		state_machine.transition_to("Normal")
