extends ChuckState

func enter(_msg := {}) -> void:
	chuck.animations.play("RESET")
	chuck.velocity.x = 0
	chuck.velocity.y = 100
	chuck.aggressive = true
	SoundManager.play_sfx(SoundManager.stomp, chuck)
	SoundManager.play_sfx(SoundManager.stun, chuck)
	await get_tree().process_frame
	chuck.animations.play("Hurt")
	await get_tree().create_timer(2, false).timeout
	if state_machine.state == self:
		state_machine.transition_to("Turn")

func physics_update(delta: float) -> void:
	chuck.velocity.y += 15
	chuck.animations.play("Hurt")

func exit() -> void:
	chuck.damage_enabled = true
