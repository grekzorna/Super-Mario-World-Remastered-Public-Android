extends BowserBossState

func enter(_msg := {}) -> void:
	boss.cutscene = true
	boss.clown_car_eyes.play("Sad")
	boss.bowser_sprite.play("HurtLoop")
	var tween = create_tween()
	tween.set_trans(tween.TRANS_LINEAR)
	tween.tween_property(boss, "global_position:y", boss.screen_center.y, 0.5)
	await get_tree().create_timer(0.5, false).timeout
	state_machine.transition_to("Death")
