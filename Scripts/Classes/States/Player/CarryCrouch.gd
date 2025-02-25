extends PlayerState
@onready var carry_position: Marker2D = $"../../CarryPosition"

func enter(_msg := {}) -> void:
	carry_position.position.y = -16
	SoundManager.play_sfx(SoundManager.carry_grab, player)
	player.velocity = Vector2.ZERO
	player.current_animation = "CarryCrouch"
	player.animation_override = "CarryCrouch"
	await get_tree().create_timer(0.1, false).timeout
	if state_machine.state == self:
		state_machine.transition_to("Normal")
		player.animation_override = ""

func physics_update(_delta: float) -> void:
	player.velocity.y += 15
