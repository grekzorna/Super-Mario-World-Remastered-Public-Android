extends ChuckState

var target_player: Player = null


func enter(_msg := {}) -> void:
	await chuck.get_node("VisibleOnScreenNotifier").screen_entered
	loop()

func loop() -> void:
	if state_machine.state != self:
		return
	await get_tree().create_timer(randf_range(1, 4), false).timeout
	if state_machine.state != self:
		return
	SoundManager.play_sfx(SoundManager.spring, chuck)
	chuck.velocity.y = -350
	await get_tree().create_timer(3, false).timeout
	if state_machine.state != self:
		return
	loop()

func physics_update(delta: float) -> void:
	target_player = CoopManager.get_closest_player(chuck.global_position)
	chuck.velocity.y += 15
	if chuck.is_on_floor():
		chuck.direction = sign(target_player.global_position.x - chuck.global_position.x)
		chuck.velocity.x = 0
	else:
		chuck.velocity.x = 75 * chuck.direction
	chuck.animations.play("ClapCharge" if chuck.is_on_floor() else "ClapAir")
