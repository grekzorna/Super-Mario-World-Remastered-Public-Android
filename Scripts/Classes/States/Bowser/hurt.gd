extends BowserBossState

func enter(_msg := {}) -> void:
	boss.clown_car_eyes.play("Sad")
	boss.can_hurt = false
	boss.animations.play("Hurt")
	boss.attack_timer.stop()
	boss.bowser_sprite.play("Hurt")
	await boss.bowser_sprite.animation_finished
	if boss.health <= 0:
		state_machine.transition_to("DeathTravel")
	elif boss.health % 2 == 0:
		state_machine.transition_to("FadeOut")
	else:
		boss.return_to_attack()

func exit() -> void:
	boss.clown_car_eyes.play("Normal")
