extends PowerScript

var can_enter := true

func _physics_process(delta: float) -> void:
	match player.state_machine.state.name:
		"Dive":
			slide_enter()
		"Normal":
			slide_enter()
		_:
			pass


func slide_enter() -> void:
	if abs(player.velocity.x) >= 120 and Input.is_action_pressed(CoopManager.get_player_input_str("move_down", player.player_id)):
		if player.is_on_floor() and not (player.carrying or player.holding or player.riding_yoshi) and player.sprite.animation.contains("Shell") == false:
			player.state_machine.transition_to("ShellSlide")
