extends PlayerState

var slow_speed := 200
var fast_speed := 400
var can_exit := false

func enter(_msg := {}) -> void:
	can_exit = false
	player.set_collision_mask_value(1, false)
	await get_tree().physics_frame
	can_exit = true

func physics_update(delta: float) -> void:
	var direction_vector := Vector2.ZERO
	var speed := slow_speed
	direction_vector = Input.get_vector(CoopManager.get_player_input_str("move_left", player.player_id), CoopManager.get_player_input_str("move_right", player.player_id), CoopManager.get_player_input_str("move_up", player.player_id), CoopManager.get_player_input_str("move_down", player.player_id))
	if Input.is_action_pressed(CoopManager.get_player_input_str("run", player.player_id)):
		speed = fast_speed
	player.velocity = speed * direction_vector
	if Input.is_action_just_pressed(CoopManager.get_player_input_str("jump", player.player_id)) and can_exit:
		state_machine.transition_to("Normal")
	
	
func exit() -> void:
	player.set_collision_mask_value(1, true)
	player.velocity = Vector2.ZERO
