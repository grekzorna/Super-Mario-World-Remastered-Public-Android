extends State

func enter(_msg := { }) -> void:
	var target = CoopManager.get_closest_player(owner.global_position)
	if target.global_position.x < owner.global_position.x:
		owner.direction = -1
	else:
		owner.direction = 1
	for i in 3:
		owner.animations.play("BreathFire")
		await owner.animations.animation_finished
		if state_machine.state != self:
			return
	await get_tree().create_timer(1, false).timeout
	if state_machine.state != self:
		return
	state_machine.transition_to("Fire")
