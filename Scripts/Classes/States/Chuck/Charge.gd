extends ChuckState
@onready var step_timer: Timer = $"../../StepTimer"

func enter(_msg := {}) -> void:
	await get_tree().physics_frame
	step_timer.start()
	

func physics_update(_delta: float) -> void:
	if chuck.clone:
		if chuck.is_on_floor():
			chuck.velocity.x = 80 * chuck.direction
			chuck.clone = false
	else:
		chuck.velocity.x = 80 * chuck.direction
	chuck.velocity.y += 15
	if sign(chuck.player.global_position.x - chuck.global_position.x) != chuck.direction:
		state_machine.transition_to("Turn", {"Direction": sign(chuck.player.global_position.x - chuck.global_position.x)})
		return 
	if chuck.velocity.y < 0:
		chuck.animations.play("ClapAir")
	elif chuck.is_on_floor():
		chuck.animations.play("Charge")
	if chuck.is_on_wall():
		if chuck.is_on_floor():
			jump()

func jump() -> void:
	chuck.velocity.y = -360
	SoundManager.play_sfx(SoundManager.spring, chuck)

func _on_step_timer_timeout() -> void:
	SoundManager.play_sfx(SoundManager.bump, chuck)

func exit() -> void:
	step_timer.stop()
	chuck.animations.speed_scale = 1
