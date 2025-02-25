extends State

func enter(_msg := {}) -> void:
	owner.hitbox.set_deferred("monitoring", false)
	owner.animations.play("Hit")
	await get_tree().create_timer(2, false).timeout
	state_machine.transition_to("Shell")
	owner.hitbox.set_deferred("monitoring", true)
