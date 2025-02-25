extends PowerScript

func _physics_process(delta: float) -> void:
	match player.state_machine.state.name:
		"Normal":
			main()
		"Dive":
			main()
		_:
			pass

func main() -> void:
	if Input.is_action_just_pressed(CoopManager.get_player_input_str("spin_jump", player.player_id)) and player.is_on_floor() == false:
		player.state_machine.transition_to("PropellerFly")
