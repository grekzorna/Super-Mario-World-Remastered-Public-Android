extends Node2D


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.owner is Player:
		bounce_player(area.owner)

func bounce_player(player: Player) -> void:
	var vector = global_position.direction_to(player.global_position)
	$Animation.play("Bounce")
	player.state_machine.transition_to("Normal")
	player.velocity = 300 * vector
	if Input.is_action_pressed(CoopManager.get_player_input_str("jump", player.player_id)):
		SoundManager.play_sfx("res://Assets/Audio/SFX/SMW/BounceRingJump.wav", self)
		player.velocity.y *= 1.2
	else:
		SoundManager.play_sfx("res://Assets/Audio/SFX/SMW/BounceRingHit.wav", self)
