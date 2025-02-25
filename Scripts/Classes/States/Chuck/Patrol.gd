extends ChuckState

func enter(_msg := {}) -> void:
	chuck.aggressive = false
	chuck.state = "Idle"
	await chuck.player_entered_split
	chuck.aggressive = true
	state_machine.transition_to("Turn", {"Direction": sign(chuck.player.global_position.x - chuck.global_position.x)})

@onready var ledge_detection_cast: LedgeDetectionCast = $"../../LedgeDetectionCast"

func physics_update(_delta: float) -> void:
	chuck.aggressive = false
	chuck.animations.speed_scale = 0.5
	if chuck.clone:
		if chuck.is_on_floor():
			chuck.velocity.x = 70 * chuck.direction
			chuck.clone = false
	else:
		chuck.velocity.x = 70 * chuck.direction
	chuck.velocity.y += 15
	ledge_detection_cast.floor_normal = chuck.get_floor_normal()
	ledge_detection_cast.position.x = abs(ledge_detection_cast.position.x) * chuck.direction
	if chuck.is_on_wall() or ledge_detection_cast.is_colliding() == false:
		state_machine.transition_to("Turn", {"Direction": chuck.direction * -1})
		ledge_detection_cast.position.x = abs(ledge_detection_cast.position.x) * -chuck.direction
		return 
	chuck.animations.play("Charge")

func jump() -> void:
	chuck.velocity.y = -360
	SoundManager.play_sfx(SoundManager.spring, chuck)

func _on_step_timer_timeout() -> void:
	SoundManager.play_sfx(SoundManager.bump, chuck)

func exit() -> void:
	chuck.animations.speed_scale = 1
