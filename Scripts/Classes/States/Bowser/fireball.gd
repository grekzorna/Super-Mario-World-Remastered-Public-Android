extends BowserBossState



func enter(_msg := {}) -> void:
	boss.fire_start.emit()
	await get_tree().create_timer(8.5, false).timeout
	state_machine.transition_to("FadeIn")
