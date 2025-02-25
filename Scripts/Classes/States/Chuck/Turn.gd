extends ChuckState

func enter(msg := {}) -> void:
	chuck.animations.stop()
	chuck.animations.play("Turn")
	await get_tree().create_timer(1, false).timeout
	if msg.has("Direction"):
		chuck.direction = msg.get("Direction")
	if state_machine.state == self:
		if chuck.aggressive:
			state_machine.transition_to("Charge")
		else:
			state_machine.transition_to(chuck.state)

func physics_update(delta: float) -> void:
	chuck.velocity.x = 0
	chuck.velocity.y += 15
