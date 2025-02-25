extends ChuckState

var can_clap := true

var can_jump := true

var queued := false

var player: Player = null

func enter(_msg := {}) -> void:
	pass

func physics_update(delta: float) -> void:
	player = CoopManager.get_closest_player(chuck.global_position)
	chuck.velocity.y += 15
	if chuck.is_on_floor():
		chuck.animations.play("ClapCharge")
	elif chuck.velocity.y < 0:
		chuck.animations.play("ClapAir")
	elif chuck.velocity.y > 0 and can_clap:
		clap()

func jump(instant := false) -> void:
	if state_machine.state != self:
		return
	can_clap = true
	can_jump = false
	chuck.velocity.y = -300
	SoundManager.play_sfx(SoundManager.spring, chuck)

func clap() -> void:
	if can_clap == false:
		return
	can_clap = false
	SoundManager.play_sfx(SoundManager.clap, chuck)
	chuck.animations.play("ClapHit")


func _on_timer_timeout() -> void:
	if state_machine.state == self:
		if chuck.is_on_floor():
			if player.global_position.y + 1 < chuck.global_position.y:
				jump()
			else:
				can_clap = false
				chuck.velocity.y = -100
