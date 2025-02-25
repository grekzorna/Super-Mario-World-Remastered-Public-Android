extends HeldObject

var active := false

func activate() -> void:
	active = true
	velocity = Vector2.ZERO
	GameManager.current_level.p_switch()
	SoundManager.play_sfx(SoundManager.switch_activate, self)
	sprite.play("Pressed")
	await get_tree().create_timer(0.25, false).timeout
	ParticleManager.summon_particle(ParticleManager.PUFF, global_position - Vector2(0, 8))
	queue_free()

func _on_pressbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		if active:
			return
		if not player_can_pickup(area.get_parent()):
			if area.get_parent().velocity.y > 0 and not held and area.get_parent().is_on_floor() == false:
				activate()
