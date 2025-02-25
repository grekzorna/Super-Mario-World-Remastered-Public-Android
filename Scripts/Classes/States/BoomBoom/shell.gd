extends BoomBossClass

func enter(_msg := {}) -> void:
	if boss.flying:
		boss.animations.play("WingShellEnter")
	else:
		boss.animations.play("NormalShellEnter")
	await boss.animations.animation_finished
	if not boss.flying:
		state_machine.transition_to("Run")
	else:
		state_machine.transition_to("Fly")

func physics_update(_delta: float) -> void:
	boss.velocity.x = 0
	boss.velocity.y += 15
