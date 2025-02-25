extends BowserBossState


func enter(_msg := {}) -> void:
	boss.cutscene = true
	if boss.seen_intro:
		boss.animations.play("FastIntro")
	await boss.animations.animation_finished
	boss.animations.speed_scale = 1
	state_machine.transition_to("AttackIdle1")

func exit() -> void:
	boss.seen_intro = true
	boss.cutscene = false
