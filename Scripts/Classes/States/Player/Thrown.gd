extends PlayerState
@onready var puff_trail: GPUParticles2D = $"../../Particles/PuffTrail"

func enter(_msg := {}) -> void:
	SoundManager.play_sfx(SoundManager.magic, player)
	player.current_animation = "Flip"
	player.carried = false
	player.set_collision_layer_value(1, false)
	player.carrying_player = null
	player.sprite.speed_scale = 1
	player.sprite_speed_scale = 1
	player.velocity.y = 0
	puff_trail.emitting = true

func physics_update(delta: float) -> void:
	player.carried = false
	player.carrying_player = null
	player.velocity.y += 15
	if player.is_on_floor() or player.is_on_wall():
		state_machine.transition_to("Normal")
		if player.input_direction == 0:
			player.velocity.x = 0
	
func exit() -> void:
	puff_trail.emitting = false
	player.attacking = false
