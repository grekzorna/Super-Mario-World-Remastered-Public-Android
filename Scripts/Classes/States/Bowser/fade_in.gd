extends BowserBossState

func enter(_msg := {}) -> void:
	boss.global_position = boss.screen_center
	SoundManager.play_ui_sound(preload("res://Assets/Audio/SFX/SMW/BowserZoomIn.mp3"))
	boss.clown_car_animations.play("ZoomIn")
	await boss.clown_car_animations.animation_finished
	state_machine.transition_to("PeachHelp")

func exit() -> void:
	boss.cutscene = false
