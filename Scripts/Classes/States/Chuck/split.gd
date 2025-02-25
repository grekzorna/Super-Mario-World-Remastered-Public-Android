extends ChuckState

func enter(_msg := {}) -> void:
	chuck.animations.play("SplitIdle")
	await chuck.player_entered_split
	split()
	chuck.aggressive = true

func split() -> void:
	chuck.animations.play("Split")
	await get_tree().create_timer(1, false).timeout
	state_machine.transition_to("Turn")
	spawn_chucks()

func spawn_chucks() -> void:
	for i in [-1, 1]:
		var node = load(chuck.scene_file_path).instantiate()
		node.state == "Charge"
		node.starting_direction = chuck.direction
		node.direction = chuck.direction
		node.global_position = chuck.global_position + Vector2(4 * i, 0)
		node.velocity.x = 40 * i
		node.clone = true
		chuck.add_sibling(node)
		node.state_machine.transition_to("Charge")
		await get_tree().physics_frame
		node.state_machine.state.jump()
