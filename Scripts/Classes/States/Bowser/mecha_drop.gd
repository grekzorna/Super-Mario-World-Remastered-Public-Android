extends BowserBossState

func enter(_msg := {}) -> void:
	boss.can_hurt = false
	if boss.get_mecha_koopas() >= 2:
		boss.return_to_attack()
		return
	boss.bowser_sprite.play("Leave")
	await get_tree().create_timer(1, false).timeout
	SoundManager.play_sfx(SoundManager.spring, boss)
	SoundManager.play_sfx("res://Assets/Audio/SFX/hammer-bro-throw.wav", boss)
	for i in 2 - boss.get_mecha_koopas():
		boss.spawn_mecha_koopa()
	await get_tree().create_timer(1, false).timeout
	boss.bowser_sprite.play("Enter")
	await boss.bowser_sprite.animation_finished
	boss.return_to_attack()
