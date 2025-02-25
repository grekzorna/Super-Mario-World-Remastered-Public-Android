extends PlayerState

func enter(_msg := {}) -> void:
	player.velocity.x = 0
	player.current_animation = "CarryCrouch"
	await get_tree().create_timer(0.1, false).timeout
	state_machine.transition_to("Normal")

func physics_update(_delta: float) -> void:
	player.velocity.y += 15

func update(_delta: float) -> void:
	player.carry_position.position.y = -14
	player.current_animation = "CarryCrouch"
