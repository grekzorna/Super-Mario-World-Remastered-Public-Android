extends PlayerState

const move_speed := 150
const acceleration := 5

func enter(_msg := {}) -> void:
	pass

func update(_delta: float) -> void:
	player.current_animation = get_animation()
	if player.input_direction != 0:
		player.direction = player.input_direction
	player.sprite.scale.x = player.direction
	
	if Input.is_action_pressed("run") == false:
		state_machine.transition_to("Swim")

func physics_update(delta: float) -> void:
	var input_vector = get_input_vector().normalized()
	
	player.velocity = lerp(player.velocity, move_speed * input_vector, delta * acceleration)
	

func get_animation() -> String:
	var input_vector = get_input_vector()
	var animation = "SwimIdle"
	if input_vector.y == -1:
		animation = "TechSwimUp"
	elif input_vector.y == 1:
		animation = "TechSwimDown"
	
	if input_vector.x != 0:
		animation = "TechSwimSide"
	
	return animation

func get_input_vector() -> Vector2:
	var input_vector = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		input_vector.y = -1
	elif Input.is_action_pressed("move_down"):
		input_vector.y = 1
	else:
		input_vector.y = 0
	
	if Input.is_action_pressed("move_left"):
		input_vector.x = -1
	elif Input.is_action_pressed("move_right"):
		input_vector.x = 1
	else:
		input_vector.x = 0
	
	return input_vector
