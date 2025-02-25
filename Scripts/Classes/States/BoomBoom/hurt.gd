extends BoomBossClass

var can_bounce := true

func enter(_msg := {}) -> void:
	can_bounce = true
	boss.velocity.x /= 1.5
	if boss.flying:
		boss.animations.play("WingHurt")
	else:
		boss.animations.play("NormalHurt")
	await get_tree().create_timer(1, false).timeout
	if boss.health > 0:
		if not boss.spiky_head:
			state_machine.transition_to("Shell")
		else:
			state_machine.transition_to("Run")
	else:
		await get_tree().create_timer(1, false).timeout
		boss.hide()
		CoopManager.boss_defeated()

func physics_update(_delta: float) -> void:
	if boss.is_on_floor() and can_bounce:
		boss.velocity.y = -150
		boss.velocity.x /= 2
		can_bounce = false
	elif boss.is_on_floor():
		boss.velocity.x = 0
	boss.velocity.y += 15
